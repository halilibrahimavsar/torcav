import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../datasources/channel_rating_local_data_source.dart';
import '../../domain/entities/channel_rating_sample.dart';
import '../../domain/repositories/channel_rating_repository.dart';

@LazySingleton(as: ChannelRatingRepository)
class ChannelRatingRepositoryImpl implements ChannelRatingRepository {
  final ChannelRatingLocalDataSource _localDataSource;

  ChannelRatingRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, void>> saveRatings(
    List<ChannelRatingSample> samples,
  ) async {
    try {
      await _localDataSource.saveRatingSamples(samples);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChannelRatingSample>>> getHistory({
    Duration? limit,
  }) async {
    try {
      final samples = await _localDataSource.getHistory(limit: limit);
      return Right(samples);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
