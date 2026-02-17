import 'package:equatable/equatable.dart';

class ChannelOccupancyStat extends Equatable {
  final int channel;
  final int frequency;
  final int networkCount;
  final int avgSignalDbm;
  final double congestionScore;
  final String recommendation;

  const ChannelOccupancyStat({
    required this.channel,
    required this.frequency,
    required this.networkCount,
    required this.avgSignalDbm,
    required this.congestionScore,
    required this.recommendation,
  });

  @override
  List<Object?> get props => [
    channel,
    frequency,
    networkCount,
    avgSignalDbm,
    congestionScore,
    recommendation,
  ];
}
