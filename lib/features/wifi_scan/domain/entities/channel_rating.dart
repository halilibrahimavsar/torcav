import 'package:equatable/equatable.dart';

enum ChannelQuality { excellent, veryGood, good, fair, congested }

/// Represents the quality rating of a Wi-Fi channel.
class ChannelRating extends Equatable {
  final int channel;
  final int frequency;

  /// Quality score from 0.0 (worst) to 10.0 (perfect).
  final double rating;

  /// Number of APs detected on or near this channel.
  final int networkCount;

  /// Enum representation of quality for localization.
  final ChannelQuality quality;

  const ChannelRating({
    required this.channel,
    required this.frequency,
    required this.rating,
    required this.networkCount,
    required this.quality,
  });

  @override
  List<Object?> get props => [
    channel,
    frequency,
    rating,
    networkCount,
    quality,
  ];
}
