import 'package:equatable/equatable.dart';

class JitterSample extends Equatable {
  final DateTime ts;
  final double latencyMs;
  final double jitterMs;
  final double lossPct;

  const JitterSample({
    required this.ts,
    required this.latencyMs,
    required this.jitterMs,
    required this.lossPct,
  });

  @override
  List<Object?> get props => [ts, latencyMs, jitterMs, lossPct];
}
