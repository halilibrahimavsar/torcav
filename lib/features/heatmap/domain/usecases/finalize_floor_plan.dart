import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/floor_plan.dart';
import '../entities/wall_segment.dart';

class FinalizeFloorPlan {
  Future<Either<Failure, FloorPlan>> call(List<WallSegment> segments) async {
    // Merges raw segments into a clean FloorPlan using RANSAC/clustering.
    // For now, simple bounding box calculation.
    if (segments.isEmpty) {
      return const Right(FloorPlan(walls: [], widthMeters: 5, heightMeters: 5));
    }

    double minX = 0, minY = 0, maxX = 0, maxY = 0;
    for (final s in segments) {
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
      walls: segments,
      widthMeters: maxX - minX,
      heightMeters: maxY - minY,
    ));
  }
}
