import 'dart:io';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

@lazySingleton
class OuiDatabaseService {
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final docDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docDir.path, 'oui.db');

    // Copy from assets on first run or if updated
    // For now, simple copy if not exists
    if (!await File(dbPath).exists()) {
      final data = await rootBundle.load('assets/data/oui.db');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(dbPath, readOnly: true);
  }

  Future<String> getVendor(String mac) async {
    if (mac.isEmpty) return 'Unknown';

    // Normalize MAC to OUI (XX:XX:XX)
    final cleanMac = mac.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '').toUpperCase();

    // Special case for zeroed MACs (Android 11+ restriction)
    if (cleanMac == '000000000000') return 'Android Device (MAC Restricted)';

    if (cleanMac.length < 6) return 'Unknown';

    final oui =
        '${cleanMac.substring(0, 2)}:${cleanMac.substring(2, 4)}:${cleanMac.substring(4, 6)}';

    try {
      final db = await _db;
      final results = await db.query(
        'oui',
        columns: ['vendor'],
        where: 'prefix = ?',
        whereArgs: [oui],
        limit: 1,
      );

      if (results.isNotEmpty) {
        return results.first['vendor'] as String;
      }
    } catch (e) {
      // Fallback if DB fails
    }

    return 'Unknown';
  }
}
