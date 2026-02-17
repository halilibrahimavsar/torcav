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
  ];
}
