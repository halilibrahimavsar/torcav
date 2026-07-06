import 'package:equatable/equatable.dart';

class JitterSample extends Equatable {
  final DateTime ts;
  final double latencyMs;
  final double jitterMs;
  final double lossPct;

  /// Resolver the native tunnel is currently using. Lets the cubit mirror
  /// auto-DNS switches performed by the native alert engine while the Dart
  /// side was dead or backgrounded. Null on platforms/protocol versions
  /// that don't report it.
  final String? activeDnsIp;

  const JitterSample({
    required this.ts,
    required this.latencyMs,
    required this.jitterMs,
    required this.lossPct,
    this.activeDnsIp,
  });

  @override
  List<Object?> get props => [ts, latencyMs, jitterMs, lossPct, activeDnsIp];
}
