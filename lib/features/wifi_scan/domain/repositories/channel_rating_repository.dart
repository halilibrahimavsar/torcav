import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/channel_rating_sample.dart';

abstract class ChannelRatingRepository {
  Future<Either<Failure, void>> saveRatings(List<ChannelRatingSample> samples);
  Future<Either<Failure, List<ChannelRatingSample>>> getHistory({
    Duration? limit,
  });
}
