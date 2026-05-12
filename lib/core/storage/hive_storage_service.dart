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

  Box get box => Hive.box(_defaultBoxName);

  /// Saves a value to the default box.
  Future<void> save(String key, dynamic value) async {
    await box.put(key, value);
  }

  /// Retrieves a value from the default box.
  T? get<T>(String key, {T? defaultValue}) {
    return box.get(key, defaultValue: defaultValue) as T?;
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
