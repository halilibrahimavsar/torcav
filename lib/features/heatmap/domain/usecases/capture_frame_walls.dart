import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/heatmap/domain/entities/wall_segment.dart';

/// Usecase to process a camera frame and detect wall segments.
class CaptureFrameWalls {
  Future<Either<Failure, List<WallSegment>>> call(CameraImage image) async {
    // This will interface with the WallDetectorDataSource (to be implemented).
    // For now, returning an empty list to satisfy the interface.
    return const Right([]);
  }
}
