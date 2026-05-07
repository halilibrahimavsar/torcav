import 'package:injectable/injectable.dart';

import '../entities/security_event.dart';
import '../entities/trusted_network_profile.dart';

/// Compares the current gateway IP against the one captured when the user
/// trusted the network. A swap usually means one of:
///   1. Router replaced legitimately (user knows about it)
///   2. The user moved to a different LAN segment that *also* claims
///      the same SSID (rare but possible — captive portals, mesh hubs).
///   3. **A rogue DHCP server is impersonating the gateway.** Classic
///      MITM stage-1: the attacker hands out their own IP as the
///      gateway, then proxies traffic.
///
/// We can't tell those three apart on signal alone, so we surface a
/// medium-severity event and let the user decide. Re-trusting the
/// network from the security center clears the warning.
@lazySingleton
class GatewayDriftDetector {
  const GatewayDriftDetector();

  /// Returns a [SecurityEvent] when the current gateway differs from the
  /// trusted profile's saved gateway. Null if there is no baseline, or if
  /// the values match.
  SecurityEvent? check({
    required String? currentGateway,
    required TrustedNetworkProfile? trusted,
  }) {
    if (trusted == null) return null;
    final baseline = trusted.gateway;
    if (baseline == null || baseline.isEmpty) return null;
    if (currentGateway == null || currentGateway.isEmpty) return null;
    if (baseline == currentGateway) return null;

    return SecurityEvent(
      type: SecurityEventType.evilTwinDetected,
      severity: SecurityEventSeverity.high,
      ssid: trusted.ssid,
      bssid: trusted.bssid,
      timestamp: DateTime.now(),
      evidence:
          'Gateway changed: trusted baseline reported $baseline, '
          'current gateway is $currentGateway. This can mean a router '
          'replacement, a different LAN, or a rogue DHCP server.',
    );
  }
}
