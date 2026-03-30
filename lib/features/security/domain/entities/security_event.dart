import 'package:equatable/equatable.dart';

enum SecurityEventType {
  rogueApSuspected,
  deauthBurstDetected,
  handshakeCaptureStarted,
  handshakeCaptureCompleted,
  captivePortalDetected,
  evilTwinDetected,
  deauthAttackSuspected,
  encryptionDowngraded,
  unsupportedOperation,
}

enum SecurityEventSeverity { low, medium, info, warning, high, critical }

class SecurityEvent extends Equatable {
  final int? id;
  final SecurityEventType type;
  final SecurityEventSeverity severity;
  final String ssid;
  final String bssid;
  final DateTime timestamp;
  final String evidence;
  final bool isRead;

  const SecurityEvent({
    this.id,
    required this.type,
    required this.severity,
    required this.ssid,
    required this.bssid,
    required this.timestamp,
    required this.evidence,
    this.isRead = false,
  });

  SecurityEvent copyWith({
    int? id,
    SecurityEventType? type,
    SecurityEventSeverity? severity,
    String? ssid,
    String? bssid,
    DateTime? timestamp,
    String? evidence,
    bool? isRead,
  }) {
    return SecurityEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      timestamp: timestamp ?? this.timestamp,
      evidence: evidence ?? this.evidence,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props =>
      [id, type, severity, ssid, bssid, timestamp, evidence, isRead];
}
