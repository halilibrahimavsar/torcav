import '../entities/speed_test_result.dart';

abstract class SpeedTestHistoryRepository {
  Future<void> save(SpeedTestResult result);
  Future<List<SpeedTestResult>> getRecent({int limit = 20});
  Future<void> deleteById(int id);
  Future<void> deleteAll();

  /// Fires after every mutation (save/delete) so listeners — e.g. the plan
  /// comparison card — can reload without polling.
  Stream<void> get changes;
}
