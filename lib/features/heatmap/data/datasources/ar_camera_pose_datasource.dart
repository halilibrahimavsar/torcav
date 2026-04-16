import 'dart:async';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Native ARCore camera pose bridge. Listens to the Kotlin-side EventChannel
/// set up by `ArScenePlugin` and re-emits the tracked camera position,
/// projected onto the floor plane (XZ), as an [Offset] stream.
///
/// Also exposes [placeMarkerAtCamera] / [clearMarkers] to drop billboarded
/// RSSI text quads into the native AR scene.
@lazySingleton
class ArCameraPoseDataSource {
  ArCameraPoseDataSource()
      : _channel = const EventChannel('torcav/ar_scene/events'),
        _commands = const MethodChannel('torcav/ar_scene/commands');

  final EventChannel _channel;
  final MethodChannel _commands;
  StreamSubscription<dynamic>? _subscription;
  final StreamController<Offset> _cameraController =
      StreamController<Offset>.broadcast();

  /// Camera world position projected onto the floor (XZ). Emitted ~15 Hz
  /// whenever ARCore reports a tracked camera pose.
  Stream<Offset> get cameraPoseStream => _cameraController.stream;

  void start() {
    if (_subscription != null) return;
    _subscription = _channel.receiveBroadcastStream().listen(
      _onEvent,
      onError: (Object error, StackTrace trace) {
        // Swallow — bloc keeps PDR fallback alive.
      },
    );
  }

  /// Drops a billboarded RSSI text quad at the camera's last tracked AR
  /// position. [colorArgb] is a 0xAARRGGBB integer used as the pill's
  /// background. The native side caches textures per RSSI bucket.
  Future<void> placeMarkerAtCamera({
    required int rssi,
    required int colorArgb,
  }) async {
    try {
      await _commands.invokeMethod<bool>('placeMarkerAtCamera', {
        'rssi': rssi,
        'color': colorArgb,
      });
    } catch (_) {
      // Native side not ready or missing — ignore.
    }
  }

  Future<void> clearMarkers() async {
    try {
      await _commands.invokeMethod<bool>('clearMarkers');
    } catch (_) {}
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  @disposeMethod
  Future<void> dispose() async {
    await stop();
    await _cameraController.close();
  }

  void _onEvent(dynamic raw) {
    if (raw is! Map) return;
    final camera = raw['camera'];
    if (camera is! Map) return;
    final x = (camera['x'] as num?)?.toDouble();
    final z = (camera['z'] as num?)?.toDouble();
    if (x == null || z == null) return;
    _cameraController.add(Offset(x, z));
  }
}
