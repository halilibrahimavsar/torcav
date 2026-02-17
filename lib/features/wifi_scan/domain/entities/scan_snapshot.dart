import 'package:equatable/equatable.dart';

import 'band_analysis_stat.dart';
import 'channel_occupancy_stat.dart';
import 'wifi_network.dart';
import 'wifi_observation.dart';

class ScanSnapshot extends Equatable {
  final DateTime timestamp;
  final String backendUsed;
  final String interfaceName;
  final List<WifiObservation> networks;
  final List<ChannelOccupancyStat> channelStats;
  final List<BandAnalysisStat> bandStats;

  const ScanSnapshot({
    required this.timestamp,
    required this.backendUsed,
    required this.interfaceName,
    required this.networks,
    required this.channelStats,
    required this.bandStats,
  });

  List<WifiNetwork> toLegacyNetworks() {
    return networks.map((entry) => entry.toWifiNetwork()).toList();
  }

  @override
  List<Object?> get props => [
    timestamp,
    backendUsed,
    interfaceName,
    networks,
    channelStats,
    bandStats,
  ];
}
