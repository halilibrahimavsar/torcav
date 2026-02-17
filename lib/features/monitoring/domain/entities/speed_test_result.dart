import 'package:equatable/equatable.dart';

class SpeedTestResult extends Equatable {
  final DateTime timestamp;
  final String backend;
  final double downloadMbps;
  final double uploadMbps;
  final double latencyMs;

  const SpeedTestResult({
    required this.timestamp,
    required this.backend,
    required this.downloadMbps,
    required this.uploadMbps,
    required this.latencyMs,
  });

  @override
  List<Object?> get props => [
    timestamp,
    backend,
    downloadMbps,
    uploadMbps,
    latencyMs,
  ];
}
