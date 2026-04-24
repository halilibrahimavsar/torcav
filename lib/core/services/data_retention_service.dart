import 'package:injectable/injectable.dart';
import '../storage/app_database.dart';
import '../../features/settings/domain/services/app_settings_store.dart';

@lazySingleton
class DataRetentionService {
  final AppDatabase _database;
  final AppSettingsStore _settingsStore;

  DataRetentionService(this._database, this._settingsStore);

  /// Deletes local records older than the configured retention period.
  Future<void> enforceRetention() async {
    final settings = _settingsStore.value;
    
    final now = DateTime.now();
    final db = await _database.database;

    final tasks = <Future<int>>[];

    // 1. Scan History Retention
    if (settings.scanHistoryRetentionDays > 0) {
      final cutoff = now.subtract(Duration(days: settings.scanHistoryRetentionDays)).toIso8601String();
      tasks.add(db.delete('scan_sessions', where: 'created_at < ?', whereArgs: [cutoff]));
      tasks.add(db.delete('lan_scan_sessions', where: 'created_at < ?', whereArgs: [cutoff]));
      tasks.add(db.delete('assessment_sessions', where: 'created_at < ?', whereArgs: [cutoff]));
      tasks.add(db.delete('channel_rating_history', where: 'timestamp < ?', whereArgs: [cutoff]));
      tasks.add(db.delete('heatmap_points', where: 'created_at < ?', whereArgs: [cutoff]));
    }

    // 2. Speed Test Retention
    if (settings.speedTestRetentionDays > 0) {
      final cutoff = now.subtract(Duration(days: settings.speedTestRetentionDays)).toIso8601String();
      tasks.add(db.delete('speed_test_results', where: 'recorded_at < ?', whereArgs: [cutoff]));
    }

    // 3. Security Event Retention
    if (settings.securityEventRetentionDays > 0) {
      final cutoffDate = now.subtract(Duration(days: settings.securityEventRetentionDays));
      final cutoffIso = cutoffDate.toIso8601String();
      final cutoffMs = cutoffDate.millisecondsSinceEpoch;
      
      tasks.add(db.delete('security_events', where: 'created_at < ?', whereArgs: [cutoffIso]));
      tasks.add(db.delete('security_score_history', where: 'recorded_at < ?', whereArgs: [cutoffMs]));
    }

    if (tasks.isNotEmpty) {
      await Future.wait(tasks);
    }
  }
}
