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
        headline:
            'Walk around your space with the heatmap survey active so we '
            'can suggest where to place your router.',
      );
    }

    final deadZones = points.where((p) => p.rssi <= _deadZoneDbm).toList();
    if (deadZones.length / total < _smallProblemFraction) {
      return PlacementSuggestion(
        advice: PlacementAdvice.noActionNeeded,
        deadZoneCount: deadZones.length,
        totalPoints: total,
        headline:
            'Coverage looks good — fewer than 5% of the area you walked '
            'showed weak signal.',
        suggestion:
            'No router move needed. Re-run the survey if you change the '
            'router\'s position or add new walls / furniture.',
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
        headline:
            'Most weak-signal spots cluster together — try moving the '
            'router closer to that area.',
        suggestion:
            'Aim for a position roughly halfway between where the router '
            'is now and the centre of the highlighted dead zone, away '
            'from large metal objects (TVs, microwaves, refrigerators).',
      );
    }

    return PlacementSuggestion(
      advice: PlacementAdvice.addMeshNode,
      deadZoneCount: deadZones.length,
      totalPoints: total,
      deadZoneCenter: (x: center.x, y: center.y),
      headline:
          'Weak spots are spread across multiple rooms — a single router '
          'move won\'t solve it.',
      suggestion:
          'Add a mesh node (Eero, Google Nest, TP-Link Deco, etc.) at '
          'roughly the dead zone centre, in line of sight of your '
          'existing router. Two-AP coverage usually fixes scattered '
          'weak zones in a way no relocation can.',
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
