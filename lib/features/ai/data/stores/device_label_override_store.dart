import 'package:injectable/injectable.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';

/// Persists user-supplied device-type corrections keyed by MAC address.
/// Overrides are stored in Hive under the prefix `ai_label_`.
@lazySingleton
class DeviceLabelOverrideStore {
  DeviceLabelOverrideStore(this._storage);

  final HiveStorageService _storage;
  static const _prefix = 'ai_label_';

  Future<void> set(String mac, String deviceType) async {
    await _storage.save('$_prefix${mac.toUpperCase()}', deviceType);
  }

  Future<void> remove(String mac) async {
    await _storage.delete('$_prefix${mac.toUpperCase()}');
  }

  Future<String?> get(String mac) async {
    return _storage.get<String>('$_prefix${mac.toUpperCase()}');
  }

  Future<Map<String, String>> getAll() async {
    // In Hive, we'd need to iterate or use a separate box for this to be efficient.
    // For now, since we're using a single box, we'll iterate.
    final result = <String, String>{};
    final box = _storage.box;
    for (final key in box.keys) {
      if (key is String && key.startsWith(_prefix)) {
        final mac = key.substring(_prefix.length);
        result[mac] = box.get(key) as String;
      }
    }
    return result;
  }

  Future<void> clearAll() async {
    final box = _storage.box;
    final keysToRemove = box.keys.where((k) => k is String && k.startsWith(_prefix)).toList();
    for (final key in keysToRemove) {
      await box.delete(key);
    }
  }
}

