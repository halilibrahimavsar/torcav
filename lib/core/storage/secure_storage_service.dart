import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

/// Service for handling sensitive data encryption at rest.
/// Wraps [FlutterSecureStorage] to provide typed access and key management.
@lazySingleton
class SecureStorageService {
  const SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const String _dbKeyName = 'torcav_db_encryption_key';
  static const String _hiveBoxKeyName = 'torcav_hive_box_key';

  /// Saves a string value to secure storage.
  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Reads a string value from secure storage.
  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  /// Deletes a specific key from secure storage.
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Deletes all data from secure storage.
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Retrieves or generates a persistent encryption key for the database.
  Future<String> getDatabaseEncryptionKey() async {
    var key = await read(_dbKeyName);
    if (key == null) {
      key = const Uuid().v4();
      await save(_dbKeyName, key);
    }
    return key;
  }

  /// Retrieves or generates a 32-byte (256-bit) AES key for Hive box
  /// encryption. Returned as raw bytes; persisted as a base64 string.
  Future<List<int>> getOrCreateHiveBoxKey() async {
    final existing = await read(_hiveBoxKeyName);
    if (existing != null) {
      return base64Decode(existing);
    }
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    await save(_hiveBoxKeyName, base64Encode(bytes));
    return bytes;
  }
}
