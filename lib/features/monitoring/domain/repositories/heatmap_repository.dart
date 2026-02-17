import '../entities/heatmap_point.dart';

abstract class HeatmapRepository {
  Future<void> addPoint(HeatmapPoint point);
  Future<List<HeatmapPoint>> getPointsFor(String bssid);
}
