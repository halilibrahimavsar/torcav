import 'package:equatable/equatable.dart';

/// Represents the current phase and live metrics of a speed test.
enum SpeedTestPhase { idle, latency, download, upload, done }

class SpeedTestProgress extends Equatable {
  final SpeedTestPhase phase;
  final double latencyMs;
  final double jitterMs;
  final double downloadMbps;
  final double uploadMbps;
  final double packetLoss;
  final double loadedLatencyMs;

  const SpeedTestProgress({
    required this.phase,
    this.latencyMs = 0,
    this.jitterMs = 0,
    this.downloadMbps = 0,
    this.uploadMbps = 0,
    this.packetLoss = 0,
    this.loadedLatencyMs = 0,
  });

  const SpeedTestProgress.idle()
    : phase = SpeedTestPhase.idle,
      latencyMs = 0,
      jitterMs = 0,
      downloadMbps = 0,
      uploadMbps = 0,
      packetLoss = 0,
      loadedLatencyMs = 0;

  SpeedTestProgress copyWith({
    SpeedTestPhase? phase,
    double? latencyMs,
    double? jitterMs,
    double? downloadMbps,
    double? uploadMbps,
    double? packetLoss,
    double? loadedLatencyMs,
  }) {
    return SpeedTestProgress(
      phase: phase ?? this.phase,
      latencyMs: latencyMs ?? this.latencyMs,
      jitterMs: jitterMs ?? this.jitterMs,
      downloadMbps: downloadMbps ?? this.downloadMbps,
      uploadMbps: uploadMbps ?? this.uploadMbps,
      packetLoss: packetLoss ?? this.packetLoss,
      loadedLatencyMs: loadedLatencyMs ?? this.loadedLatencyMs,
    );
  }

  @override
  List<Object?> get props =>
      [phase, latencyMs, jitterMs, downloadMbps, uploadMbps, packetLoss, loadedLatencyMs];
}
