import 'package:injectable/injectable.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';

import '../../domain/entities/network_context_type.dart';

/// Persists user-supplied network-context overrides keyed by BSSID.
///
/// Inference (`NetworkContextInferrer`) runs over passive signals; users can
/// always overrule it (e.g. a coffee shop's encrypted Wi-Fi inferred as
/// `unknown` should be set to `public`). Overrides win against inference.
@lazySingleton
class NetworkContextOverrideStore {
  NetworkContextOverrideStore(this._storage);

  final HiveStorageService _storage;
  static const _prefix = 'net_ctx_';

  Future<void> set(String bssid, NetworkContextType context) async {
    await _storage.save('$_prefix${bssid.toUpperCase()}', context.name);
  }

  Future<void> remove(String bssid) async {
    await _storage.delete('$_prefix${bssid.toUpperCase()}');
  }

  Future<NetworkContextType?> get(String bssid) async {
    final raw = _storage.get<String>('$_prefix${bssid.toUpperCase()}');
    if (raw == null) return null;
    return NetworkContextType.values.firstWhere(
      (t) => t.name == raw,
      orElse: () => NetworkContextType.unknown,
    );
  }

  Future<void> clearAll() async {
    final box = _storage.box;
    final keysToRemove =
        box.keys.where((k) => k is String && k.startsWith(_prefix)).toList();
    for (final key in keysToRemove) {
      await box.delete(key);
    }
  }
}
