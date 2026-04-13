import 'package:equatable/equatable.dart';

/// Represents a position and orientation update.
/// Pure Dart entity for the Domain layer.
class PositionUpdate extends Equatable {
  const PositionUpdate({
    required this.x,
    required this.y,
    required this.heading,
    this.isStep = false,
  });

  final double x;
  final double y;
  final double heading;
  final bool isStep;

  @override
  List<Object?> get props => [x, y, heading, isStep];
}

/// Represents a candidate for a new heatmap point.
/// Pure Dart entity for the Domain layer.
class PointCandidate extends Equatable {
  const PointCandidate({
    required this.x,
    required this.y,
    required this.heading,
    required this.isStep,
  });

  final double x;
  final double y;
  final double heading;
  final bool isStep;

  @override
  List<Object?> get props => [x, y, heading, isStep];
}
