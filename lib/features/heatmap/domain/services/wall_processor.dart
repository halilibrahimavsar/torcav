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
    // BUG-11: Require BOTH proximity AND similar angle to qualify as duplicate.
    // Previously only center-distance was checked, which could suppress two real
    // parallel walls (e.g. doorframe edges) whose centres happen to be <0.4 m apart.
    return walls.any((w) {
      if (_segCenterDist(w, wall) >= _duplicateDistanceTolerance) return false;
      final dx1 = w.x2 - w.x1, dy1 = w.y2 - w.y1;
      final dx2 = wall.x2 - wall.x1, dy2 = wall.y2 - wall.y1;
      final len1 = math.sqrt(dx1 * dx1 + dy1 * dy1);
      final len2 = math.sqrt(dx2 * dx2 + dy2 * dy2);
      if (len1 < 0.01 || len2 < 0.01) return true;
      final dot = (dx1 * dx2 + dy1 * dy2) / (len1 * len2);
      // Only treat as duplicate when angle difference is also within tolerance.
      return dot.abs() >= _angleToleranceDot;
    });
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
    // BUG-10: The previous approach sorted endpoints by X or Y axis depending on
    // which was dominant. For near-diagonal walls (dx ≈ dy) the axis choice was
    // unstable, causing endpoint order to flip between frames.
    // Fix: project all four endpoints onto segment a's direction vector and sort
    // by scalar projection, which is unambiguous regardless of orientation.
    final dx = a.x2 - a.x1;
    final dy = a.y2 - a.y1;
    final len = math.sqrt(dx * dx + dy * dy);
    // Normalised direction of segment a (safe — caller guarantees len > 0.1).
    final ux = dx / len;
    final uy = dy / len;

    // Scalar projection of each endpoint onto the direction vector.
    double proj(double x, double y) => (x - a.x1) * ux + (y - a.y1) * uy;

    final projs = [
      (t: proj(a.x1, a.y1), x: a.x1, y: a.y1),
      (t: proj(a.x2, a.y2), x: a.x2, y: a.y2),
      (t: proj(b.x1, b.y1), x: b.x1, y: b.y1),
      (t: proj(b.x2, b.y2), x: b.x2, y: b.y2),
    ]..sort((p1, p2) => p1.t.compareTo(p2.t));

    return WallSegment(
      x1: projs.first.x,
      y1: projs.first.y,
      x2: projs.last.x,
      y2: projs.last.y,
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
