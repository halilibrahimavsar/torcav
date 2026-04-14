import 'dart:math' as math;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/heatmap/domain/entities/floor_plan.dart';
import 'package:torcav/features/heatmap/domain/entities/wall_segment.dart';

@lazySingleton
class FinalizeFloorPlan {
  Future<Either<Failure, FloorPlan>> call(List<WallSegment> segments) async {
    if (segments.isEmpty) {
      return const Right(FloorPlan(walls: [], widthMeters: 5, heightMeters: 5));
    }

    final clustered = _clusterSegments(segments);

    double minX = 0, minY = 0, maxX = 0, maxY = 0;
    for (final s in clustered) {
      if (s.x1 < minX) minX = s.x1;
      if (s.x2 < minX) minX = s.x2;
      if (s.y1 < minY) minY = s.y1;
      if (s.y2 < minY) minY = s.y2;
      if (s.x1 > maxX) maxX = s.x1;
      if (s.x2 > maxX) maxX = s.x2;
      if (s.y1 > maxY) maxY = s.y1;
      if (s.y2 > maxY) maxY = s.y2;
    }

    return Right(FloorPlan(
      walls: clustered,
      widthMeters: (maxX - minX).clamp(1.0, 100.0),
      heightMeters: (maxY - minY).clamp(1.0, 100.0),
    ));
  }

  /// Iterative merge: runs _singlePassMerge until stable (up to 8 passes).
  /// Handles cases where A+C would merge but B sits between them in angle order,
  /// causing a single pass to miss the A–C pair.
  List<WallSegment> _clusterSegments(List<WallSegment> segments) {
    var current = List<WallSegment>.from(segments);
    var changed = true;
    var maxIter = 8;
    while (changed && maxIter-- > 0) {
      final next = _singlePassMerge(current);
      changed = next.length < current.length;
      current = next;
    }
    return current;
  }

  /// Greedy single-pass merge: sort segments by angle, then merge consecutive
  /// pairs whose angle difference and perpendicular midpoint distance are within
  /// threshold. Reduces duplicate walls accumulated across many camera frames.
  List<WallSegment> _singlePassMerge(List<WallSegment> segments) {
    double angle(WallSegment s) {
      final dx = s.x2 - s.x1;
      final dy = s.y2 - s.y1;
      return math.atan2(dy, dx) % math.pi;
    }

    // Midpoint as (x, y) pair — avoids dart:ui dependency in domain layer.
    (double, double) midpoint(WallSegment s) =>
        ((s.x1 + s.x2) / 2, (s.y1 + s.y2) / 2);

    double perpendicularDist(WallSegment a, WallSegment b) {
      final (mx, my) = midpoint(b);
      final dx = a.x2 - a.x1;
      final dy = a.y2 - a.y1;
      final len = math.sqrt(dx * dx + dy * dy);
      if (len < 0.001) {
        final (ax, ay) = midpoint(a);
        final ddx = mx - ax;
        final ddy = my - ay;
        return math.sqrt(ddx * ddx + ddy * ddy);
      }
      return ((mx - a.x1) * dy - (my - a.y1) * dx).abs() / len;
    }

    bool shouldMerge(WallSegment a, WallSegment b) {
      var angleDiff = (angle(a) - angle(b)).abs();
      if (angleDiff > math.pi / 2) angleDiff = math.pi - angleDiff;
      if (angleDiff > 0.26) return false; // ~15°
      return perpendicularDist(a, b) <= 0.5;
    }

    WallSegment merge(WallSegment a, WallSegment b) {
      // Use the direction of `a` to project all four points and take the
      // furthest extremes — this avoids the degenerate zero-length case
      // (BUG-20) that arises from the midpoint-averaging approach when
      // two coincident segments are merged.
      final dx = a.x2 - a.x1;
      final dy = a.y2 - a.y1;
      final len = math.sqrt(dx * dx + dy * dy);
      if (len < 0.001) {
        // Degenerate segment a: fall back to segment b as the result.
        return b;
      }
      final ux = dx / len;
      final uy = dy / len;
      double proj(double x, double y) => (x - a.x1) * ux + (y - a.y1) * uy;
      final pts = [
        (t: proj(a.x1, a.y1), x: a.x1, y: a.y1),
        (t: proj(a.x2, a.y2), x: a.x2, y: a.y2),
        (t: proj(b.x1, b.y1), x: b.x1, y: b.y1),
        (t: proj(b.x2, b.y2), x: b.x2, y: b.y2),
      ]..sort((p1, p2) => p1.t.compareTo(p2.t));
      return WallSegment(
        x1: pts.first.x, y1: pts.first.y,
        x2: pts.last.x,  y2: pts.last.y,
      );
    }

    final sorted = List<WallSegment>.from(segments)
      ..sort((a, b) => angle(a).compareTo(angle(b)));

    final result = <WallSegment>[];
    var current = sorted.first;

    for (int i = 1; i < sorted.length; i++) {
      if (shouldMerge(current, sorted[i])) {
        current = merge(current, sorted[i]);
      } else {
        result.add(current);
        current = sorted[i];
      }
    }
    result.add(current);

    // BUG-20: Discard any degenerate (zero-length) segments that may have
    // been produced by merging two exactly-coincident inputs. A zero-length
    // segment causes NaN when its direction vector is later normalised in
    // WallProcessor or the canvas projection code.
    const minSegmentLength = 0.1;
    return result.where((s) {
      final sdx = s.x2 - s.x1;
      final sdy = s.y2 - s.y1;
      return math.sqrt(sdx * sdx + sdy * sdy) >= minSegmentLength;
    }).toList();
  }
}
