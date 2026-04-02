import 'package:equatable/equatable.dart';

enum SecurityType { open, wep, wpa, wpa2, wpa3, unknown }

/// WiFi standard generation derived from Android's `ScanResult.wifiStandard`.
enum WifiStandard { legacy, n, ac, ax, be, unknown }

WifiStandard wifiStandardFromInt(int? value) {
  switch (value) {
    case 4:
      return WifiStandard.n; // 802.11n (Wi-Fi 4)
    case 5:
      return WifiStandard.ac; // 802.11ac (Wi-Fi 5)
    case 6:
      return WifiStandard.ax; // 802.11ax (Wi-Fi 6)
    case 7:
      return WifiStandard.be; // 802.11be (Wi-Fi 7)
    case 1:
    case 2:
    case 3:
      return WifiStandard.legacy; // 802.11a/b/g
    default:
      return WifiStandard.unknown;
  }
}

String wifiStandardLabel(WifiStandard std) {
  switch (std) {
    case WifiStandard.legacy:
      return 'Wi-Fi (legacy)';
    case WifiStandard.n:
      return 'Wi-Fi 4 (802.11n)';
    case WifiStandard.ac:
      return 'Wi-Fi 5 (802.11ac)';
    case WifiStandard.ax:
      return 'Wi-Fi 6 (802.11ax)';
    case WifiStandard.be:
      return 'Wi-Fi 7 (802.11be)';
    case WifiStandard.unknown:
      return 'Unknown';
  }
}

class WifiNetwork extends Equatable {
  final String ssid;
  final String bssid;
  final int signalStrength; // in dBm
  final int channel;
  final int frequency; // in MHz
  final SecurityType security;
  final String vendor; // OUI lookup result
  final bool isHidden;

  // Extended fields from Android ScanResult (available via method channel)
  final int? channelWidthMhz; // 20, 40, 80, 160, or 320
  final WifiStandard? wifiStandard; // Wi-Fi generation
  final bool? hasWps; // WPS enabled flag
  final bool? hasPmf; // Protected Management Frames flag
  final String? rawCapabilities; // e.g. "[WPA2-PSK-CCMP][WPS][ESS]"
  final String? apMldMac; // Wi-Fi 7 multi-link MAC (API 33+)

  const WifiNetwork({
    required this.ssid,
    required this.bssid,
    required this.signalStrength,
    required this.channel,
    required this.frequency,
    required this.security,
    this.vendor = 'Unknown',
    this.isHidden = false,
    this.channelWidthMhz,
    this.wifiStandard,
    this.hasWps,
    this.hasPmf,
    this.rawCapabilities,
    this.apMldMac,
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
    int? channelWidthMhz,
    WifiStandard? wifiStandard,
    bool? hasWps,
    bool? hasPmf,
    String? rawCapabilities,
    String? apMldMac,
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
      channelWidthMhz: channelWidthMhz ?? this.channelWidthMhz,
      wifiStandard: wifiStandard ?? this.wifiStandard,
      hasWps: hasWps ?? this.hasWps,
      hasPmf: hasPmf ?? this.hasPmf,
      rawCapabilities: rawCapabilities ?? this.rawCapabilities,
      apMldMac: apMldMac ?? this.apMldMac,
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
    channelWidthMhz,
    wifiStandard,
    hasWps,
    hasPmf,
    rawCapabilities,
    apMldMac,
  ];
}
