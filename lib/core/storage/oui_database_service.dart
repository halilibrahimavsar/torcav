import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    hide Database, openDatabase;
import 'package:sqflite_sqlcipher/sqflite.dart' hide databaseFactory;

import '../logging/app_logger.dart';

@lazySingleton
class OuiDatabaseService {
  Database? _database;
  Future<Database>? _databaseFuture;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    final pending = _databaseFuture;
    if (pending != null) return pending;

    final future = _initDb();
    _databaseFuture = future;
    try {
      _database = await future;
      return _database!;
    } finally {
      _databaseFuture = null;
    }
  }

  Future<Database> _initDb() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final docDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docDir.path, 'oui.db');

    await _syncAssetDatabase(dbPath);

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(readOnly: true),
      );
    }

    return openDatabase(dbPath, readOnly: true);
  }

  Future<void> _syncAssetDatabase(String dbPath) async {
    final assetBytes = await _loadAssetDatabaseBytes();
    final dbFile = File(dbPath);

    if (!await _isLocalDatabaseCurrent(dbFile, assetBytes)) {
      final tempFile = File('$dbPath.tmp');
      await tempFile.writeAsBytes(assetBytes, flush: true);
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
      await tempFile.rename(dbPath);
    }
  }

  Future<List<int>> _loadAssetDatabaseBytes() async {
    final data = await rootBundle.load('assets/data/oui.db');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  @visibleForTesting
  Future<bool> isLocalDatabaseCurrentForTest(
    File dbFile,
    List<int> assetBytes,
  ) => _isLocalDatabaseCurrent(dbFile, assetBytes);

  Future<bool> _isLocalDatabaseCurrent(
    File dbFile,
    List<int> assetBytes,
  ) async {
    if (!await dbFile.exists()) return false;

    try {
      if (await dbFile.length() != assetBytes.length) return false;
      final localDigest = sha256.convert(await dbFile.readAsBytes());
      final assetDigest = sha256.convert(assetBytes);
      return localDigest == assetDigest;
    } catch (_) {
      return false;
    }
  }

  Future<String> getVendor(String mac) async {
    final oui = normalizeMacToOui(mac);
    if (oui == null) return 'Unknown';
    if (isZeroedMac(mac)) return 'Android Device (MAC Restricted)';

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
      AppLogger.e('OUI lookup failed', error: e);
    }

    return 'Unknown';
  }

  static String? normalizeMacToOui(String mac) {
    final cleanMac = mac.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '').toUpperCase();
    if (cleanMac.length < 6) return null;
    return '${cleanMac.substring(0, 2)}:${cleanMac.substring(2, 4)}:${cleanMac.substring(4, 6)}';
  }

  static bool isZeroedMac(String mac) {
    final cleanMac = mac.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '').toUpperCase();
    return cleanMac.length == 12 && RegExp(r'^0+$').hasMatch(cleanMac);
  }

  Future<void> close() async {
    final db = _database;
    _database = null;
    _databaseFuture = null;
    await db?.close();
  }
}
