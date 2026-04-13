import 'dart:math' as math;
import 'package:injectable/injectable.dart';
import 'package:torcav/features/heatmap/domain/entities/wall_segment.dart';

/// Service responsible for processing and clustering [WallSegment]s.
/// Implements advanced colinearity merging to prevent duplicate or messy floor plans.
@LazySingleton()
class WallProcessor {
  const WallProcessor();

  /// Constants for clustering logic
  static const double _angleToleranceDot = 0.985; // ~10 degrees
  static const double _lateralDistanceTolerance = 0.35; // meters
  static const double _proximityMergeTolerance = 1.0; // meters
  static const double _duplicateDistanceTolerance = 0.4; // meters

  /// Adds a new [wall] to the list of [existingWalls], merging if colinear.
  /// Uses an iterative merging strategy to ensure all chainable segments are joined.
  List<WallSegment> processNewWall(List<WallSegment> existingWalls, WallSegment wall) {
    // 1. Minimum length filter to reduce jitter from tiny edge flickers.
    final dx = wall.x2 - wall.x1;
    final dy = wall.y2 - wall.y1;
    if (math.sqrt(dx * dx + dy * dy) < 0.15) return existingWalls;

    var currentWalls = List<WallSegment>.from(existingWalls);
    var candidate = wall;
    bool anyMerged = false;

    // Iterative merge: Keep merging the candidate with any matching wall in the set.
    // This allows a new segment to bridge two existing segments if they are close.
    bool mergedInThisPass;
    do {
      mergedInThisPass = false;
      for (int i = 0; i < currentWalls.length; i++) {
        if (_areSegmentsColinear(currentWalls[i], candidate)) {
          candidate = _mergeSegments(currentWalls[i], candidate);
          currentWalls.removeAt(i);
          mergedInThisPass = true;
          anyMerged = true;
          break; // Restart search with newly enlarged candidate
        }
      }
    } while (mergedInThisPass);

    if (anyMerged || !_isDuplicate(currentWalls, candidate)) {
      currentWalls.add(candidate);
    }

    return currentWalls;
  }

  bool _isDuplicate(List<WallSegment> walls, WallSegment wall) {
    return walls.any((w) => _segCenterDist(w, wall) < _duplicateDistanceTolerance);
  }

  bool _areSegmentsColinear(WallSegment a, WallSegment b) {
    final dx1 = a.x2 - a.x1, dy1 = a.y2 - a.y1;
    final dx2 = b.x2 - b.x1, dy2 = b.y2 - b.y1;

    final len1 = math.sqrt(dx1 * dx1 + dy1 * dy1);
    final len2 = math.sqrt(dx2 * dx2 + dy2 * dy2);
    if (len1 < 0.1 || len2 < 0.1) return false;

    // 1. Angle check (dot product of normalized directions).
    final dot = (dx1 * dx2 + dy1 * dy2) / (len1 * len2);
    if (dot.abs() < _angleToleranceDot) return false;

    // 2. Lateral distance check (is center of B on infinite line A?).
    final bcx = (b.x1 + b.x2) / 2;
    final bcy = (b.y1 + b.y2) / 2;
    // perp distance from point (bcx, bcy) to line (a.x1, a.y1) -> (a.x2, a.y2)
    final dist = ((a.y2 - a.y1) * bcx - (a.x2 - a.x1) * bcy + a.x2 * a.y1 - a.y2 * a.x1).abs() / len1;
    if (dist > _lateralDistanceTolerance) return false;

    // 3. Proximity check (are they close or overlapping?).
    return _segCenterDist(a, b) < _proximityMergeTolerance;
  }

  WallSegment _mergeSegments(WallSegment a, WallSegment b) {
    // Return a segment that encapsulates the min/max extents of both.
    final coords = [
      [a.x1, a.y1],
      [a.x2, a.y2],
      [b.x1, b.y1],
      [b.x2, b.y2],
    ];

    // Sort by X or Y depending on orientation to find extrema.
    final dx = (a.x2 - a.x1).abs(), dy = (a.y2 - a.y1).abs();
    if (dx > dy) {
      coords.sort((p1, p2) => p1[0].compareTo(p2[0]));
    } else {
      coords.sort((p1, p2) => p1[1].compareTo(p2[1]));
    }

    final pStart = coords.first;
    final pEnd = coords.last;

    return WallSegment(
      x1: pStart[0],
      y1: pStart[1],
      x2: pEnd[0],
      y2: pEnd[1],
    );
  }

  double _segCenterDist(WallSegment a, WallSegment b) {
    final acx = (a.x1 + a.x2) / 2;
    final acy = (a.y1 + a.y2) / 2;
    final bcx = (b.x1 + b.x2) / 2;
    final bcy = (b.y1 + b.y2) / 2;
    final dx = acx - bcx, dy = acy - bcy;
    return math.sqrt(dx * dx + dy * dy);
  }
}
