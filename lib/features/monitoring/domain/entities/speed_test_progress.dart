import 'package:equatable/equatable.dart';

/// Represents the current phase and live metrics of a speed test.
enum SpeedTestPhase { idle, latency, download, upload, done }

class SpeedTestProgress extends Equatable {
  final SpeedTestPhase phase;
  final double latencyMs;
  final double downloadMbps;
  final double uploadMbps;

  const SpeedTestProgress({
    required this.phase,
    this.latencyMs = 0,
    this.downloadMbps = 0,
    this.uploadMbps = 0,
  });

  const SpeedTestProgress.idle()
    : phase = SpeedTestPhase.idle,
      latencyMs = 0,
      downloadMbps = 0,
      uploadMbps = 0;

  SpeedTestProgress copyWith({
    SpeedTestPhase? phase,
    double? latencyMs,
    double? downloadMbps,
    double? uploadMbps,
  }) {
    return SpeedTestProgress(
      phase: phase ?? this.phase,
      latencyMs: latencyMs ?? this.latencyMs,
      downloadMbps: downloadMbps ?? this.downloadMbps,
      uploadMbps: uploadMbps ?? this.uploadMbps,
    );
  }

  @override
  List<Object?> get props => [phase, latencyMs, downloadMbps, uploadMbps];
}
