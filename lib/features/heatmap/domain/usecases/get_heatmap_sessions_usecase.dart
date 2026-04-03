import 'package:injectable/injectable.dart';

import '../entities/heatmap_session.dart';
import '../repositories/heatmap_repository.dart';

/// Returns all stored heatmap sessions, newest first.
@lazySingleton
class GetHeatmapSessionsUsecase {
  const GetHeatmapSessionsUsecase(this._repository);

  final HeatmapRepository _repository;

  Future<List<HeatmapSession>> call() => _repository.getSessions();
}
