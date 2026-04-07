import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/heatmap_session.dart';
import '../../domain/repositories/heatmap_repository.dart';
import '../datasources/heatmap_local_data_source.dart';

@LazySingleton(as: HeatmapRepository)
class HeatmapRepositoryImpl implements HeatmapRepository {
  const HeatmapRepositoryImpl(this._dataSource);

  final HeatmapLocalDataSource _dataSource;

  @override
  Future<Either<Failure, List<HeatmapSession>>> getSessions() async {
    try {
      final sessions = await _dataSource.getSessions();
      return Right(sessions);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSession(HeatmapSession session) async {
    try {
      await _dataSource.saveSession(session);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSession(String sessionId) async {
    try {
      await _dataSource.deleteSession(sessionId);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
