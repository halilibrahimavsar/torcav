import 'package:equatable/equatable.dart';

class KnownNetwork extends Equatable {
  final String ssid;
  final String bssid;
  final String security;
  final DateTime firstSeen;
  final DateTime lastSeen;

  const KnownNetwork({
    required this.ssid,
    required this.bssid,
    required this.security,
    required this.firstSeen,
    required this.lastSeen,
  });

  @override
  List<Object?> get props => [ssid, bssid, security, firstSeen, lastSeen];
}
