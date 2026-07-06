/// Abstract front-end for the platform-native background monitoring
/// scheduler. Android enqueues a WorkManager periodic worker via
/// [MethodChannel('torcav/background_monitor')] (Doze-aware, persists
/// across reboots, no foreground service). iOS uses the BGAppRefreshTask
/// scheduler. Both surfaces are best-effort and the caller should treat
/// failures as non-fatal.
abstract class BackgroundMonitor {
  /// Start (or refresh) the platform schedule. Returns true if the
  /// platform accepted the request. Android clamps the interval to
  /// WorkManager's 15-minute periodic floor.
  Future<bool> start({Duration tickInterval = const Duration(minutes: 30)});

  /// Stop the platform service. Idempotent — safe to call when nothing
  /// is running.
  Future<bool> stop();
}
