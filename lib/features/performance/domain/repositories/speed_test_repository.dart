import '../entities/speed_test_progress.dart';

/// Repository that runs a speed test and emits live progress updates.
abstract class SpeedTestRepository {
  /// Yields [SpeedTestProgress] updates as each phase completes.
  Stream<SpeedTestProgress> runSpeedTest();
}
