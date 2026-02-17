import 'package:equatable/equatable.dart';

enum SecurityType { open, wep, wpa, wpa2, wpa3, unknown }

class WifiNetwork extends Equatable {
  final String ssid;
  final String bssid;
  final int signalStrength; // in dBm
  final int channel;
  final int frequency; // in MHz
  final SecurityType security;
  final String vendor; // OUI lookup result
  final bool isHidden;

  const WifiNetwork({
    required this.ssid,
    required this.bssid,
    required this.signalStrength,
    required this.channel,
    required this.frequency,
    required this.security,
    this.vendor = 'Unknown',
    this.isHidden = false,
  });

  WifiNetwork copyWith({
    String? ssid,
    String? bssid,
    int? signalStrength,
    int? channel,
    int? frequency,
    SecurityType? security,
    String? vendor,
    bool? isHidden,
  }) {
    return WifiNetwork(
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      signalStrength: signalStrength ?? this.signalStrength,
      channel: channel ?? this.channel,
      frequency: frequency ?? this.frequency,
      security: security ?? this.security,
      vendor: vendor ?? this.vendor,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  @override
  List<Object?> get props => [
    ssid,
    bssid,
    signalStrength,
    channel,
    frequency,
    security,
    vendor,
    isHidden,
  ];
}
