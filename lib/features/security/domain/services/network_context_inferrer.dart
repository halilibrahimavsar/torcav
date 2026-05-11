import 'package:injectable/injectable.dart';

import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import '../entities/network_context_type.dart';
import '../entities/trusted_network_profile.dart';

/// Infers a [NetworkContextType] from observable signals.
///
/// Order of precedence:
///   1. User override (resolved upstream — not handled here).
///   2. Trusted profile present → [NetworkContextType.home].
///   3. Open / suspicious SSID → [NetworkContextType.public].
///   4. Otherwise → [NetworkContextType.unknown].
///
/// `guest` is not auto-inferred yet; it requires explicit user selection
/// (planned in onboarding / per-network settings).
@lazySingleton
class NetworkContextInferrer {
  const NetworkContextInferrer();

  NetworkContextType infer(
    WifiNetwork network, {
    TrustedNetworkProfile? trustedProfile,
  }) {
    if (trustedProfile != null) return NetworkContextType.home;

    if (network.security == SecurityType.open) return NetworkContextType.public;
    if (_matchesPublicSsidPattern(network.ssid))
      return NetworkContextType.public;

    return NetworkContextType.unknown;
  }

  static const _publicSsidPatterns = [
    'free wifi',
    'free internet',
    'free wi-fi',
    'airport wifi',
    'airport free',
    'hotel wifi',
    'hotel free',
    'starbucks free',
    'mcdonalds free',
    'open wifi',
    'open network',
    'public wifi',
    'public free',
    'guest free',
    'free hotspot',
    'wifi free',
    'internet free',
    'xfinity wifi',
  ];

  bool _matchesPublicSsidPattern(String ssid) {
    if (ssid.isEmpty) return false;
    final lower = ssid.toLowerCase().trim();
    return _publicSsidPatterns.any(
      (pattern) => lower == pattern || lower.contains(pattern),
    );
  }
}
