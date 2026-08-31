import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../data/datasources/network_probe_data_source.dart';
import '../entities/security_event.dart';

enum CaptivePortalStatus { clean, detected, unknown }

/// Fetches the connectivity-check endpoint and reports its HTTP status.
///
/// Injected so the detector's decision logic can be tested without a network.
/// Returns null when the probe could not run at all.
typedef ConnectivityProbe = Future<int?> Function();

/// Probes for a captive portal by requesting the standard Google connectivity
/// check endpoint. A response other than 204 indicates a portal is redirecting
/// traffic.
@lazySingleton
class CaptivePortalDetector {
  /// Production constructor — the one `injectable` wires.
  CaptivePortalDetector(this._networkInfo, NetworkProbeDataSource probes)
    : _probe = probes.connectivityStatus;

  /// Substitutes the network probe so every [CaptivePortalStatus] can be
  /// driven deterministically. The detector's job is interpreting a status
  /// code, which needs no socket to test.
  @visibleForTesting
  CaptivePortalDetector.withProbe(this._networkInfo, this._probe);

  final NetworkInfo _networkInfo;
  final ConnectivityProbe _probe;

  Future<({CaptivePortalStatus status, SecurityEvent? event})> check() async {
    try {
      final ssid = await _networkInfo.getWifiName() ?? '';
      final bssid = await _networkInfo.getWifiBSSID() ?? '';

      final statusCode = await _probe();
      // No answer at all: offline, blocked, or timed out. We learned nothing,
      // which is not the same as "no portal".
      if (statusCode == null) {
        return (status: CaptivePortalStatus.unknown, event: null);
      }
      if (statusCode == 204) {
        return (status: CaptivePortalStatus.clean, event: null);
      }

      // Any redirect or non-204 response indicates a captive portal.
      return (
        status: CaptivePortalStatus.detected,
        event: SecurityEvent(
          type: SecurityEventType.captivePortalDetected,
          severity: SecurityEventSeverity.warning,
          ssid: ssid.replaceAll('"', ''),
          bssid: bssid.toUpperCase(),
          timestamp: DateTime.now(),
          evidence:
              'Connectivity check returned HTTP $statusCode '
              '(expected 204). A captive portal is redirecting traffic.',
        ),
      );
    } catch (_) {
      return (status: CaptivePortalStatus.unknown, event: null);
    }
  }
}
