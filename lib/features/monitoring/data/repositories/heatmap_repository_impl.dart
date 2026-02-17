import 'package:injectable/injectable.dart';

import '../../domain/entities/heatmap_point.dart';
import '../../domain/repositories/heatmap_repository.dart';

@LazySingleton(as: HeatmapRepository)
class HeatmapRepositoryImpl implements HeatmapRepository {
  final List<HeatmapPoint> _points = [];

  @override
  Future<void> addPoint(HeatmapPoint point) async {
    _points.add(point);
  }

  @override
  Future<List<HeatmapPoint>> getPointsFor(String bssid) async {
    return _points
        .where((point) => point.bssid.toUpperCase() == bssid.toUpperCase())
        .toList(growable: false);
  }
}
