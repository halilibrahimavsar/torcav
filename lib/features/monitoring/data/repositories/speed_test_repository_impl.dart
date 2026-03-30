import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/process_runner.dart';
import '../../domain/entities/speed_test_progress.dart';
import '../../domain/repositories/speed_test_repository.dart';

// ── All measurements use Cloudflare's speed-test CDN. ───────────────────────
// Latency   : 1 warmup request + 5 timed requests on the warm connection.
//             Taking the median avoids outliers from GC/OS scheduler jitter.
// Download  : Fixed 2.5 s window — we request a 500 MB file and break after
//             the time budget, so the result is always ≈ 2.5 s on any link.
// Upload    : Fixed 2.5 s window — we send 512 KB chunks sequentially and
//             stop when the budget is exhausted; each chunk has its own hard
//             timeout so a stalled slow connection still finishes in time.
// Total     : ~1 s (latency) + 2.5 s (dl) + 2.5 s (ul) ≈ 6–7 s.
// ────────────────────────────────────────────────────────────────────────────

// Using bytes=0 for the ping endpoint — zero-byte body, so we only measure
// network RTT + server processing, not transfer time.
const _kPingUrl = 'https://speed.cloudflare.com/__down?bytes=0';

// 500 MB is large enough that even a 1 Gbit/s link won't exhaust it in 2.5 s.
const _kDownloadUrl = 'https://speed.cloudflare.com/__down?bytes=500000000';
const _kUploadUrl = 'https://speed.cloudflare.com/__up';

const _kDownloadDuration = Duration(milliseconds: 2500);
const _kUploadDuration = Duration(milliseconds: 2500);

// 512 KB per upload round: small enough to complete even on ~2 Mbit/s links.
const _kUploadChunkBytes = 524288;

@LazySingleton(as: SpeedTestRepository)
class SpeedTestRepositoryImpl implements SpeedTestRepository {
  final ProcessRunner _processRunner;

  SpeedTestRepositoryImpl(this._processRunner);

  @override
  Stream<SpeedTestProgress> runSpeedTest() async* {
    if (Platform.isLinux) {
      var cliSuccess = false;
      try {
        await for (final progress in _runLinuxCli()) {
          yield progress;
          if (progress.phase == SpeedTestPhase.done) {
            cliSuccess = true;
          }
        }
      } catch (_) {
        // Fall through to HTTP
      }
      if (cliSuccess) return;
    }

    yield* _runHttpSpeedTest();
  }

  // ── Linux CLI path ────────────────────────────────────────────────────────

  Stream<SpeedTestProgress> _runLinuxCli() async* {
    yield const SpeedTestProgress(phase: SpeedTestPhase.latency);

    final result = await _processRunner.run('speedtest-cli', ['--json']);
    if (result.exitCode != 0) throw const ScanFailure('CLI failed');

    final decoded =
        jsonDecode(result.stdout.toString()) as Map<String, dynamic>;

    yield SpeedTestProgress(
      phase: SpeedTestPhase.done,
      downloadMbps: ((decoded['download'] as num?)?.toDouble() ?? 0) / 1000000,
      uploadMbps: ((decoded['upload'] as num?)?.toDouble() ?? 0) / 1000000,
      latencyMs: (decoded['ping'] as num?)?.toDouble() ?? 0,
    );
  }

  // ── HTTP path ─────────────────────────────────────────────────────────────

  Stream<SpeedTestProgress> _runHttpSpeedTest() async* {
    // connectionTimeout only applies to establishing the socket.
    // Per-operation timeouts are set inline below.
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);

