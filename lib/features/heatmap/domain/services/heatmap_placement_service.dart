import 'package:injectable/injectable.dart';

import '../entities/heatmap_point.dart';
import '../entities/placement_suggestion.dart';

/// Turns a heatmap survey into a single, actionable router-placement
/// recommendation. Designed to give the user *one* thing to try, not a
/// dump of statistics.
///
/// Heuristic:
///   1. Mark every point with RSSI ≤ [_deadZoneDbm] as a dead zone.
///   2. If dead zones are < 5% of the survey → coverage is fine.
///   3. If dead zones cluster (>60% within a single 4 m radius), suggest
///      relocating the router toward that cluster's centre of mass.
///   4. Otherwise the dead zones are scattered → a single move won't
///      help; recommend adding a mesh node.
@lazySingleton
class HeatmapPlacementService {
  const HeatmapPlacementService();

  static const int _deadZoneDbm = -75;
  static const double _clusterRadiusMeters = 4.0;
  static const double _smallProblemFraction = 0.05;
  static const double _clusterDensityThreshold = 0.6;

  PlacementSuggestion analyze(List<HeatmapPoint> points) {
    final total = points.length;
    if (total == 0) {
      return const PlacementSuggestion(
        advice: PlacementAdvice.noActionNeeded,
        deadZoneCount: 0,
        totalPoints: 0,
        headlineKey: 'placementNoSurvey',
      );
    }

    final deadZones = points.where((p) => p.rssi <= _deadZoneDbm).toList();
    if (deadZones.length / total < _smallProblemFraction) {
      return PlacementSuggestion(
        advice: PlacementAdvice.noActionNeeded,
        deadZoneCount: deadZones.length,
        totalPoints: total,
        headlineKey: 'placementGoodCoverage',
        suggestionKey: 'placementGoodCoverageDetail',
      );
    }

    final center = _centroid(deadZones);
    final clusterCount =
        deadZones
            .where((p) => _distance(p, center) <= _clusterRadiusMeters)
            .length;
    final clusterDensity = clusterCount / deadZones.length;

    if (clusterDensity >= _clusterDensityThreshold) {
      return PlacementSuggestion(
        advice: PlacementAdvice.relocateRouter,
        deadZoneCount: deadZones.length,
        totalPoints: total,
        deadZoneCenter: (x: center.x, y: center.y),
        headlineKey: 'placementRelocate',
        suggestionKey: 'placementRelocateDetail',
      );
    }

    return PlacementSuggestion(
      advice: PlacementAdvice.addMeshNode,
      deadZoneCount: deadZones.length,
      totalPoints: total,
      deadZoneCenter: (x: center.x, y: center.y),
      headlineKey: 'placementAddMesh',
      suggestionKey: 'placementAddMeshDetail',
    );
  }

  ({double x, double y}) _centroid(List<HeatmapPoint> points) {
    var sumX = 0.0;
    var sumY = 0.0;
    for (final p in points) {
      sumX += p.floorX;
      sumY += p.floorY;
    }
    return (x: sumX / points.length, y: sumY / points.length);
  }

  double _distance(HeatmapPoint p, ({double x, double y}) c) {
    final dx = p.floorX - c.x;
    final dy = p.floorY - c.y;
    return _sqrt(dx * dx + dy * dy);
  }

  double _sqrt(double v) {
    if (v <= 0) return 0;
    var x = v;
    for (var i = 0; i < 12; i++) {
      x = (x + v / x) / 2;
    }
    return x;
  }
}
