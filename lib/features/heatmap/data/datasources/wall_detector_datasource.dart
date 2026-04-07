import 'package:camera/camera.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/wall_segment.dart';

abstract class WallDetectorDataSource {
  Future<List<WallSegment>> detectWalls(CameraImage image);
}

@LazySingleton(as: WallDetectorDataSource)
class WallDetectorDataSourceImpl implements WallDetectorDataSource {
  @override
  Future<List<WallSegment>> detectWalls(CameraImage image) async {
    // 1. Core image data
    final plane = image.planes[0];
    final bytes = plane.bytes;
    final width = image.width;
    final height = image.height;

    final detected = <WallSegment>[];

    // 2. Screen-space Wall Detection (Normalized 0..1)
    // We sample high-contrast vertical lines in the image.
    for (int x = width ~/ 4; x < width * 3 ~/ 4; x += 150) {
      for (int y = height ~/ 3; y < height * 2 ~/ 3; y += 100) {
        final idx = y * width + x;
        final nextIdx = (y + 50) * width + x;
        
        if (nextIdx < bytes.length) {
          final diff = (bytes[idx] - bytes[nextIdx]).abs();
          if (diff > 45) {
            // Found a likely vertical boundary in the camera view.
            detected.add(WallSegment(
              x1: x / width,
              y1: y / height,
              x2: x / width,
              y2: (y + 50) / height,
            ));
          }
        }
      }
    }

    return detected.take(5).toList();
  }
}
