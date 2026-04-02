import 'dart:math';

import 'package:equatable/equatable.dart';

import 'wifi_network.dart';

class WifiObservation extends Equatable {
  final String ssid;
  final String bssid;
  final List<int> signalDbmSamples;
  final int avgSignalDbm;
  final double signalStdDev;
  final int channel;
  final int frequency;
  final SecurityType security;
  final String vendor;
  final bool isHidden;
  final int seenCount;

  // Extended fields from Android ScanResult (null when not available)
  final int? channelWidthMhz;
  final WifiStandard? wifiStandard;
  final bool? hasWps;
  final bool? hasPmf;
  final String? rawCapabilities;
  final String? apMldMac;

  const WifiObservation({
    required this.ssid,
    required this.bssid,
    required this.signalDbmSamples,
    required this.avgSignalDbm,
    required this.signalStdDev,
    required this.channel,
    required this.frequency,
    required this.security,
    required this.vendor,
    required this.isHidden,
    required this.seenCount,
    this.channelWidthMhz,
    this.wifiStandard,
    this.hasWps,
    this.hasPmf,
    this.rawCapabilities,
    this.apMldMac,
  });

  factory WifiObservation.fromSingleNetwork(
    WifiNetwork network, {
    String? vendor,
  }) {
    return WifiObservation(
      ssid: network.ssid,
      bssid: network.bssid,
      signalDbmSamples: [network.signalStrength],
      avgSignalDbm: network.signalStrength,
      signalStdDev: 0,
      channel: network.channel,
      frequency: network.frequency,
      security: network.security,
      vendor: vendor ?? network.vendor,
      isHidden: network.isHidden,
      seenCount: 1,
      channelWidthMhz: network.channelWidthMhz,
      wifiStandard: network.wifiStandard,
      hasWps: network.hasWps,
      hasPmf: network.hasPmf,
      rawCapabilities: network.rawCapabilities,
      apMldMac: network.apMldMac,
    );
  }

  factory WifiObservation.fromSamples({
    required String ssid,
    required String bssid,
    required List<int> samples,
    required int channel,
    required int frequency,
    required SecurityType security,
    required String vendor,
    required bool isHidden,
    required int seenCount,
    int? channelWidthMhz,
    WifiStandard? wifiStandard,
    bool? hasWps,
    bool? hasPmf,
    String? rawCapabilities,
    String? apMldMac,
  }) {
    final safeSamples = samples.isEmpty ? const <int>[-100] : samples;
    final average =
        safeSamples.reduce((a, b) => a + b) / safeSamples.length.toDouble();
    final variance =
        safeSamples
            .map((sample) => pow(sample - average, 2))
            .fold<double>(0, (a, b) => a + b) /
        safeSamples.length.toDouble();

    return WifiObservation(
      ssid: ssid,
      bssid: bssid,
      signalDbmSamples: List.unmodifiable(safeSamples),
      avgSignalDbm: average.round(),
      signalStdDev: sqrt(variance),
      channel: channel,
      frequency: frequency,
      security: security,
      vendor: vendor,
      isHidden: isHidden,
      seenCount: seenCount,
      channelWidthMhz: channelWidthMhz,
      wifiStandard: wifiStandard,
      hasWps: hasWps,
      hasPmf: hasPmf,
      rawCapabilities: rawCapabilities,
      apMldMac: apMldMac,
    );
  }

  WifiNetwork toWifiNetwork() {
    return WifiNetwork(
      ssid: ssid,
      bssid: bssid,
      signalStrength: avgSignalDbm,
      channel: channel,
      frequency: frequency,
      security: security,
      vendor: vendor,
      isHidden: isHidden,
      channelWidthMhz: channelWidthMhz,
      wifiStandard: wifiStandard,
      hasWps: hasWps,
      hasPmf: hasPmf,
      rawCapabilities: rawCapabilities,
      apMldMac: apMldMac,
    );
  }

  @override
  List<Object?> get props => [
    ssid,
    bssid,
    signalDbmSamples,
    avgSignalDbm,
    signalStdDev,
    channel,
    frequency,
    security,
    vendor,
    isHidden,
    seenCount,
    channelWidthMhz,
    wifiStandard,
    hasWps,
    hasPmf,
    rawCapabilities,
    apMldMac,
  ];
}
