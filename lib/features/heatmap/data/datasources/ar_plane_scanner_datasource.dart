import 'dart:async';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import 'package:torcav/features/heatmap/domain/entities/wall_segment.dart';

/// Native ARCore plane-polygon stream. Listens to the Kotlin-side EventChannel
/// set up by `ArScenePlugin`, projects each detected vertical plane onto the
/// floor (XZ), and emits a [WallSegment] per plane. The segment is the plane's
/// horizontal footprint — the bottom edge you'd trace along the floor.
@lazySingleton
class ArPlaneScannerDataSource {
  ArPlaneScannerDataSource()
      : _channel = const EventChannel('torcav/ar_scene/events');

  final EventChannel _channel;
  StreamSubscription<dynamic>? _subscription;
  final StreamController<List<WallSegment>> _controller =
      StreamController<List<WallSegment>>.broadcast();
  final StreamController<Offset> _cameraController =
      StreamController<Offset>.broadcast();

  Stream<List<WallSegment>> get wallStream => _controller.stream;

  /// Camera world position projected onto the floor (XZ). Emitted ~15 Hz
  /// whenever ARCore reports a tracked camera pose.
  Stream<Offset> get cameraPoseStream => _cameraController.stream;

  void start() {
    if (_subscription != null) return;
    _subscription = _channel.receiveBroadcastStream().listen(
      _onEvent,
      onError: (Object error, StackTrace trace) {
        // Swallow — bloc keeps Sobel fallback alive.
      },
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  @disposeMethod
  Future<void> dispose() async {
    await stop();
    await _controller.close();
    await _cameraController.close();
  }

  void _onEvent(dynamic raw) {
    if (raw is! Map) return;

    final camera = raw['camera'];
    if (camera is Map) {
      final x = (camera['x'] as num?)?.toDouble();
      final z = (camera['z'] as num?)?.toDouble();
      if (x != null && z != null) {
        _cameraController.add(Offset(x, z));
      }
    }

    final planes = raw['planes'];
    if (planes is List) {
      final segments = <WallSegment>[];
      for (final dynamic plane in planes) {
        if (plane is! Map) continue;
        final segment = _projectPlaneToFloor(plane);
        if (segment != null) segments.add(segment);
      }
      if (segments.isNotEmpty) {
        _controller.add(segments);
      }
    }
  }

  /// ARCore gives us the plane polygon as a flat list of (x, y, z) world
  /// coordinates. For a vertical plane we only care about its horizontal
  /// footprint — the projection onto the XZ (floor) plane. The two points
  /// most distant from each other in that projection define the wall segment.
  WallSegment? _projectPlaneToFloor(Map<dynamic, dynamic> plane) {
    final points = plane['points'];
    if (points is! List || points.length < 6) return null;

    double? bestLen;
    double bestAx = 0;
    double bestAz = 0;
    double bestBx = 0;
    double bestBz = 0;

    for (int i = 0; i + 2 < points.length; i += 3) {
      final ax = (points[i] as num).toDouble();
      final az = (points[i + 2] as num).toDouble();
      for (int j = i + 3; j + 2 < points.length; j += 3) {
        final bx = (points[j] as num).toDouble();
        final bz = (points[j + 2] as num).toDouble();
        final dx = bx - ax;
        final dz = bz - az;
        final len = dx * dx + dz * dz;
        if (bestLen == null || len > bestLen) {
          bestLen = len;
          bestAx = ax;
          bestAz = az;
          bestBx = bx;
          bestBz = bz;
        }
      }
    }

    if (bestLen == null || bestLen < 0.04) return null; // < 20 cm ignored

    return WallSegment(
      x1: bestAx,
      y1: bestAz,
      x2: bestBx,
      y2: bestBz,
    );
  }
}

