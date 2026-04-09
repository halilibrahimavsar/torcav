import 'package:equatable/equatable.dart';

class KnownNetwork extends Equatable {
  final String ssid;
  final String bssid;
  final String security;
  final String? gateway;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final int seenCount;

  const KnownNetwork({
    required this.ssid,
    required this.bssid,
    required this.security,
    this.gateway,
    required this.firstSeen,
    required this.lastSeen,
    this.seenCount = 1,
  });

  KnownNetwork copyWith({
    String? ssid,
    String? bssid,
    String? security,
    String? gateway,
    DateTime? firstSeen,
    DateTime? lastSeen,
    int? seenCount,
  }) {
    return KnownNetwork(
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      security: security ?? this.security,
      gateway: gateway ?? this.gateway,
      firstSeen: firstSeen ?? this.firstSeen,
      lastSeen: lastSeen ?? this.lastSeen,
      seenCount: seenCount ?? this.seenCount,
    );
  }

  @override
  List<Object?> get props => [
        ssid,
        bssid,
        security,
        gateway,
        firstSeen,
        lastSeen,
        seenCount,
      ];
}