    try {
      // ── Phase 1: Latency ──────────────────────────────────────────────────
      yield const SpeedTestProgress(phase: SpeedTestPhase.latency);
      final latencyMs = await _measureLatency(client);

      // ── Phase 2: Download ─────────────────────────────────────────────────
      yield SpeedTestProgress(
        phase: SpeedTestPhase.download,
        latencyMs: latencyMs,
      );

      var downloadMbps = 0.0;
      await for (final mbps in _measureDownloadStream(client)) {
        downloadMbps = mbps;
        yield SpeedTestProgress(
          phase: SpeedTestPhase.download,
          latencyMs: latencyMs,
          downloadMbps: downloadMbps,
        );
      }

      // ── Phase 3: Upload ───────────────────────────────────────────────────
      yield SpeedTestProgress(
        phase: SpeedTestPhase.upload,
        latencyMs: latencyMs,
        downloadMbps: downloadMbps,
      );

      var uploadMbps = 0.0;
      await for (final mbps in _measureUploadStream(client)) {
        uploadMbps = mbps;
        yield SpeedTestProgress(
          phase: SpeedTestPhase.upload,
          latencyMs: latencyMs,
          downloadMbps: downloadMbps,
          uploadMbps: uploadMbps,
        );
      }

      yield SpeedTestProgress(
        phase: SpeedTestPhase.done,
        latencyMs: latencyMs,
        downloadMbps: downloadMbps,
        uploadMbps: uploadMbps,
      );
    } finally {
      client.close(force: true);
    }
  }

  // ── Latency ───────────────────────────────────────────────────────────────

  /// Makes 1 warmup GET to `_kPingUrl` (zero-byte body) to establish the
  /// TCP+TLS connection, then performs 5 timed GETs on the *same warm*
  /// connection and returns the **median** round-trip time in milliseconds.
  ///
  /// Using the median instead of the mean removes the effect of occasional
  /// OS-scheduler or GC pauses that inflate one or two samples.
  Future<double> _measureLatency(HttpClient client) async {
    // Warmup: TCP + TLS handshake are paid here, not in measurements.
    try {
      final req = await client.getUrl(Uri.parse(_kPingUrl));
      final resp = await req.close();
      await resp.drain<void>();
    } catch (_) {
      // If warmup fails the timed requests will be slightly inflated, but
      // the test can still produce a useful result.
    }

    final samples = <double>[];
    for (var i = 0; i < 5; i++) {
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

    if (samples.isEmpty) return 0;
    samples.sort();
    // Median: middle element for odd count, lower-middle for even.
    return samples[samples.length ~/ 2];
  }

  // ── Download ──────────────────────────────────────────────────────────────

  /// Streams live Mbps readings while downloading from Cloudflare for exactly
  /// [_kDownloadDuration].  Requesting 500 MB ensures the file is never
  /// exhausted before the deadline even on very fast links.
  Stream<double> _measureDownloadStream(HttpClient client) async* {
    final sw = Stopwatch()..start();
    var totalBytes = 0;
    var lastReportMs = -999;

    try {
      final request = await client.getUrl(Uri.parse(_kDownloadUrl));
      final response = await request.close();

      await for (final chunk in response) {
        totalBytes += chunk.length;
        final elapsedMs = sw.elapsedMilliseconds;

        // Time budget exhausted — yield final value and stop.
        if (sw.elapsed >= _kDownloadDuration) {
          yield _mbps(totalBytes, elapsedMs);
          break;
        }

        // Report at most every 150 ms, after an initial 400 ms stabilisation
        // window (early chunks can be bursty due to TCP slow-start).
        if (elapsedMs > 400 && elapsedMs - lastReportMs >= 150) {
          lastReportMs = elapsedMs;
          yield _mbps(totalBytes, elapsedMs);
        }
      }

      // File finished before the deadline (only happens on very slow links
      // where the 500 MB server side is somehow truncated — unlikely).
      if (totalBytes > 0 && sw.elapsedMilliseconds > 0) {
        yield _mbps(totalBytes, sw.elapsedMilliseconds);
      }
    } catch (_) {
      if (totalBytes > 0 && sw.elapsedMilliseconds > 0) {
        yield _mbps(totalBytes, sw.elapsedMilliseconds);
      } else {
        yield 0;
      }
    }
  }

  // ── Upload ────────────────────────────────────────────────────────────────

  /// Sends 512 KB POST requests to Cloudflare until [_kUploadDuration] is
  /// exhausted.  Each individual request has its own deadline so a stalled
  /// slow connection cannot run past the overall budget.
  ///
  /// Timing: from `request.add()` to the server response arriving (i.e. the
  /// server received all bytes and acknowledged them).  `request.close()`
  /// waits for both the outgoing body to be flushed *and* response headers to
  /// arrive, which is the correct measurement point for upload throughput.
  Stream<double> _measureUploadStream(HttpClient client) async* {
    final payload = List<int>.filled(_kUploadChunkBytes, 0x41);
    var totalBytes = 0;
    final sw = Stopwatch()..start();

    while (sw.elapsed < _kUploadDuration) {
      final remainingMs =
          (_kUploadDuration - sw.elapsed).inMilliseconds.clamp(1, 10000);

      try {
        final request = await client.postUrl(Uri.parse(_kUploadUrl));
        request.headers.contentType = ContentType.binary;
        request.contentLength = _kUploadChunkBytes;
        request.add(payload);

        // This future resolves when the server has received all bytes and
        // returned its response headers — the right point to stop the clock.
        final response = await request
            .close()
            .timeout(Duration(milliseconds: remainingMs + 500));
        // Discard response body quickly.
        await response.drain<void>().timeout(const Duration(milliseconds: 300));

        totalBytes += _kUploadChunkBytes;
        final elapsedMs = sw.elapsedMilliseconds;
        if (elapsedMs > 0) {
          yield _mbps(totalBytes, elapsedMs);
        }
      } on TimeoutException {
        break; // Hard deadline reached mid-request.
      } catch (_) {
        break;
      }
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  static double _mbps(int bytes, int elapsedMs) {
    if (elapsedMs <= 0) return 0;
    return (bytes * 8) / (elapsedMs / 1000.0 * 1000000);
  }
}
