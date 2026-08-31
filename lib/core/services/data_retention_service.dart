import 'package:injectable/injectable.dart';
import 'package:torcav/core/settings/app_settings_store.dart';
import 'package:torcav/features/ai/data/stores/device_label_override_store.dart';
import 'package:torcav/features/dashboard/data/datasources/score_history_local_data_source.dart';
import 'package:torcav/features/heatmap/data/datasources/heatmap_local_data_source.dart';
import 'package:torcav/features/network_scan/domain/repositories/lan_scan_history_repository.dart';
import 'package:torcav/features/performance/domain/repositories/speed_test_history_repository.dart';
import 'package:torcav/features/security/data/datasources/security_local_data_source.dart';
import 'package:torcav/features/security/data/stores/network_context_override_store.dart';
import 'package:torcav/features/security/data/stores/router_hardening_store.dart';
import 'package:torcav/features/wifi_scan/data/datasources/channel_rating_local_data_source.dart';
import 'package:torcav/features/wifi_scan/data/datasources/wifi_scan_history_local_data_source.dart';
import 'package:torcav/features/wifi_scan/data/services/favorites_store.dart';
import 'package:torcav/features/wifi_scan/domain/services/scan_session_store.dart';
import '../storage/app_database.dart';

/// Owns the two operations that span every store the app writes to: pruning
/// by age, and wiping everything on request.
///
/// It is deliberately the one place that knows the full list. That knowledge
/// used to live in `settings_page.dart`, which meant a settings screen
/// reached into eleven datasources across eight features — and a new store
/// could be added without anyone remembering to delete it here.
@lazySingleton
class DataRetentionService {
  DataRetentionService(
    this._database,
    this._settingsStore,
    this._scanSessions,
    this._speedTests,
    this._security,
    this._channelRatings,
    this._wifiScanHistory,
    this._heatmap,
    this._lanScans,
    this._deviceLabels,
    this._favorites,
    this._scoreHistory,
    this._networkContexts,
    this._routerHardening,
  );

  final AppDatabase _database;
  final AppSettingsStore _settingsStore;
  final ScanSessionStore _scanSessions;
  final SpeedTestHistoryRepository _speedTests;
  final SecurityLocalDataSource _security;
  final ChannelRatingLocalDataSource _channelRatings;
  final WifiScanHistoryLocalDataSource _wifiScanHistory;
  final HeatmapLocalDataSource _heatmap;
  final LanScanHistoryRepository _lanScans;
  final DeviceLabelOverrideStore _deviceLabels;
  final FavoritesStore _favorites;
  final ScoreHistoryLocalDataSource _scoreHistory;
  final NetworkContextOverrideStore _networkContexts;
  final RouterHardeningStore _routerHardening;

  /// Deletes every record the user has accumulated, in memory and on disk.
  ///
  /// The in-memory session store is cleared first so nothing re-persists a
  /// snapshot while the deletes are in flight.
  Future<void> wipeAllUserData() async {
    _scanSessions.clear();
    await Future.wait<void>([
      _speedTests.deleteAll(),
      _security.deleteAllData(),
      _channelRatings.clearHistory(),
      _wifiScanHistory.clear(),
      _heatmap.deleteAll(),
      _lanScans.deleteAllSessions(),
      _deviceLabels.clearAll(),
      _favorites.clearAll(),
      _scoreHistory.deleteAll(),
      _networkContexts.clearAll(),
      _routerHardening.clearAll(),
    ]);
  }

  /// Deletes local records older than the configured retention period.
  /// Returns the total number of rows deleted across all tables.
  Future<int> enforceRetention() async {
    final settings = _settingsStore.value;

    final now = DateTime.now();
    final db = await _database.database;

    final tasks = <Future<int>>[];

    // 1. Scan History Retention
    if (settings.scanHistoryRetentionDays > 0) {
      final cutoff =
          now
              .subtract(Duration(days: settings.scanHistoryRetentionDays))
              .toIso8601String();
      tasks.add(
        db.delete(
          'scan_sessions',
          where: 'created_at < ?',
          whereArgs: [cutoff],
        ),
      );
      tasks.add(
        db.delete(
          'lan_scan_sessions',
          where: 'created_at < ?',
          whereArgs: [cutoff],
        ),
      );
      tasks.add(
        db.delete(
          'assessment_sessions',
          where: 'created_at < ?',
          whereArgs: [cutoff],
        ),
      );
      tasks.add(
        db.delete(
          'channel_rating_history',
          where: 'timestamp < ?',
          whereArgs: [cutoff],
        ),
      );
      tasks.add(
        db.delete(
          'heatmap_points',
          where: 'created_at < ?',
          whereArgs: [cutoff],
        ),
      );
    }

    // 2. Speed Test Retention
    if (settings.speedTestRetentionDays > 0) {
      final cutoff =
          now
              .subtract(Duration(days: settings.speedTestRetentionDays))
              .toIso8601String();
      tasks.add(
        db.delete(
          'speed_test_results',
          where: 'recorded_at < ?',
          whereArgs: [cutoff],
        ),
      );
    }

    // 3. Security Event Retention
    if (settings.securityEventRetentionDays > 0) {
      final cutoffDate = now.subtract(
        Duration(days: settings.securityEventRetentionDays),
      );
      final cutoffIso = cutoffDate.toIso8601String();
      final cutoffMs = cutoffDate.millisecondsSinceEpoch;

      tasks.add(
        db.delete(
          'security_events',
          where: 'created_at < ?',
          whereArgs: [cutoffIso],
        ),
      );
      tasks.add(
        db.delete(
          'security_score_history',
          where: 'recorded_at < ?',
          whereArgs: [cutoffMs],
        ),
      );
    }

    if (tasks.isEmpty) return 0;
    final results = await Future.wait(tasks);
    return results.fold<int>(0, (sum, count) => sum + count);
  }
}
