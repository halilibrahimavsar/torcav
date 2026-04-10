import 'package:equatable/equatable.dart';

class ConnectedSignal extends Equatable {
  const ConnectedSignal({
    required this.ssid,
    required this.bssid,
    required this.rssi,
    required this.frequency,
    required this.linkSpeedMbps,
    required this.timestamp,
  });

  final String ssid;
  final String bssid;
  final int rssi;
  final int frequency;
  final int linkSpeedMbps;
  final DateTime timestamp;

  ConnectedSignal copyWith({
    String? ssid,
    String? bssid,
    int? rssi,
    int? frequency,
    int? linkSpeedMbps,
    DateTime? timestamp,
  }) {
    return ConnectedSignal(
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      rssi: rssi ?? this.rssi,
      frequency: frequency ?? this.frequency,
      linkSpeedMbps: linkSpeedMbps ?? this.linkSpeedMbps,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
    ssid,
    bssid,
    rssi,
    frequency,
    linkSpeedMbps,
    timestamp,
  ];
}
