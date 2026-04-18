import 'dart:io';
import 'package:injectable/injectable.dart';
import '../entities/security_event.dart';

@lazySingleton
class DnsSecurityUseCase {
  /// Analyzes the system DNS settings and query results for hijacking signatures.
  ///
  /// Logic:
  /// 1. Check for NXDOMAIN hijacking (ISP/Router redirecting non-existent domains).
  /// 2. Verify common domain (google.com) resolution.
  Future<SecurityEvent?> check() async {
    const canaryDomain = 'google.com';
    final nonExistentDomain =
        'this-should-nxdomain-torcav-${DateTime.now().millisecondsSinceEpoch}.com';

    try {
      // 1. Check if non-existent domains resolve to an IP (NXDOMAIN hijacking)
      try {
        final nxResult = await InternetAddress.lookup(nonExistentDomain);
        if (nxResult.isNotEmpty) {
          return SecurityEvent(
            type: SecurityEventType.dnsHijackingDetected,
            severity: SecurityEventSeverity.medium,
            ssid: '',
            bssid: '',
            timestamp: DateTime.now(),
            evidence:
                'NXDOMAIN hijacking detected. Non-existent domain resolved to ${nxResult.map((a) => a.address).join(", ")}. This is common for ISP ad-injection or captive portals.',
          );
        }
      } on SocketException {
        // Expected behavior: domain not found
      }

      // 2. Perform a basic resolution of a trusted domain
      final googleIps = await InternetAddress.lookup(canaryDomain);
      if (googleIps.isEmpty) {
        return SecurityEvent(
          type: SecurityEventType.dnsHijackingDetected,
          severity: SecurityEventSeverity.high,
          ssid: '',
          bssid: '',
          timestamp: DateTime.now(),
          evidence:
              'DNS Resolution failed for $canaryDomain. Possible network obstruction or DNS failure.',
        );
      }

      return null;
    } catch (e) {
      // Silent fail for detection heuristics
      return null;
    }
  }
}
