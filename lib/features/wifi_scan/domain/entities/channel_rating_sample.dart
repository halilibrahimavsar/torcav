import 'package:equatable/equatable.dart';

/// A single sample of a channel rating at a specific point in time.
class ChannelRatingSample extends Equatable {
  final int? id;
  final int channel;

  /// Center frequency in MHz. Required so that channel numbers that exist in
  /// multiple bands (e.g. CH 1 in both 2.4 GHz and 6 GHz) can be classified
  /// unambiguously by historical readers.
  final int frequency;
  final double rating;
  final DateTime timestamp;

  const ChannelRatingSample({
    this.id,
    required this.channel,
    required this.frequency,
    required this.rating,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, channel, frequency, rating, timestamp];
}
