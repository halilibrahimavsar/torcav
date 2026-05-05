import 'package:equatable/equatable.dart';

import '../../../performance/domain/entities/speed_test_result.dart';
import '../../../security/domain/entities/dns_test_result.dart';
import '../../../security/domain/entities/network_context_type.dart';
import '../../../wifi_scan/domain/entities/wifi_network.dart';

/// Bundle of every signal the diagnose use case needs.
///
/// Any field may be null when the corresponding probe was unavailable
/// (offline cellular, scan permission denied, DNS benchmark failed); the
/// use case must degrade gracefully.
class DiagnosisInputs extends Equatable {
  final WifiNetwork? connectedNetwork;
  final List<WifiNetwork> visibleNetworks;
  final SpeedTestResult? speedTest;
  final int? gatewayPingMs;
  final DnsBenchmarkResult? dnsBenchmark;
  final NetworkContextType context;

  const DiagnosisInputs({
    required this.connectedNetwork,
    required this.visibleNetworks,
    required this.speedTest,
    required this.gatewayPingMs,
    required this.dnsBenchmark,
    required this.context,
  });

  @override
  List<Object?> get props => [
    connectedNetwork,
    visibleNetworks,
    speedTest,
    gatewayPingMs,
    dnsBenchmark,
    context,
  ];
}
