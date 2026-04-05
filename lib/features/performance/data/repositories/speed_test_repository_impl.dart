import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import '../../domain/entities/speed_test_progress.dart';
import '../../domain/repositories/speed_test_repository.dart';

// ── Time budgets ─────────────────────────────────────────────────────────────
// Latency   : 1 warmup + 7 timed pings  →  ~1.5 s
// Download  : keep making 20 MB requests until 10 s elapsed → always ≈ 10 s
// Upload    : keep making 2 MB  requests until 10 s elapsed → always ≈ 10 s
// Total     : ≈ 21–22 s on any connection speed.
// ─────────────────────────────────────────────────────────────────────────────

const _kPingPings = 7; // timed pings after 1 warmup
const _kPingUrl = 'https://speed.cloudflare.com/__down?bytes=1'; // 1-byte body
const _kConnectionTimeout = Duration(seconds: 10);
const _kDrainTimeout = Duration(seconds: 2);

const _kDownloadDuration = Duration(seconds: 10);
// 20 MB is large enough to last several seconds on mid-speed links.
// On very fast links (≥ 100 Mbps) it finishes quickly so we loop again.
const _kDownloadChunkUrl = 'https://speed.cloudflare.com/__down?bytes=20000000';

const _kUploadDuration = Duration(seconds: 10);
// 2 MB per round: finishes in < 1 s at 16+ Mbps, ≈ 16 s at 1 Mbps.
// We accept that a single round on a very slow link may overshoot the budget
// slightly — accuracy matters more than strict timing on slow connections.
const _kUploadChunkBytes = 2 * 1024 * 1024; // 2 MB
const _kUploadUrl = 'https://speed.cloudflare.com/__up';

@LazySingleton(as: SpeedTestRepository)
class SpeedTestRepositoryImpl implements SpeedTestRepository {
  const SpeedTestRepositoryImpl();

  @override
  Stream<SpeedTestProgress> runSpeedTest() async* {
    yield* _runHttpSpeedTest();
  }

  // ── HTTP path ─────────────────────────────────────────────────────────────

  Stream<SpeedTestProgress> _runHttpSpeedTest() async* {
    final client =
        HttpClient()..connectionTimeout = _kConnectionTimeout;

    try {
      // ── Phase 1 ───────────────────────────────────────────────────────────
      yield const SpeedTestProgress(phase: SpeedTestPhase.latency);
      final (latencyMs, jitterMs) = await _measureLatency(client);

      // ── Phase 2 ───────────────────────────────────────────────────────────
      yield SpeedTestProgress(
        phase: SpeedTestPhase.download,
        latencyMs: latencyMs,
        jitterMs: jitterMs,
      );

      var downloadMbps = 0.0;
      await for (final mbps in _measureDownload(client)) {
        downloadMbps = mbps;
        yield SpeedTestProgress(
          phase: SpeedTestPhase.download,
          latencyMs: latencyMs,
          jitterMs: jitterMs,
          downloadMbps: downloadMbps,
        );
      }

      // ── Phase 3 ───────────────────────────────────────────────────────────
      yield SpeedTestProgress(
        phase: SpeedTestPhase.upload,
        latencyMs: latencyMs,
        jitterMs: jitterMs,
        downloadMbps: downloadMbps,
      );

      var uploadMbps = 0.0;
      await for (final mbps in _measureUpload(client)) {
        uploadMbps = mbps;
        yield SpeedTestProgress(
          phase: SpeedTestPhase.upload,
          latencyMs: latencyMs,
          jitterMs: jitterMs,
          downloadMbps: downloadMbps,
          uploadMbps: uploadMbps,
        );
      }

      yield SpeedTestProgress(
        phase: SpeedTestPhase.done,
        latencyMs: latencyMs,
        jitterMs: jitterMs,
        downloadMbps: downloadMbps,
        uploadMbps: uploadMbps,
      );
    } finally {
      client.close(force: true);
    }
  }

  // ── Latency ───────────────────────────────────────────────────────────────
  //
  // Strategy: warm up the TCP+TLS connection with one discarded request, then
  // make [_kPingPings] timed GETs on the same keep-alive connection.
  // Reporting the median removes the effect of OS/GC-induced spikes.

  /// Returns (medianLatencyMs, jitterMs).
  Future<(double, double)> _measureLatency(HttpClient client) async {
    // Warmup — DNS + TCP + TLS paid here, not counted in results.
    try {
      final req = await client.getUrl(Uri.parse(_kPingUrl));
      final resp = await req.close();
      await resp.drain<void>();
    } catch (_) {}

    final samples = <double>[];
    for (var i = 0; i < _kPingPings; i++) {
      final sw = Stopwatch()..start();
      try {
        final req = await client.getUrl(Uri.parse(_kPingUrl));
        final resp = await req.close();
        await resp.drain<void>();
        sw.stop();
        samples.add(sw.elapsedMilliseconds.toDouble());
      } catch (_) {
        // skip failed sample
      }
    }

    if (samples.isEmpty) return (0.0, 0.0);
    samples.sort();
    final median = samples[samples.length ~/ 2];
    // Jitter = mean absolute deviation between consecutive sorted samples.
    double jitterSum = 0;
    for (var i = 1; i < samples.length; i++) {
      jitterSum += (samples[i] - samples[i - 1]).abs();
    }
    final jitter = samples.length > 1 ? jitterSum / (samples.length - 1) : 0.0;
    return (median, jitter);
  }

