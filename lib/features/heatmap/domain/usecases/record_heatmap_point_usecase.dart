import 'package:injectable/injectable.dart';

import '../entities/heatmap_point.dart';
import '../entities/heatmap_session.dart';
import '../repositories/heatmap_repository.dart';

/// Appends a new [HeatmapPoint] to an existing session.
///
/// If the session does not exist yet, a new one is created with [sessionName].
@lazySingleton
class RecordHeatmapPointUsecase {
  const RecordHeatmapPointUsecase(this._repository);

  final HeatmapRepository _repository;

  Future<HeatmapSession> call({
    required String sessionId,
    required String sessionName,
    required HeatmapPoint point,
  }) async {
    final sessions = await _repository.getSessions();
    final existing = sessions.where((s) => s.id == sessionId).firstOrNull;

    final session =
        existing ??
        HeatmapSession(
          id: sessionId,
          name: sessionName,
          points: const [],
          createdAt: DateTime.now(),
        );

    final updated = session.copyWith(
      points: [...session.points, point],
    );
    await _repository.saveSession(updated);
    return updated;
  }
}
