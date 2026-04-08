import 'package:injectable/injectable.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../../network_scan/data/datasources/arp_data_source.dart';
import '../entities/security_event.dart';

@lazySingleton
class ArpSpoofingDetector {
  final ArpDataSource _arpDataSource;
  final NetworkInfo _networkInfo = NetworkInfo();

  ArpSpoofingDetector(this._arpDataSource);

  /// Analyzes the current ARP table for spoofing signatures.
  ///
  /// Returns a [SecurityEvent] if spoofing is detected, otherwise null.
  Future<SecurityEvent?> check() async {
    final gatewayIp = await _networkInfo.getWifiGatewayIP();
    if (gatewayIp == null) return null;

    final arpResult = await _arpDataSource.readArpTable();
    return arpResult.fold(
      (failure) => null, // Cannot read ARP table on this platform
      (entries) {
        if (entries.isEmpty) return null;

        // 1. Check for Duplicate MAC addresses (MAC Poisoning/Spoofing)
        // multiple IPs sharing the same MAC.
        final macToIps = <String, List<String>>{};
        for (final entry in entries) {
          if (entry.mac == '00:00:00:00:00:00') continue;
          macToIps.putIfAbsent(entry.mac, () => []).add(entry.ip);
        }

        for (final mac in macToIps.keys) {
          final ips = macToIps[mac]!;
          if (ips.length > 1) {
            // Check if one of these IPs is the gateway
            final isGatewayInvolved = ips.contains(gatewayIp);
            
            if (isGatewayInvolved) {
              return SecurityEvent(
                type: SecurityEventType.arpSpoofingDetected,
                severity: SecurityEventSeverity.critical,
                ssid: '', // SSID not directly available here
                bssid: mac,
                timestamp: DateTime.now(),
                evidence: 'Multiple IPs (${ips.join(", ")}) share the same MAC address as the Gateway ($gatewayIp). High probability of ARP poisoning.',
              );
            }
          }
        }

        return null;
      },
    );
  }
}
