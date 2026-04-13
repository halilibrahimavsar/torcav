import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/domain/repositories/heatmap_repository.dart';

/// Returns all stored heatmap sessions, newest first.
@lazySingleton
class GetHeatmapSessionsUsecase {
  const GetHeatmapSessionsUsecase(this._repository);

  final HeatmapRepository _repository;

  Future<Either<Failure, List<HeatmapSession>>> call() =>
      _repository.getSessions();
}
