import 'package:equatable/equatable.dart';

/// Verdict the placement engine produces after looking at a survey.
enum PlacementAdvice {
  /// Coverage is good across all sampled points. No action needed.
  noActionNeeded,

  /// One or more dead zones exist but are isolated. Move the router
  /// closer to the centre of mass of the weak area.
  relocateRouter,

  /// Dead zones span multiple rooms / a large fraction of the survey.
  /// A second AP / mesh node is the only realistic fix.
  addMeshNode,
}

/// Output of [HeatmapPlacementService]. Carries the advice plus the data
/// the UI needs to point the user at the problem area.
class PlacementSuggestion extends Equatable {
  final PlacementAdvice advice;

  /// Number of "dead zone" points detected (RSSI ≤ -75 dBm).
  final int deadZoneCount;

  /// Total measurement points in the session.
  final int totalPoints;

  /// Approximate centre of mass of the dead zone in metric coordinates,
  /// or null when no dead zones exist.
  final ({double x, double y})? deadZoneCenter;

  /// Plain-language summary, ready to render in the heatmap page.
  final String headline;

  /// Optional follow-up sentence with a concrete suggestion.
  final String? suggestion;

  const PlacementSuggestion({
    required this.advice,
    required this.deadZoneCount,
    required this.totalPoints,
    required this.headline,
    this.deadZoneCenter,
    this.suggestion,
  });

  @override
  List<Object?> get props => [
    advice,
    deadZoneCount,
    totalPoints,
    deadZoneCenter,
    headline,
    suggestion,
  ];
}
