import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    hide openDatabase, Database, ConflictAlgorithm, getDatabasesPath;
import 'package:sqflite_sqlcipher/sqflite.dart' hide databaseFactory;

import '../logging/app_logger.dart';
import 'hive_storage_service.dart';
import 'secure_storage_service.dart';

@lazySingleton
class AppDatabase {
  AppDatabase(this._secureStorage, this._hive);

  /// Hive key set by [_open] when the encrypted database had to be reset.
  /// The splash page reads (and clears) it to surface a one-time notice.
  static const String healedFlagKey = 'last_db_healed_at';

  final SecureStorageService _secureStorage;
  final HiveStorageService _hive;
  Database? _database;
  Completer<Database>? _dbOpenCompleter;

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (_dbOpenCompleter != null) {
      return _dbOpenCompleter!.future;
    }

    _dbOpenCompleter = Completer<Database>();
    try {
      _database = await _open();
      _dbOpenCompleter!.complete(_database);
      return _database!;
    } catch (e, stack) {
      _dbOpenCompleter!.completeError(e, stack);
      _dbOpenCompleter = null;
      rethrow;
    }
  }

  Future<Database> _open() async {
    // Standard database path for Android/iOS, fallbacks to support for desktop
    String baseDirPath;
    if (Platform.isAndroid || Platform.isIOS) {
      baseDirPath = await getDatabasesPath();
    } else {
      final appDir = await getApplicationSupportDirectory();
      baseDirPath = appDir.path;
    }

    final dbPath = p.join(baseDirPath, 'torcav.sqlite');
    AppLogger.d('Initializing Vault at: $dbPath');

    // Ensure parent directory exists
    await Directory(baseDirPath).create(recursive: true);

    // Retrieve or generate the encryption key from secure storage
    final password = await _secureStorage.getDatabaseEncryptionKey();

    try {
      return await _openDatabase(dbPath, password);
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      // SQLCipher triggers 'not a database' or 'code 26' on key mismatch.
      // Some Android versions return 'open_failed' for the same underlying issue.
      final isCorruption =
          errorStr.contains('not a database') ||
          errorStr.contains('code 26') ||
          errorStr.contains('open_failed') ||
          errorStr.contains('malformed');

      if (isCorruption) {
        AppLogger.e(
          'Vault mismatch/corruption detected ($errorStr). Healing — '
          'local user data is being reset.',
          error: e,
        );
        final file = File(dbPath);
        if (await file.exists()) {
          await file.delete();
        }
        // Flag for the splash page to surface a one-time user notice next run.
        await _hive.save(healedFlagKey, DateTime.now().toIso8601String());
        return await _openDatabase(dbPath, password);
      }
      rethrow;
    }
  }

  Future<Database> _openDatabase(String dbPath, String password) async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      return databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 9,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
            // Apply encryption key via PRAGMA for FFI platforms.
            await db.execute(
              "PRAGMA key = '${password.replaceAll("'", "''")}'",
            );
          },
        ),
      );
    }

    return openDatabase(
      dbPath,
      password: password, // Enable encryption via sqflite_sqlcipher on mobile
      version: 9,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE security_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL,
        type TEXT NOT NULL,
        severity TEXT NOT NULL,
        ssid TEXT NOT NULL,
        bssid TEXT NOT NULL,
        evidence TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE known_networks (
        bssid TEXT PRIMARY KEY,
        ssid TEXT NOT NULL,
        security TEXT NOT NULL,
        first_seen TEXT NOT NULL,
        last_seen TEXT NOT NULL,
        seen_count INTEGER NOT NULL DEFAULT 1,
        gateway TEXT
      )
    ''');

    await _createTrustedNetworkProfilesTable(db);
    await _createScanHistoryTables(db);
    await _createLanHistoryTables(db);
    await _createAssessmentSessionsTable(db);

    await db.execute('''
      CREATE TABLE channel_rating_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        channel INTEGER NOT NULL,
        frequency INTEGER NOT NULL,
        rating REAL NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE heatmap_points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL,
        bssid TEXT NOT NULL,
        zone_tag TEXT NOT NULL,
        signal_dbm INTEGER NOT NULL
      )
    ''');

    await _createSpeedTestTable(db);
    await _createScoreHistoryTable(db);
  }

  Future<void> _createScoreHistoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE security_score_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        score INTEGER NOT NULL,
        recorded_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _createSpeedTestTable(Database db) async {
    await db.execute('''
      CREATE TABLE speed_test_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recorded_at TEXT NOT NULL,
        latency_ms REAL NOT NULL,
        jitter_ms REAL NOT NULL,
        download_mbps REAL NOT NULL,
        upload_mbps REAL NOT NULL,
        packet_loss REAL NOT NULL DEFAULT 0,
        loaded_latency_ms REAL NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _createTrustedNetworkProfilesTable(Database db) async {
    await db.execute('''
      CREATE TABLE trusted_network_profiles (
        bssid TEXT PRIMARY KEY,
        ssid TEXT NOT NULL,
        fingerprint_json TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        trusted_at TEXT NOT NULL,
        last_confirmed_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createScanHistoryTables(Database db) async {
    await db.execute('''
      CREATE TABLE scan_sessions (
        session_key TEXT PRIMARY KEY,
        created_at TEXT NOT NULL,
        backend_used TEXT NOT NULL,
        interface_name TEXT NOT NULL,
        channel_stats_json TEXT NOT NULL,
        band_stats_json TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE wifi_observations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_key TEXT NOT NULL,
        ssid TEXT NOT NULL,
        bssid TEXT NOT NULL,
        samples_json TEXT NOT NULL,
        avg_signal_dbm INTEGER NOT NULL,
        signal_std_dev REAL NOT NULL,
        channel INTEGER NOT NULL,
        frequency INTEGER NOT NULL,
        security TEXT NOT NULL,
        vendor TEXT NOT NULL,
        is_hidden INTEGER NOT NULL,
        seen_count INTEGER NOT NULL,
        channel_width_mhz INTEGER,
        wifi_standard TEXT,
        has_wps INTEGER,
        has_pmf INTEGER,
        raw_capabilities TEXT,
        ap_mld_mac TEXT,
        FOREIGN KEY(session_key) REFERENCES scan_sessions(session_key) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createLanHistoryTables(Database db) async {
    await db.execute('''
      CREATE TABLE lan_scan_sessions (
        session_key TEXT PRIMARY KEY,
        created_at TEXT NOT NULL,
        target TEXT NOT NULL,
        profile TEXT NOT NULL,
        payload_json TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE lan_exposure_findings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_key TEXT NOT NULL,
        host_ip TEXT NOT NULL,
        host_mac TEXT NOT NULL,
        rule_id TEXT NOT NULL,
        summary TEXT NOT NULL,
        risk TEXT NOT NULL,
        evidence TEXT NOT NULL,
        remediation TEXT NOT NULL,
        service_name TEXT,
        port INTEGER,
        FOREIGN KEY(session_key) REFERENCES lan_scan_sessions(session_key) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createAssessmentSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE assessment_sessions (
        session_key TEXT PRIMARY KEY,
        created_at TEXT NOT NULL,
        overall_score INTEGER NOT NULL,
        overall_status TEXT NOT NULL,
        wifi_findings_json TEXT NOT NULL,
        lan_findings_json TEXT NOT NULL,
        dns_result_json TEXT,
        trusted_profile_count INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await _createSpeedTestTable(db);
    }
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS wifi_signal_samples');
      await db.execute('DROP TABLE IF EXISTS wifi_observations');
      await db.execute('DROP TABLE IF EXISTS channel_metrics');
      await db.execute('DROP TABLE IF EXISTS band_metrics');
      await db.execute('DROP TABLE IF EXISTS network_services');
      await db.execute('DROP TABLE IF EXISTS network_vulnerabilities');
      await db.execute('DROP TABLE IF EXISTS network_hosts');
      await db.execute('DROP TABLE IF EXISTS scan_sessions');
      await db.execute('DROP TABLE IF EXISTS speedtest_results');
      await db.execute('DROP TABLE IF EXISTS security_assessments');
      await db.execute('DROP TABLE IF EXISTS authorized_targets');
      await db.execute('DROP TABLE IF EXISTS bandwidth_samples');
      await db.execute('DROP TABLE IF EXISTS report_exports');
      await db.execute('DROP TABLE IF EXISTS app_settings');
    }
    if (oldVersion < 4) {
      await _createTrustedNetworkProfilesTable(db);
      await _createScanHistoryTables(db);
      await _createLanHistoryTables(db);
      await _createAssessmentSessionsTable(db);
      await _migrateKnownNetworks(db);
    }
    if (oldVersion < 5) {
      await db.execute(
        'ALTER TABLE known_networks ADD COLUMN seen_count INTEGER NOT NULL DEFAULT 1',
      );
    }
    if (oldVersion < 6) {
      await db.execute(
        'ALTER TABLE speed_test_results ADD COLUMN packet_loss REAL NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE speed_test_results ADD COLUMN loaded_latency_ms REAL NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE known_networks ADD COLUMN gateway TEXT');
    }
    if (oldVersion < 8) {
      await _createScoreHistoryTable(db);
    }
    if (oldVersion < 9) {
      // v9 is the first version shipped to Play Store; pre-release builds
      // (v1–v8) had no `frequency` column on channel_rating_history, so the
      // table is recreated cleanly. Once v9 is published, future migrations
      // must be non-destructive (use ALTER TABLE ADD COLUMN) — production
      // users will have real history rows.
      await db.execute('DROP TABLE IF EXISTS channel_rating_history');
      await db.execute('''
        CREATE TABLE channel_rating_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          channel INTEGER NOT NULL,
          frequency INTEGER NOT NULL,
          rating REAL NOT NULL,
          timestamp TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _migrateKnownNetworks(Database db) async {
    final rows = await db.query('known_networks');
    for (final row in rows) {
      final bssid = row['bssid'] as String? ?? '';
      final ssid = row['ssid'] as String? ?? '';
      final security = row['security'] as String? ?? 'unknown';
      final trustedAt = row['first_seen'] as String? ?? '';
      final lastConfirmedAt = row['last_seen'] as String? ?? trustedAt;

      final fingerprint = jsonEncode({
        'ssid': ssid,
        'bssid': bssid,
        'security': security,
        'vendor': 'Unknown',
        'isHidden': false,
        'channel': 0,
        'frequency': 0,
        'bandLabel': 'Unknown',
      });

      await db.insert('trusted_network_profiles', {
        'bssid': bssid,
        'ssid': ssid,
        'fingerprint_json': fingerprint,
        'notes': '',
        'trusted_at':
            trustedAt.isEmpty
                ? DateTime.fromMillisecondsSinceEpoch(0).toIso8601String()
                : trustedAt,
        'last_confirmed_at':
            lastConfirmedAt.isEmpty
                ? DateTime.fromMillisecondsSinceEpoch(0).toIso8601String()
                : lastConfirmedAt,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}
