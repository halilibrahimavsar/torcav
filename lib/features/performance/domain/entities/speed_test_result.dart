import 'package:equatable/equatable.dart';

class SpeedTestResult extends Equatable {
  final int? id;
  final DateTime recordedAt;
  final double latencyMs;
  final double jitterMs;
  final double downloadMbps;
  final double uploadMbps;

  const SpeedTestResult({
    this.id,
    required this.recordedAt,
    required this.latencyMs,
    required this.jitterMs,
    required this.downloadMbps,
    required this.uploadMbps,
  });

  @override
  List<Object?> get props =>
      [id, recordedAt, latencyMs, jitterMs, downloadMbps, uploadMbps];
}
