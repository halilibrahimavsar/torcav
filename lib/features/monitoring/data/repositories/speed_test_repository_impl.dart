import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/process_runner.dart';
import '../../domain/entities/speed_test_progress.dart';
import '../../domain/repositories/speed_test_repository.dart';

@LazySingleton(as: SpeedTestRepository)
class SpeedTestRepositoryImpl implements SpeedTestRepository {
  final ProcessRunner _processRunner;

  SpeedTestRepositoryImpl(this._processRunner);

  @override
  Stream<SpeedTestProgress> runSpeedTest() async* {
    if (Platform.isLinux) {
      yield* _runLinuxCli();
      return;
    }
    yield* _runHttpSpeedTest();
  }

  Stream<SpeedTestProgress> _runLinuxCli() async* {
    yield const SpeedTestProgress(phase: SpeedTestPhase.latency);

    final result = await _processRunner.run('speedtest-cli', ['--json']);
    if (result.exitCode != 0) {
      throw const ScanFailure(
        'speedtest-cli failed. Install with: sudo pacman -S speedtest-cli',
      );
    }

    final decoded =
        jsonDecode(result.stdout.toString()) as Map<String, dynamic>;
    final downloadBits = (decoded['download'] as num?)?.toDouble() ?? 0;
    final uploadBits = (decoded['upload'] as num?)?.toDouble() ?? 0;
    final ping = (decoded['ping'] as num?)?.toDouble() ?? 0;

    yield SpeedTestProgress(
      phase: SpeedTestPhase.done,
      downloadMbps: downloadBits / 1000000,
      uploadMbps: uploadBits / 1000000,
      latencyMs: ping,
    );
  }

  /// HTTP-based speed test that streams progress.
  Stream<SpeedTestProgress> _runHttpSpeedTest() async* {
    final client =
        HttpClient()..connectionTimeout = const Duration(seconds: 10);

    try {
      // Phase 1: Latency
      yield const SpeedTestProgress(phase: SpeedTestPhase.latency);
      final latencyMs = await _measureLatency(client);

      yield SpeedTestProgress(
        phase: SpeedTestPhase.download,
        latencyMs: latencyMs,
      );

      // Phase 2: Download — stream live values
      var downloadMbps = 0.0;
      await for (final mbps in _measureDownloadStream(client)) {
        downloadMbps = mbps;
        yield SpeedTestProgress(
          phase: SpeedTestPhase.download,
          latencyMs: latencyMs,
          downloadMbps: downloadMbps,
        );
      }

      yield SpeedTestProgress(
        phase: SpeedTestPhase.upload,
        latencyMs: latencyMs,
        downloadMbps: downloadMbps,
      );

      // Phase 3: Upload
      final uploadMbps = await _measureUpload(client);

      yield SpeedTestProgress(
        phase: SpeedTestPhase.done,
        latencyMs: latencyMs,
        downloadMbps: downloadMbps,
        uploadMbps: uploadMbps,
      );
    } finally {
      client.close();
    }
  }

  Future<double> _measureLatency(HttpClient client) async {
    const testUrl = 'https://www.google.com';
    final samples = <double>[];

    for (var i = 0; i < 3; i++) {
      final sw = Stopwatch()..start();
      try {
        final request = await client.headUrl(Uri.parse(testUrl));
        final response = await request.close();
        await response.drain<void>();
        sw.stop();
        samples.add(sw.elapsedMilliseconds.toDouble());
      } catch (_) {
        // skip failed sample
      }
    }

    if (samples.isEmpty) return 0;
    return samples.reduce((a, b) => a + b) / samples.length;
  }

  /// Yields updated Mbps as chunks arrive.
  Stream<double> _measureDownloadStream(HttpClient client) async* {
    const downloadUrl = 'https://speed.cloudflare.com/__down?bytes=5000000';
    final sw = Stopwatch()..start();
    var totalBytes = 0;

    try {
      final request = await client.getUrl(Uri.parse(downloadUrl));
      final response = await request.close();
      await for (final chunk in response) {
        totalBytes += chunk.length;
        final elapsed = sw.elapsedMilliseconds;
        if (elapsed > 0) {
          final seconds = elapsed / 1000.0;
          yield (totalBytes * 8) / (seconds * 1000000);
        }
      }
      sw.stop();
    } catch (_) {
      yield 0;
    }
  }

  Future<double> _measureUpload(HttpClient client) async {
    const uploadUrl = 'https://speed.cloudflare.com/__up';
    const uploadBytes = 1000000;
    final payload = List<int>.filled(uploadBytes, 0x41);
    final sw = Stopwatch()..start();

    try {
      final request = await client.postUrl(Uri.parse(uploadUrl));
      request.headers.contentType = ContentType.binary;
      request.contentLength = uploadBytes;
      request.add(payload);
      final response = await request.close();
      await response.drain<void>();
      sw.stop();
    } catch (_) {
      return 0;
    }

    if (sw.elapsedMilliseconds == 0) return 0;
    final seconds = sw.elapsedMilliseconds / 1000.0;
    return (uploadBytes * 8) / (seconds * 1000000);
  }
}
