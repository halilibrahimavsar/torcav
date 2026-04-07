import 'dart:math' as math;

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
    final plane = image.planes[0]; // Y (luminance) plane of YUV420
    final bytes = plane.bytes;
    final width = image.width;
    final height = image.height;
    // Use bytesPerRow instead of width — Android pads rows for memory alignment.
    final rowStride = plane.bytesPerRow;

    // Process the central 50% of the image to ignore sky and floor clutter.
    final yStart = height ~/ 4;
    final yEnd = height * 3 ~/ 4;
    final xStart = width ~/ 6;
    final xEnd = width * 5 ~/ 6;

    // Step every 8 pixels to stay well under the 16 ms frame budget.
    const step = 8;
    const edgeThreshold = 60.0;

    final candidates = <_EdgeCandidate>[];

    for (int y = yStart + 1; y < yEnd - 1; y += step) {
      for (int x = xStart + 1; x < xEnd - 1; x += step) {
        // 3×3 Sobel kernel using row-stride-aware indexing.
        final tl = bytes[(y - 1) * rowStride + (x - 1)] & 0xFF;
        final tm = bytes[(y - 1) * rowStride + x] & 0xFF;
        final tr = bytes[(y - 1) * rowStride + (x + 1)] & 0xFF;
        final ml = bytes[y * rowStride + (x - 1)] & 0xFF;
        final mr = bytes[y * rowStride + (x + 1)] & 0xFF;
        final bl = bytes[(y + 1) * rowStride + (x - 1)] & 0xFF;
        final bm = bytes[(y + 1) * rowStride + x] & 0xFF;
        final br = bytes[(y + 1) * rowStride + (x + 1)] & 0xFF;

        final gx = -tl + tr - 2 * ml + 2 * mr - bl + br;
        final gy = -tl - 2 * tm - tr + bl + 2 * bm + br;

        final mag = math.sqrt((gx * gx + gy * gy).toDouble());

        // Vertical wall criterion: strong horizontal gradient, weak vertical gradient.
        if (mag > edgeThreshold && gx.abs() > gy.abs() * 1.5) {
          candidates.add(
            _EdgeCandidate(x: x / width, y: y / height),
          );
        }
      }
    }

    return _groupIntoSegments(candidates);
  }

  /// Groups nearby edge candidates into vertical wall segments.
  List<WallSegment> _groupIntoSegments(List<_EdgeCandidate> candidates) {
    if (candidates.isEmpty) return [];

    candidates.sort((a, b) => a.x.compareTo(b.x));

    final segments = <WallSegment>[];
    var groupX = candidates.first.x;
    var topY = candidates.first.y;
    var botY = candidates.first.y;

    for (int i = 1; i < candidates.length; i++) {
      final c = candidates[i];
      if ((c.x - groupX).abs() < 0.08) {
        // Same vertical line cluster — extend the span.
        if (c.y < topY) topY = c.y;
        if (c.y > botY) botY = c.y;
      } else {
        // Emit segment if it spans a meaningful height.
        if (botY - topY > 0.10) {
          segments.add(WallSegment(x1: groupX, y1: topY, x2: groupX, y2: botY));
        }
        groupX = c.x;
        topY = c.y;
        botY = c.y;
      }
    }
    // Flush the last group.
    if (botY - topY > 0.10) {
      segments.add(WallSegment(x1: groupX, y1: topY, x2: groupX, y2: botY));
    }

    return segments.take(6).toList();
  }
}

class _EdgeCandidate {
  const _EdgeCandidate({required this.x, required this.y});
  final double x;
  final double y;
}
