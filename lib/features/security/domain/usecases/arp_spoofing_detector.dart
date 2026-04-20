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
              final oui = _ouiPrefix(mac);
              return SecurityEvent(
                type: SecurityEventType.arpSpoofingDetected,
                severity: SecurityEventSeverity.critical,
                ssid: '',
                bssid: mac,
                timestamp: DateTime.now(),
                evidence:
                    'Gateway IP $gatewayIp shares MAC OUI $oui with ${ips.length} addresses. Possible ARP poisoning.',
              );
            }
          }
        }

        return null;
      },
    );
  }

  /// Returns the first 3 octets (OUI prefix) of a MAC address, e.g. "AA:BB:CC".
  static String _ouiPrefix(String mac) {
    final parts = mac.split(':');
    return parts.length >= 3 ? parts.sublist(0, 3).join(':') : mac;
  }
}
