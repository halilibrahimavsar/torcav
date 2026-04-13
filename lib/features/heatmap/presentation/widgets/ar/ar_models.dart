import 'package:flutter/material.dart';

import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';

/// Data slice for the AR label overlay to minimize rebuilds.
class LabelOverlaySlice {
  const LabelOverlaySlice({
    required this.points,
    required this.camX,
    required this.camY,
    required this.heading,
    required this.headingOffset,
    required this.hasOrigin,
  });

  final List<HeatmapPoint> points;
  final double camX;
  final double camY;
  final double heading;
  final double headingOffset;
  final bool hasOrigin;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelOverlaySlice &&
          runtimeType == other.runtimeType &&
          points == other.points &&
          camX == other.camX &&
          camY == other.camY &&
          heading == other.heading &&
          headingOffset == other.headingOffset &&
          hasOrigin == other.hasOrigin;

  @override
  int get hashCode =>
      points.hashCode ^
      camX.hashCode ^
      camY.hashCode ^
      heading.hashCode ^
      headingOffset.hashCode ^
      hasOrigin.hashCode;
}

/// Result of a 3D to 2D screen-space projection.
class ProjectionResult {
  const ProjectionResult(this.offset, this.depth);
  final Offset offset;
  final double depth;
}
