import 'package:injectable/injectable.dart';

import '../entities/heatmap_point.dart';
import '../repositories/heatmap_repository.dart';

@lazySingleton
class LogHeatmapPointUseCase {
  final HeatmapRepository _repository;

  LogHeatmapPointUseCase(this._repository);

  Future<void> call({
    required String bssid,
    required String zoneTag,
    required int signalDbm,
  }) {
    return _repository.addPoint(
      HeatmapPoint(
        timestamp: DateTime.now(),
        bssid: bssid,
        zoneTag: zoneTag,
        signalDbm: signalDbm,
      ),
    );
  }
}
