import 'package:injectable/injectable.dart';

import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/core/settings/app_settings_store.dart';
import '../../data/stores/network_context_override_store.dart';
import 'package:torcav/core/network/network_context_type.dart';
import '../entities/trusted_network_profile.dart';
import 'network_context_inferrer.dart';

/// Resolves a network's context, giving user overrides precedence over
/// passive inference.
///
/// Lookup order:
///   1. User override stored against the BSSID.
///   2. [NetworkContextInferrer] (trusted profile / open / lure SSID).
///   3. User's onboarding-declared default (settings).
///   4. `unknown` fallback.
@lazySingleton
class NetworkContextResolver {
  NetworkContextResolver(
    this._inferrer,
    this._overrideStore,
    this._settingsStore,
  );

  final NetworkContextInferrer _inferrer;
  final NetworkContextOverrideStore _overrideStore;
  final AppSettingsStore _settingsStore;

  Future<NetworkContextType> resolve(
    WifiNetwork network, {
    TrustedNetworkProfile? trustedProfile,
  }) async {
    final override = await _overrideStore.get(network.bssid);
    if (override != null) return override;
    final inferred = _inferrer.infer(network, trustedProfile: trustedProfile);
    if (inferred != NetworkContextType.unknown) return inferred;
    // Inferrer couldn't classify → fall back to the user's onboarding choice.
    return _settingsStore.value.defaultNetworkContext;
  }

  Future<void> setOverride(String bssid, NetworkContextType context) =>
      _overrideStore.set(bssid, context);

  Future<void> clearOverride(String bssid) => _overrideStore.remove(bssid);
}
