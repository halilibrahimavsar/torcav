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
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scan_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL,
        backend_used TEXT NOT NULL,
        interface_name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE wifi_observations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        ssid TEXT NOT NULL,
        bssid TEXT NOT NULL,
        avg_signal_dbm INTEGER NOT NULL,
        stddev REAL NOT NULL,
        channel INTEGER NOT NULL,
        frequency INTEGER NOT NULL,
        security TEXT NOT NULL,
        vendor TEXT NOT NULL,
        is_hidden INTEGER NOT NULL DEFAULT 0,
        seen_count INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (session_id) REFERENCES scan_sessions(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE wifi_signal_samples (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        observation_id INTEGER NOT NULL,
        sample_index INTEGER NOT NULL,
        signal_dbm INTEGER NOT NULL,
        FOREIGN KEY (observation_id) REFERENCES wifi_observations(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE channel_metrics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        channel INTEGER NOT NULL,
        frequency INTEGER NOT NULL,
        network_count INTEGER NOT NULL,
        avg_signal_dbm INTEGER NOT NULL,
        congestion_score REAL NOT NULL,
        recommendation TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES scan_sessions(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE band_metrics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        band TEXT NOT NULL,
        network_count INTEGER NOT NULL,
        avg_signal_dbm INTEGER NOT NULL,
        recommendation TEXT NOT NULL,
        recommended_channels TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES scan_sessions(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE security_assessments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER,
        bssid TEXT NOT NULL,
        score INTEGER NOT NULL,
        status TEXT NOT NULL,
        risk_factors TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE security_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL,
        type TEXT NOT NULL,
        severity TEXT NOT NULL,
        ssid TEXT NOT NULL,
        bssid TEXT NOT NULL,
        evidence TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE authorized_targets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bssid TEXT NOT NULL UNIQUE,
        ssid TEXT NOT NULL,
        operations TEXT NOT NULL,
        approved_at TEXT NOT NULL,
        approved_by TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE network_hosts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER,
        ip TEXT NOT NULL,
        mac TEXT NOT NULL,
        vendor TEXT NOT NULL,
        host_name TEXT NOT NULL,
        os_guess TEXT NOT NULL,
        exposure_score REAL NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE network_services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        host_id INTEGER NOT NULL,
        port INTEGER NOT NULL,
        protocol TEXT NOT NULL,
        service_name TEXT NOT NULL,
        product TEXT NOT NULL,
        version TEXT NOT NULL,
        FOREIGN KEY (host_id) REFERENCES network_hosts(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE network_vulnerabilities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        host_id INTEGER NOT NULL,
        script_id TEXT NOT NULL,
        summary TEXT NOT NULL,
        severity TEXT NOT NULL,
        FOREIGN KEY (host_id) REFERENCES network_hosts(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE bandwidth_samples (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL,
        interface_name TEXT NOT NULL,
        tx_bps REAL NOT NULL,
        rx_bps REAL NOT NULL
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

    await db.execute('''
      CREATE TABLE speedtest_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL,
        backend TEXT NOT NULL,
        download_mbps REAL NOT NULL,
        upload_mbps REAL NOT NULL,
        latency_ms REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE report_exports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL,
        format TEXT NOT NULL,
        file_path TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }
}
