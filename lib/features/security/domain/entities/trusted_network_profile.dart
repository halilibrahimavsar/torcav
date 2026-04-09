import 'package:equatable/equatable.dart';

import 'network_fingerprint.dart';

class TrustedNetworkProfile extends Equatable {
  const TrustedNetworkProfile({
    required this.ssid,
    required this.bssid,
    required this.fingerprint,
    required this.trustedAt,
    required this.lastConfirmedAt,
    this.gateway,
    this.notes = '',
  });

  factory TrustedNetworkProfile.fromJson(Map<String, dynamic> json) {
    return TrustedNetworkProfile(
      ssid: json['ssid'] as String? ?? '',
      bssid: json['bssid'] as String? ?? '',
      gateway: json['gateway'] as String?,
      fingerprint: NetworkFingerprint.fromJson(
        json['fingerprint'] as Map<String, dynamic>? ?? const {},
      ),
      trustedAt:
          DateTime.tryParse(json['trustedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      lastConfirmedAt:
          DateTime.tryParse(json['lastConfirmedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      notes: json['notes'] as String? ?? '',
    );
  }

  final String ssid;
  final String bssid;
  final String? gateway;
  final NetworkFingerprint fingerprint;
  final DateTime trustedAt;
  final DateTime lastConfirmedAt;
  final String notes;

  TrustedNetworkProfile copyWith({
    String? ssid,
    String? bssid,
    String? gateway,
    NetworkFingerprint? fingerprint,
    DateTime? trustedAt,
    DateTime? lastConfirmedAt,
    String? notes,
  }) {
    return TrustedNetworkProfile(
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      gateway: gateway ?? this.gateway,
      fingerprint: fingerprint ?? this.fingerprint,
      trustedAt: trustedAt ?? this.trustedAt,
      lastConfirmedAt: lastConfirmedAt ?? this.lastConfirmedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'bssid': bssid,
      'gateway': gateway,
      'fingerprint': fingerprint.toJson(),
      'trustedAt': trustedAt.toIso8601String(),
      'lastConfirmedAt': lastConfirmedAt.toIso8601String(),
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [
    ssid,
    bssid,
    gateway,
    fingerprint,
    trustedAt,
    lastConfirmedAt,
    notes,
  ];
}
