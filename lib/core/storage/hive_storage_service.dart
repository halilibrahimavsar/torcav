import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../logging/app_logger.dart';

/// Service for handling non-sensitive persistent app state.
/// Wraps [Hive] as a modern, high-performance alternative to SharedPreferences.
///
/// All boxes are encrypted at rest with a 256-bit AES key provided by the
/// caller; the key itself is held in `flutter_secure_storage`.
@lazySingleton
class HiveStorageService {
  static const String _defaultBoxName = 'torcav_preferences';

  /// Marker written on every successful open, so a later open can tell
  /// "empty because it is a fresh install" from "empty because the key
  /// changed".
  static const String _canaryKey = '__torcav_cipher_canary';
  static const String _canaryValue = 'ok';

  /// Initializes Hive for Flutter and opens the default box with AES
  /// encryption.
  ///
  /// Recovering from a cipher mismatch is not as simple as catching an
  /// exception: **Hive does not throw when the key is wrong.** It logs
  /// "Recovering corrupted box" and hands back an *empty* box, which is
  /// indistinguishable from a first launch. Left alone, a secure-storage
  /// reset silently wipes the user's preferences back to defaults while the
  /// old encrypted file stays on disk forever.
  ///
  /// So the mismatch is detected by canary instead: every successful open
  /// writes a marker, and a box that opens empty *and* has a file on disk
  /// larger than a fresh one must have failed to decrypt. That box is
  /// deleted and recreated, which is the same outcome the old comment
  /// promised — this time it actually happens.
  static Future<void> init(List<int> encryptionKey) async {
    await Hive.initFlutter();
    final cipher = HiveAesCipher(encryptionKey);

    Future<void> openFresh() async {
      await Hive.deleteBoxFromDisk(_defaultBoxName);
      final box = await Hive.openBox(_defaultBoxName, encryptionCipher: cipher);
      await box.put(_canaryKey, _canaryValue);
    }

    // Measured BEFORE opening: when Hive fails to decrypt it logs
    // "Recovering corrupted box" and truncates the file to zero, so asking
    // afterwards always answers "empty" and the mismatch becomes invisible.
    final hadStoredData = await _hasStoredData();

    Box box;
    try {
      box = await Hive.openBox(_defaultBoxName, encryptionCipher: cipher);
    } catch (e, stack) {
      AppLogger.e(
        'Hive box open threw; deleting and recreating',
        error: e,
        stackTrace: stack,
      );
      await openFresh();
      return;
    }

    if (box.get(_canaryKey) == _canaryValue) return;

    // No canary. Either a genuinely fresh box, or one we just failed to
    // decrypt. An empty box is fine either way; a box that reports empty
    // while data exists on disk is the mismatch case.
    if (box.isEmpty && !hadStoredData) {
      await box.put(_canaryKey, _canaryValue);
      return;
    }

    AppLogger.e(
      'Hive cipher mismatch: box opened empty but data exists on disk. '
      'Recreating — local preferences will reset.',
    );
    await box.close();
    await openFresh();
  }

  /// Whether the box file on disk holds any records.
  ///
  /// Measured, not guessed: a never-written Hive box is **0 bytes**, the
  /// canary alone is 64, and one further record is 110. So any non-zero
  /// length means records exist — and after a failed decrypt Hive truncates
  /// the file back to 0, which is why this has to be read before opening.
  static Future<bool> _hasStoredData() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_defaultBoxName.hive');
      if (!file.existsSync()) return false;
      return await file.length() > 0;
    } catch (_) {
      // Cannot tell — assume fresh rather than destroying readable data.
      return false;
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
