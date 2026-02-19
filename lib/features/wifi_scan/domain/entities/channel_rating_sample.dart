import 'package:equatable/equatable.dart';

/// A single sample of a channel rating at a specific point in time.
class ChannelRatingSample extends Equatable {
  final int? id;
  final int channel;
  final double rating;
  final DateTime timestamp;

  const ChannelRatingSample({
    this.id,
    required this.channel,
    required this.rating,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, channel, rating, timestamp];

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'channel': channel,
      'rating': rating,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ChannelRatingSample.fromMap(Map<String, dynamic> map) {
    return ChannelRatingSample(
      id: map['id'] as int?,
      channel: map['channel'] as int,
      rating: map['rating'] as double,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}
