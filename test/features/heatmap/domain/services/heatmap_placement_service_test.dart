import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/placement_suggestion.dart';
import 'package:torcav/features/heatmap/domain/services/heatmap_placement_service.dart';

void main() {
  const service = HeatmapPlacementService();

  HeatmapPoint pt(double x, double y, int rssi) =>
      HeatmapPoint(floorX: x, floorY: y, rssi: rssi, timestamp: DateTime(2025));

  test('empty survey returns guidance to walk around first', () {
    final result = service.analyze(const []);
    expect(result.advice, PlacementAdvice.noActionNeeded);
    expect(result.totalPoints, 0);
  });

  test('mostly-strong survey reports no action needed', () {
    final pts = [
      for (var i = 0; i < 50; i++) pt(i.toDouble(), 0, -50),
      pt(99, 99, -78), // single weak spot < 5%
    ];
    final result = service.analyze(pts);
    expect(result.advice, PlacementAdvice.noActionNeeded);
  });

  test('clustered dead zones recommend relocating the router', () {
    final pts = <HeatmapPoint>[
      for (var i = 0; i < 20; i++) pt(i.toDouble(), 0, -50),
      // 10 weak points all within ~3 m radius of (50, 50)
      pt(49, 49, -78),
      pt(50, 49, -80),
      pt(51, 49, -82),
      pt(49, 50, -85),
      pt(50, 50, -84),
      pt(51, 50, -82),
      pt(49, 51, -80),
      pt(50, 51, -78),
      pt(51, 51, -77),
      pt(50, 52, -76),
    ];
    final result = service.analyze(pts);
    expect(result.advice, PlacementAdvice.relocateRouter);
    expect(result.deadZoneCenter, isNotNull);
  });

  test('scattered dead zones recommend adding a mesh node', () {
    final pts = <HeatmapPoint>[
      for (var i = 0; i < 10; i++) pt(i.toDouble(), 0, -50),
      // dead zones in three different corners
      pt(0, 0, -85),
      pt(0, 1, -83),
      pt(50, 0, -82),
      pt(51, 1, -84),
      pt(50, 50, -82),
      pt(51, 51, -84),
      pt(0, 50, -82),
      pt(1, 51, -84),
    ];
    final result = service.analyze(pts);
    expect(result.advice, PlacementAdvice.addMeshNode);
  });
}
