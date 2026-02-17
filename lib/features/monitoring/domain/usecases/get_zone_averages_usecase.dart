import 'package:injectable/injectable.dart';

import '../repositories/heatmap_repository.dart';

@lazySingleton
class GetZoneAveragesUseCase {
  final HeatmapRepository _repository;

  GetZoneAveragesUseCase(this._repository);

  Future<Map<String, double>> call(String bssid) async {
    final points = await _repository.getPointsFor(bssid);
    final zones = <String, List<int>>{};

    for (final point in points) {
      zones.putIfAbsent(point.zoneTag, () => []).add(point.signalDbm);
    }

    return zones.map((zone, values) {
      final avg = values.reduce((a, b) => a + b) / values.length;
      return MapEntry(zone, avg);
    });
  }
}
