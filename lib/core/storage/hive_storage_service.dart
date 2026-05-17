import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import '../logging/app_logger.dart';

/// Service for handling non-sensitive persistent app state.
/// Wraps [Hive] as a modern, high-performance alternative to SharedPreferences.
///
/// All boxes are encrypted at rest with a 256-bit AES key provided by the
/// caller; the key itself is held in `flutter_secure_storage`.
@lazySingleton
class HiveStorageService {
  static const String _defaultBoxName = 'torcav_preferences';

  /// Initializes Hive for Flutter and opens the default box with AES
  /// encryption. If the existing box cannot be decrypted with [encryptionKey]
  /// (cipher mismatch, e.g. after a secure-storage reset) the box files are
  /// deleted and recreated cleanly so the app can keep running.
  static Future<void> init(List<int> encryptionKey) async {
    await Hive.initFlutter();
    final cipher = HiveAesCipher(encryptionKey);
    try {
      await Hive.openBox(_defaultBoxName, encryptionCipher: cipher);
    } catch (e, stack) {
      AppLogger.e(
        'Hive box open failed; deleting and recreating',
        error: e,
        stackTrace: stack,
      );
      await Hive.deleteBoxFromDisk(_defaultBoxName);
      await Hive.openBox(_defaultBoxName, encryptionCipher: cipher);
    }
  }

  Box get box {
    if (!Hive.isBoxOpen(_defaultBoxName)) {
      // Hive'ın `BoxNotFound` mesajı yerine bootstrap context'ini verir.
      // Production'da hiç tetiklenmemeli; test/refactor regression'larında
      // erken sinyal verir.
      throw StateError(
        'HiveStorageService.init() not called before accessing storage. '
        'Bootstrap order: SecureStorage → HiveStorageService.init → '
        'configureDependencies.',
      );
    }
    return Hive.box(_defaultBoxName);
  }

  /// Saves a value to the default box.
  Future<void> save(String key, dynamic value) async {
    await box.put(key, value);
  }

  /// Retrieves a value from the default box with safety guards.
  T? get<T>(String key, {T? defaultValue}) {
    try {
      final value = box.get(key, defaultValue: defaultValue);
      if (value == null) return null;
      if (value is! T) {
        AppLogger.w('Hive type mismatch for key $key: expected $T, got ${value.runtimeType}');
        return defaultValue;
      }
      return value;
    } catch (e) {
      AppLogger.e('Hive read error for key $key', error: e);
      return defaultValue;
    }
  }

  /// Deletes a key from the default box.
  Future<void> delete(String key) async {
    await box.delete(key);
  }

  /// Clears all data from the default box.
  Future<void> clearAll() async {
    await box.clear();
  }
}
