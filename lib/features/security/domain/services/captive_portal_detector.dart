import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../entities/security_event.dart';

enum CaptivePortalStatus { clean, detected, unknown }

/// Probes for a captive portal by requesting the standard Google connectivity
/// check endpoint. A response other than 204 indicates a portal is redirecting
/// traffic.
@lazySingleton
class CaptivePortalDetector {
  final NetworkInfo _networkInfo;

  CaptivePortalDetector(this._networkInfo);

  /// Returns the current captive portal status and, if detected, a
  /// pre-built [SecurityEvent] ready to be persisted.
  Future<({CaptivePortalStatus status, SecurityEvent? event})> check() async {
    try {
      final ssid = await _networkInfo.getWifiName() ?? '';
      final bssid = await _networkInfo.getWifiBSSID() ?? '';

      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(
        Uri.parse('http://connectivitycheck.gstatic.com/generate_204'),
      );
      final response = await request.close().timeout(
        const Duration(seconds: 5),
      );
      await response.drain<void>();
      client.close();

      if (response.statusCode == 204) {
        return (status: CaptivePortalStatus.clean, event: null);
      }

      // Any redirect or non-204 response indicates a captive portal.
      final event = SecurityEvent(
        type: SecurityEventType.captivePortalDetected,
        severity: SecurityEventSeverity.warning,
        ssid: ssid.replaceAll('"', ''),
        bssid: bssid.toUpperCase(),
        timestamp: DateTime.now(),
        evidence:
            'Connectivity check returned HTTP ${response.statusCode} '
            '(expected 204). A captive portal is redirecting traffic.',
      );
      return (status: CaptivePortalStatus.detected, event: event);
    } catch (_) {
      return (status: CaptivePortalStatus.unknown, event: null);
    }
  }
}
