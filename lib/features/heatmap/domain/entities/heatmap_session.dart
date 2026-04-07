import 'package:equatable/equatable.dart';

import 'floor_plan.dart';
import 'heatmap_point.dart';

/// An ordered collection of [HeatmapPoint]s captured during a single walk-through.
class HeatmapSession extends Equatable {
  const HeatmapSession({
    required this.id,
    required this.name,
    required this.points,
    required this.createdAt,
    this.floorPlan,
  });

  final String id;

  /// User-given label for this measurement session, e.g. "Living room survey".
  final String name;

  final List<HeatmapPoint> points;

  final DateTime createdAt;

  /// Optional floor plan synthesized from room geometry.
  final FloorPlan? floorPlan;

  /// Signal strength range across all points, used for colour-scale normalisation.
  int get minRssi =>
      points.isEmpty ? -90 : points.map((p) => p.rssi).reduce((a, b) => a < b ? a : b);
  int get maxRssi =>
      points.isEmpty ? -30 : points.map((p) => p.rssi).reduce((a, b) => a > b ? a : b);

  HeatmapSession copyWith({
    String? id,
    String? name,
    List<HeatmapPoint>? points,
    DateTime? createdAt,
    FloorPlan? floorPlan,
  }) =>
      HeatmapSession(
        id: id ?? this.id,
        name: name ?? this.name,
        points: points ?? this.points,
        createdAt: createdAt ?? this.createdAt,
        floorPlan: floorPlan ?? this.floorPlan,
      );

  @override
  List<Object?> get props => [id, name, points, createdAt, floorPlan];
}
