import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/channel_rating_sample.dart';

abstract class ChannelRatingRepository {
  Future<Either<Failure, void>> saveRatings(List<ChannelRatingSample> samples);
  Future<Either<Failure, List<ChannelRatingSample>>> getHistory({
    Duration? limit,
  });
  Future<Either<Failure, void>> clearHistory();
}
