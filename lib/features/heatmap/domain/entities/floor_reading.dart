import 'package:equatable/equatable.dart';

/// A barometer-based floor detection reading.
///
/// [floorIndex] is relative to the baseline pressure captured at scan start
/// (0 = ground floor where scanning began, positive = higher floors).
class FloorReading extends Equatable {
  const FloorReading({required this.floorIndex, required this.pressureHpa});

  /// Floor index relative to scan start (0 = starting floor).
  final int floorIndex;

  /// Raw pressure reading in hectopascals.
  final double pressureHpa;

  @override
  List<Object?> get props => [floorIndex, pressureHpa];
}
