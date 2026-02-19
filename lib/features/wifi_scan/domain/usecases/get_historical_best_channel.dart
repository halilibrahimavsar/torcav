import 'package:injectable/injectable.dart';
import '../repositories/channel_rating_repository.dart';

@lazySingleton
class GetBestHistoricalChannel {
  final ChannelRatingRepository _repository;

  GetBestHistoricalChannel(this._repository);

  Future<Map<int, double>> call({
    Duration limit = const Duration(hours: 24),
  }) async {
    final result = await _repository.getHistory(limit: limit);

    return result.fold((failure) => {}, (samples) {
      if (samples.isEmpty) return {};

      // Calculate average rating per channel
      final aggregates = <int, List<double>>{};
      for (final sample in samples) {
        aggregates.putIfAbsent(sample.channel, () => []).add(sample.rating);
      }

      final averages = aggregates.map((channel, ratings) {
        final sum = ratings.reduce((a, b) => a + b);
        return MapEntry(channel, sum / ratings.length);
      });

      return averages;
    });
  }
}
