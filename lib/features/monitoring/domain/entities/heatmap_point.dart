import 'package:equatable/equatable.dart';

class HeatmapPoint extends Equatable {
  final DateTime timestamp;
  final String bssid;
  final String zoneTag;
  final int signalDbm;

  const HeatmapPoint({
    required this.timestamp,
    required this.bssid,
    required this.zoneTag,
    required this.signalDbm,
  });

  @override
  List<Object?> get props => [timestamp, bssid, zoneTag, signalDbm];
}
