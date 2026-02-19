import 'package:equatable/equatable.dart';

/// Represents the quality rating of a Wi-Fi channel.
class ChannelRating extends Equatable {
  final int channel;
  final int frequency;

  /// Quality score from 0.0 (worst) to 10.0 (perfect).
  final double rating;

  /// Number of APs detected on or near this channel.
  final int networkCount;

  /// Human-readable recommendation (e.g., 'Excellent', 'Congested').
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
