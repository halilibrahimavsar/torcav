import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

@lazySingleton
class AppDatabase {
  Database? _database;

  Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final baseDir = await getApplicationSupportDirectory();
    final dbPath = p.join(baseDir.path, 'torcav.sqlite');

    return openDatabase(
      dbPath,
      version: 3,
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
        last_seen TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE channel_rating_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        channel INTEGER NOT NULL,
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
  }

  Future<void> _createSpeedTestTable(Database db) async {
    await db.execute('''
      CREATE TABLE speed_test_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recorded_at TEXT NOT NULL,
        latency_ms REAL NOT NULL,
        jitter_ms REAL NOT NULL,
        download_mbps REAL NOT NULL,
        upload_mbps REAL NOT NULL
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
  }
}
