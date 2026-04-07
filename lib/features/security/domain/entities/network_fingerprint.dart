import 'package:equatable/equatable.dart';

import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

class NetworkFingerprint extends Equatable {
  const NetworkFingerprint({
    required this.ssid,
    required this.bssid,
    required this.security,
    required this.vendor,
    required this.isHidden,
    required this.channel,
    required this.frequency,
    required this.bandLabel,
    this.channelWidthMhz,
    this.wifiStandard,
    this.hasWps,
    this.hasPmf,
    this.apMldMac,
  });

  factory NetworkFingerprint.fromWifiNetwork(WifiNetwork network) {
    return NetworkFingerprint(
      ssid: network.ssid,
      bssid: network.bssid,
      security: network.security.name,
      vendor: network.vendor,
      isHidden: network.isHidden,
      channel: network.channel,
      frequency: network.frequency,
      bandLabel: _bandLabelFor(network.frequency),
      channelWidthMhz: network.channelWidthMhz,
      wifiStandard: network.wifiStandard?.name,
      hasWps: network.hasWps,
      hasPmf: network.hasPmf,
      apMldMac: network.apMldMac,
    );
  }

  factory NetworkFingerprint.fromJson(Map<String, dynamic> json) {
    return NetworkFingerprint(
      ssid: json['ssid'] as String? ?? '',
      bssid: json['bssid'] as String? ?? '',
      security: json['security'] as String? ?? SecurityType.unknown.name,
      vendor: json['vendor'] as String? ?? 'Unknown',
      isHidden: json['isHidden'] as bool? ?? false,
      channel: json['channel'] as int? ?? 0,
      frequency: json['frequency'] as int? ?? 0,
      bandLabel: json['bandLabel'] as String? ?? 'Unknown',
      channelWidthMhz: json['channelWidthMhz'] as int?,
      wifiStandard: json['wifiStandard'] as String?,
      hasWps: json['hasWps'] as bool?,
      hasPmf: json['hasPmf'] as bool?,
      apMldMac: json['apMldMac'] as String?,
    );
  }

  final String ssid;
  final String bssid;
  final String security;
  final String vendor;
  final bool isHidden;
  final int channel;
  final int frequency;
  final String bandLabel;
  final int? channelWidthMhz;
  final String? wifiStandard;
  final bool? hasWps;
  final bool? hasPmf;
  final String? apMldMac;

  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'bssid': bssid,
      'security': security,
      'vendor': vendor,
      'isHidden': isHidden,
      'channel': channel,
      'frequency': frequency,
      'bandLabel': bandLabel,
      'channelWidthMhz': channelWidthMhz,
      'wifiStandard': wifiStandard,
      'hasWps': hasWps,
      'hasPmf': hasPmf,
      'apMldMac': apMldMac,
    };
  }

  List<String> driftAgainst(NetworkFingerprint baseline) {
    final changes = <String>[];

    void addIfChanged<T>(String label, T current, T previous) {
      if (current != previous) {
        changes.add(label);
      }
    }

    addIfChanged('BSSID', bssid, baseline.bssid);
    addIfChanged('Security', security, baseline.security);
    addIfChanged('Vendor', vendor, baseline.vendor);
    addIfChanged('Hidden SSID', isHidden, baseline.isHidden);
    addIfChanged('Channel', channel, baseline.channel);
    addIfChanged('Frequency', frequency, baseline.frequency);
    addIfChanged('Band', bandLabel, baseline.bandLabel);
    addIfChanged(
      'Channel Width',
      channelWidthMhz ?? -1,
      baseline.channelWidthMhz ?? -1,
    );
    addIfChanged(
      'Wi-Fi Standard',
      wifiStandard ?? '',
      baseline.wifiStandard ?? '',
    );
    addIfChanged('WPS', hasWps ?? false, baseline.hasWps ?? false);
    addIfChanged('PMF', hasPmf ?? false, baseline.hasPmf ?? false);
    addIfChanged('AP MLD MAC', apMldMac ?? '', baseline.apMldMac ?? '');

    return changes;
  }

  static String _bandLabelFor(int frequency) {
    if (frequency >= 5925) {
      return '6 GHz';
    }
    if (frequency >= 5000) {
      return '5 GHz';
    }
    if (frequency > 0) {
      return '2.4 GHz';
    }
    return 'Unknown';
  }

  @override
  List<Object?> get props => [
    ssid,
    bssid,
    security,
    vendor,
    isHidden,
    channel,
    frequency,
    bandLabel,
    channelWidthMhz,
    wifiStandard,
    hasWps,
    hasPmf,
    apMldMac,
  ];
}
