import 'package:equatable/equatable.dart';

/// A single line segment representing a physical wall in the floor plan.
///
/// Coordinates are in meters relative to the start of the scan session (0,0).
class WallSegment extends Equatable {
  const WallSegment({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  /// Horizontal start position in meters.
  final double x1;

  /// Vertical start position in meters.
  final double y1;

  /// Horizontal end position in meters.
  final double x2;

  /// Vertical end position in meters.
  final double y2;

  WallSegment copyWith({
    double? x1,
    double? y1,
    double? x2,
    double? y2,
  }) =>
      WallSegment(
        x1: x1 ?? this.x1,
        y1: y1 ?? this.y1,
        x2: x2 ?? this.x2,
        y2: y2 ?? this.y2,
      );

  @override
  List<Object?> get props => [x1, y1, x2, y2];
}