  // ── Download ──────────────────────────────────────────────────────────────
  //
  // Runs 4 parallel streams simultaneously to saturate the pipe.  Each stream
  // independently downloads 20 MB chunks and reports its byte count to a
  // shared accumulator.  The controller yields a live throughput reading
  // every 200 ms until [_kDownloadDuration] has elapsed.

  static const _kDownloadStreams = 4;

  Stream<double> _measureDownload(HttpClient client) async* {
    final sw = Stopwatch()..start();
    var totalBytes = 0;
    final controller = StreamController<int>();

    // Spawn parallel downloader workers.
    var activeWorkers = _kDownloadStreams;
    for (var i = 0; i < _kDownloadStreams; i++) {
      _downloadWorker(client, sw, controller).then((_) {
        activeWorkers--;
        if (activeWorkers == 0) controller.close();
      });
    }

    var lastReportMs = -999;
    await for (final bytes in controller.stream) {
      totalBytes += bytes;
      final elapsedMs = sw.elapsedMilliseconds;
      if (elapsedMs > 500 && elapsedMs - lastReportMs >= 200) {
        lastReportMs = elapsedMs;
        yield _mbps(totalBytes, elapsedMs);
      }
    }

    if (totalBytes > 0 && sw.elapsedMilliseconds > 0) {
      yield _mbps(totalBytes, sw.elapsedMilliseconds);
    }
  }

  Future<void> _downloadWorker(
    HttpClient client,
    Stopwatch sw,
    StreamController<int> sink,
  ) async {
    while (sw.elapsed < _kDownloadDuration) {
      try {
        final request = await client.getUrl(Uri.parse(_kDownloadChunkUrl));
        final response = await request.close();
        if (response.statusCode < 200 || response.statusCode >= 300) {
          await response.drain<void>();
          return;
        }
        await for (final chunk in response) {
          if (!sink.isClosed) sink.add(chunk.length);
          if (sw.elapsed >= _kDownloadDuration) return;
        }
      } catch (_) {
        return;
      }
    }
  }

  // ── Upload ────────────────────────────────────────────────────────────────
  //
  // Repeatedly POSTs a 2 MB payload to the Cloudflare upload endpoint.
  // We measure wall-clock time from the first send to each server ACK so the
  // result accurately reflects actual network throughput.
  //
  // Per-request timeout = remaining budget + 5 s grace.  This means:
  //   - fast link (100 Mbps): 2 MB ≈ 0.16 s → many rounds, very accurate.
  //   - slow link (1 Mbps)  : 2 MB ≈ 16 s  → one round, slight overshoot, but
  //                           we still get a valid measurement.

  Stream<double> _measureUpload(HttpClient client) async* {
    final payload = List<int>.filled(_kUploadChunkBytes, 0x41);
    var totalBytes = 0;
    final sw = Stopwatch()..start();

    while (sw.elapsed < _kUploadDuration) {
      final remainingMs = (_kUploadDuration - sw.elapsed).inMilliseconds.clamp(
        0,
        60000,
      );

      try {
        final request = await client
            .postUrl(Uri.parse(_kUploadUrl))
            .timeout(_kConnectionTimeout);

        request.headers.set(
          HttpHeaders.contentTypeHeader,
          'application/octet-stream',
        );
        request.contentLength = _kUploadChunkBytes;
        request.add(payload);

        // request.close() flushes the body AND waits for response headers.
        // The server only responds after receiving all bytes, so this is the
        // correct moment to stop the clock for upload throughput.
        final response = await request.close().timeout(
          Duration(milliseconds: remainingMs + 5000),
        );

        // Quickly discard the (empty) response body.
        await response.drain<void>().timeout(_kDrainTimeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          totalBytes += _kUploadChunkBytes;
          final elapsedMs = sw.elapsedMilliseconds;
          if (elapsedMs > 0) {
            yield _mbps(totalBytes, elapsedMs);
          }
        }
        // Non-2xx response: skip this round and try again (rate-limit etc.).
      } on TimeoutException {
        // Time budget exhausted mid-request — break cleanly.
        break;
      } catch (_) {
        // Connection error — stop trying.
        break;
      }
    }

    // Emit final computed value even if the last round slightly overshot the
    // budget (slow-link case where one round > 10 s).
    if (totalBytes > 0 && sw.elapsedMilliseconds > 0) {
      yield _mbps(totalBytes, sw.elapsedMilliseconds);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static double _mbps(int bytes, int elapsedMs) {
    if (elapsedMs <= 0) return 0;
    return (bytes * 8) / (elapsedMs / 1000.0 * 1_000_000);
  }
}
