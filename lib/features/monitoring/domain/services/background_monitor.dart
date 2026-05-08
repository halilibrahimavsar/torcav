/// Abstract front-end for the platform-native background monitoring
/// service. Android implementation drives a foreground service via
/// [MethodChannel('torcav/background_monitor')]. iOS uses the
/// BGAppRefreshTask scheduler. Both surfaces are best-effort and the
/// caller should treat failures as non-fatal.
abstract class BackgroundMonitor {
  /// Start the platform service. Returns true if the platform accepted
  /// the request (notification posted on Android, task scheduled on iOS).
  Future<bool> start({Duration tickInterval = const Duration(minutes: 30)});

  /// Stop the platform service. Idempotent — safe to call when nothing
  /// is running.
  Future<bool> stop();
}
