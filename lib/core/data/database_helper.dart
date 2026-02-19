import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DatabaseHelper {
  static const _databaseName = "security.db";
  static const _databaseVersion = 2;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE channel_rating_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          channel INTEGER NOT NULL,
          rating REAL NOT NULL,
          timestamp INTEGER NOT NULL
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE known_networks (
        bssid TEXT PRIMARY KEY,
        ssid TEXT NOT NULL,
        security TEXT NOT NULL,
        first_seen INTEGER NOT NULL,
        last_seen INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE security_alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        severity TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE channel_rating_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        channel INTEGER NOT NULL,
        rating REAL NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }
}
