import 'package:equatable/equatable.dart';

import 'lan_exposure_finding.dart';
import 'service_fingerprint.dart';
import 'vulnerability_finding.dart';

class HostScanResult extends Equatable {
  final String ip;
  final String mac;
  final String vendor;
  final String hostName;
  final String osGuess;
  final double latency;
  final List<ServiceFingerprint> services;
  final List<LanExposureFinding> exposureFindings;
  final double exposureScore;
  final String deviceType;

  const HostScanResult({
    required this.ip,
    required this.mac,
    required this.vendor,
    required this.hostName,
    required this.osGuess,
    required this.latency,
    required this.services,
    required this.exposureFindings,
    required this.exposureScore,
    required this.deviceType,
  });

  List<VulnerabilityFinding> get vulnerabilities =>
      exposureFindings.map((finding) => finding.toLegacyFinding()).toList();

  @override
  List<Object?> get props => [
    ip,
    mac,
    vendor,
    hostName,
    osGuess,
    latency,
    services,
    exposureFindings,
    exposureScore,
    deviceType,
  ];
}
