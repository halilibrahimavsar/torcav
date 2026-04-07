import 'package:equatable/equatable.dart';

import 'wall_segment.dart';

/// A compiled floor plan containing wall geometry and dimensions.
class FloorPlan extends Equatable {
  const FloorPlan({
    required this.walls,
    required this.widthMeters,
    required this.heightMeters,
    this.pixelsPerMeter = 40.0,
  });

  /// Detected wall segments in metric units.
  final List<WallSegment> walls;

  /// Maximum horizontal extent of the plan in meters.
  final double widthMeters;

  /// Maximum vertical extent of the plan in meters.
  final double heightMeters;

  /// Scale factor for painting to canvas.
  final double pixelsPerMeter;

  FloorPlan copyWith({
    List<WallSegment>? walls,
    double? widthMeters,
    double? heightMeters,
    double? pixelsPerMeter,
  }) =>
      FloorPlan(
        walls: walls ?? this.walls,
        widthMeters: widthMeters ?? this.widthMeters,
        heightMeters: heightMeters ?? this.heightMeters,
        pixelsPerMeter: pixelsPerMeter ?? this.pixelsPerMeter,
      );

  @override
  List<Object?> get props => [walls, widthMeters, heightMeters, pixelsPerMeter];
}
