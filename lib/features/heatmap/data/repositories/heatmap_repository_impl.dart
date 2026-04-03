import 'package:injectable/injectable.dart';

import '../../domain/entities/heatmap_session.dart';
import '../../domain/repositories/heatmap_repository.dart';
import '../datasources/heatmap_local_data_source.dart';

@LazySingleton(as: HeatmapRepository)
class HeatmapRepositoryImpl implements HeatmapRepository {
  const HeatmapRepositoryImpl(this._dataSource);

  final HeatmapLocalDataSource _dataSource;

  @override
  Future<List<HeatmapSession>> getSessions() => _dataSource.getSessions();

  @override
  Future<void> saveSession(HeatmapSession session) =>
      _dataSource.saveSession(session);

  @override
  Future<void> deleteSession(String sessionId) =>
      _dataSource.deleteSession(sessionId);
}
