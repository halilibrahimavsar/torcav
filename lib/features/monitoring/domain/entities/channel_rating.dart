import 'package:equatable/equatable.dart';

class ChannelRating extends Equatable {
  final int channel;
  final int frequency;
  final double rating; // 0.0 to 10.0 (10 is best)
  final int networkCount;
  final String recommendation;

  const ChannelRating({
    required this.channel,
    required this.frequency,
    required this.rating,
    required this.networkCount,
    required this.recommendation,
  });

  @override
  List<Object?> get props => [
    channel,
    frequency,
    rating,
    networkCount,
    recommendation,
  ];
}
