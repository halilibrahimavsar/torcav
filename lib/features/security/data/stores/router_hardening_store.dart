import 'package:injectable/injectable.dart';

import 'package:torcav/core/storage/hive_storage_service.dart';
import '../../domain/entities/hardening_check.dart';

/// Persists the user's router hardening progress per BSSID.
///
/// Stored as a comma-separated list of [HardeningCheck] enum names under
/// `router_harden_<BSSID>`.
@lazySingleton
class RouterHardeningStore {
  RouterHardeningStore(this._storage);

  final HiveStorageService _storage;
  static const _prefix = 'router_harden_';

  String _key(String bssid) => '$_prefix${bssid.toUpperCase()}';

  Future<Set<HardeningCheck>> get(String bssid) async {
    final raw = _storage.get<String>(_key(bssid));
    if (raw == null || raw.isEmpty) return <HardeningCheck>{};
    final result = <HardeningCheck>{};
    for (final name in raw.split(',')) {
      for (final value in HardeningCheck.values) {
        if (value.name == name) {
          result.add(value);
          break;
        }
      }
    }
    return result;
  }

  Future<void> set(String bssid, Set<HardeningCheck> checks) async {
    final encoded = checks.map((c) => c.name).join(',');
    await _storage.save(_key(bssid), encoded);
  }

  Future<void> clear(String bssid) async {
    await _storage.delete(_key(bssid));
  }

  /// Removes hardening progress for every BSSID — used by the global
  /// "Wipe All Local Data" flow.
  Future<void> clearAll() async {
    final box = _storage.box;
    final keysToRemove = box.keys
        .where((k) => k is String && k.startsWith(_prefix))
        .toList();
    for (final key in keysToRemove) {
      await box.delete(key);
    }
  }
}
