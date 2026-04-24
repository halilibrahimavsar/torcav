import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

/// Service for handling non-sensitive persistent app state.
/// Wraps [Hive] as a modern, high-performance alternative to SharedPreferences.
@lazySingleton
class HiveStorageService {
  static const String _defaultBoxName = 'torcav_preferences';

  /// Initializes Hive for Flutter.
  /// Should be called in main() before app launch.
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_defaultBoxName);
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
