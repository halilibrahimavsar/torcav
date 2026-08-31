import 'dart:ui';

/// Camera pose from the native AR session, plus the marker commands the
/// survey uses to annotate the scene.
///
/// Only the pose crosses this boundary — never a camera frame. The native
/// side keeps the image; Dart receives an [Offset] on the floor plane.
///
/// The interface lives in `domain` so the bloc depends on the contract rather
/// than on the `EventChannel` wiring that implements it.
abstract class ArCameraPoseSource {
  /// Camera world position projected onto the floor (XZ), ~15 Hz.
  Stream<Offset> get cameraPoseStream;

  void start();

  Future<void> stop();

  /// Drops a billboarded RSSI label at the camera's last tracked position.
  Future<void> placeMarkerAtCamera({required int rssi, required int colorArgb});

  Future<void> clearMarkers();

  /// Releases the native subscription. Called by the DI container on
  /// teardown, so it has to be part of the contract.
  Future<void> dispose();
}
