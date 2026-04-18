import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/domain/repositories/heatmap_repository.dart';

/// Appends a new [HeatmapPoint] to an existing session.
///
/// If the session does not exist yet, a new one is created with [sessionName].
@lazySingleton
class RecordHeatmapPointUsecase {
  const RecordHeatmapPointUsecase(this._repository);

  final HeatmapRepository _repository;

  Future<Either<Failure, HeatmapSession>> call({
    required String sessionId,
    required String sessionName,
    required HeatmapPoint point,
  }) async {
    final sessionsResult = await _repository.getSessions();

    return sessionsResult.fold((failure) => Left(failure), (sessions) async {
      final existing =
          sessions.isEmpty
              ? null
              : sessions.firstWhere(
                (s) => s.id == sessionId,
                orElse:
                    () => HeatmapSession(
                      id: sessionId,
                      name: sessionName,
                      points: const [],
                      createdAt: DateTime.now(),
                    ),
              );

      final session =
          existing ??
          HeatmapSession(
            id: sessionId,
            name: sessionName,
            points: const [],
            createdAt: DateTime.now(),
          );

      final updated = session.copyWith(points: [...session.points, point]);

      final saveResult = await _repository.saveSession(updated);
      return saveResult.fold((f) => Left(f), (_) => Right(updated));
    });
  }
}
