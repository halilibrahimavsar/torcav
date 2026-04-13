import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/wall_segment.dart';

abstract class WallDetectorDataSource {
  Future<List<WallSegment>> detectWalls(CameraImage image);
}

@LazySingleton(as: WallDetectorDataSource)
class WallDetectorDataSourceImpl implements WallDetectorDataSource {
  /// History of segments for temporal stabilization.
  final List<List<WallSegment>> _history = [];
  static const _maxHistory = 3;

  @override
  Future<List<WallSegment>> detectWalls(CameraImage image) async {
    final plane = image.planes[0]; // Y (luminance) plane of YUV420
    final bytes = plane.bytes;
    final width = image.width;
    final height = image.height;
    final rowStride = plane.bytesPerRow;

    // Adaptive Analysis: Calculate average luminance to adjust thresholds.
    // Sample a sparse grid to save cycles.
    double avgLuminance = 0;
    int samples = 0;
    for (int y = height ~/ 4; y < height * 3 ~/ 4; y += 40) {
      for (int x = width ~/ 4; x < width * 3 ~/ 4; x += 40) {
        avgLuminance += bytes[y * rowStride + x] & 0xFF;
        samples++;
      }
    }
    avgLuminance /= samples;

    // Process the central region for walls/floors.
    final yStart = height ~/ 6;
    final yEnd = height * 5 ~/ 6;
    final xStart = width ~/ 8;
    final xEnd = width * 7 ~/ 8;

    // Adaptive threshold: more sensitive in dark scenes, stricter in bright ones.
    final edgeThreshold = math.max(35.0, avgLuminance * 0.45);
    const step = 8;

    final vCandidates = <_EdgeCandidate>[];
    final hCandidates = <_EdgeCandidate>[];

    for (int y = yStart + 1; y < yEnd - 1; y += step) {
      for (int x = xStart + 1; x < xEnd - 1; x += step) {
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

        if (mag > edgeThreshold) {
          if (gx.abs() > gy.abs() * 1.6) {
            vCandidates.add(_EdgeCandidate(x: x / width, y: y / height));
          } else if (gy.abs() > gx.abs() * 1.6) {
            hCandidates.add(_EdgeCandidate(x: x / width, y: y / height));
          }
        }
      }
    }

    final currentFrameSegments = [
      ..._groupIntoSegments(vCandidates, isVertical: true),
      ..._groupIntoSegments(hCandidates, isVertical: false),
    ];

    return _stabilize(currentFrameSegments);
  }

  /// Groups nearby candidates into segments with noise filtering.
  List<WallSegment> _groupIntoSegments(
    List<_EdgeCandidate> candidates, {
    required bool isVertical,
  }) {
    if (candidates.isEmpty) return [];

    if (isVertical) {
      candidates.sort((a, b) => a.x != b.x ? a.x.compareTo(b.x) : a.y.compareTo(b.y));
    } else {
      candidates.sort((a, b) => a.y != b.y ? a.y.compareTo(b.y) : a.x.compareTo(b.x));
    }

    final segments = <WallSegment>[];
    if (candidates.isEmpty) return [];

    var groupRef = isVertical ? candidates.first.x : candidates.first.y;
    var startPos = isVertical ? candidates.first.y : candidates.first.x;
    var endPos = isVertical ? candidates.first.y : candidates.first.x;

    for (int i = 1; i < candidates.length; i++) {
      final c = candidates[i];
      final val = isVertical ? c.x : c.y;
      final pos = isVertical ? c.y : c.x;

      if ((val - groupRef).abs() < 0.05 && (pos - endPos).abs() < 0.12) {
        endPos = pos;
      } else {
        if ((endPos - startPos).abs() > 0.15) {
          segments.add(
            isVertical
                ? WallSegment(x1: groupRef, y1: startPos, x2: groupRef, y2: endPos)
                : WallSegment(x1: startPos, y1: groupRef, x2: endPos, y2: groupRef),
          );
        }
        groupRef = val;
        startPos = pos;
        endPos = pos;
      }
    }

    if ((endPos - startPos).abs() > 0.15) {
      segments.add(
        isVertical
            ? WallSegment(x1: groupRef, y1: startPos, x2: groupRef, y2: endPos)
            : WallSegment(x1: startPos, y1: groupRef, x2: endPos, y2: groupRef),
      );
    }

    return segments.take(8).toList();
  }

  /// Simple temporal stabilization: only emit segments that have nearby matches 
  /// in the history to reduce flicker.
  List<WallSegment> _stabilize(List<WallSegment> current) {
    _history.insert(0, current);
    if (_history.length > _maxHistory) _history.removeLast();

    if (_history.length < 2) return current;

    final stable = <WallSegment>[];
    for (final seg in current) {
      int matches = 0;
      for (int i = 1; i < _history.length; i++) {
        final hasMatch = _history[i].any((prev) => _isProximityMatch(seg, prev));
        if (hasMatch) matches++;
      }
      if (matches >= 1) {
        stable.add(seg);
      }
    }
    return stable;
  }

  bool _isProximityMatch(WallSegment a, WallSegment b) {
    final dx = (a.x1 - b.x1).abs() + (a.x2 - b.x2).abs();
    final dy = (a.y1 - b.y1).abs() + (a.y2 - b.y2).abs();
    return (dx + dy) < 0.15;
  }
}

class _EdgeCandidate {
  const _EdgeCandidate({required this.x, required this.y});
  final double x;
  final double y;
}
