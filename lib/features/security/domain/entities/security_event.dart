import 'package:equatable/equatable.dart';

enum SecurityEventType {
  rogueApSuspected,
  deauthBurstDetected,
  handshakeCaptureStarted,
  handshakeCaptureCompleted,
  captivePortalDetected,
  unsupportedOperation,
}

enum SecurityEventSeverity { info, warning, high, critical }

class SecurityEvent extends Equatable {
  final SecurityEventType type;
  final SecurityEventSeverity severity;
  final String ssid;
  final String bssid;
  final DateTime timestamp;
  final String evidence;

  const SecurityEvent({
    required this.type,
    required this.severity,
    required this.ssid,
    required this.bssid,
    required this.timestamp,
    required this.evidence,
  });

  @override
  List<Object?> get props => [type, severity, ssid, bssid, timestamp, evidence];
}
