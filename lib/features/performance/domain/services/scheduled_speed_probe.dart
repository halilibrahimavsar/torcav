import '../entities/speed_test_result.dart';

/// Opt-in background download probe: measures the line periodically on
/// unmetered networks so the paying-vs-getting trend builds itself.
abstract class ScheduledSpeedProbe {
  /// Schedules (or re-schedules) the periodic probe.
  Future<bool> start({Duration interval = const Duration(hours: 12)});

  /// Cancels the periodic probe.
  Future<bool> stop();

  /// Returns results collected since the last drain and clears the native
  /// queue. Call on app start; the caller persists them into history.
  Future<List<SpeedTestResult>> drain();
}
