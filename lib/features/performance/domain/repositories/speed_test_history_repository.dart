import '../entities/speed_test_result.dart';

abstract class SpeedTestHistoryRepository {
  Future<void> save(SpeedTestResult result);
  Future<List<SpeedTestResult>> getRecent({int limit = 20});
  Future<void> deleteById(int id);
  Future<void> deleteAll();
}
