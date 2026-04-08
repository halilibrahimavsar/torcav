import 'package:equatable/equatable.dart';

class SpeedTestResult extends Equatable {
  final int? id;
  final DateTime recordedAt;
  final double latencyMs;
  final double jitterMs;
  final double downloadMbps;
  final double uploadMbps;
  final double packetLoss;
  final double loadedLatencyMs;

  const SpeedTestResult({
    this.id,
    required this.recordedAt,
    required this.latencyMs,
    required this.jitterMs,
    required this.downloadMbps,
    required this.uploadMbps,
    this.packetLoss = 0,
    this.loadedLatencyMs = 0,
  });

  @override
  List<Object?> get props => [
        id,
        recordedAt,
        latencyMs,
        jitterMs,
        downloadMbps,
        uploadMbps,
        packetLoss,
        loadedLatencyMs,
      ];
}
