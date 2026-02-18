import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../domain/entities/host_scan_result.dart';
import '../../domain/entities/network_scan_profile.dart';
import '../../domain/entities/service_fingerprint.dart';

/// Fallback data source for Android and other non-Linux platforms.
///
/// Reads `/proc/net/arp` to discover hosts on the local network,
/// then probes common ports via basic TCP socket connections for
/// service and device-type guessing.
@LazySingleton()
class ArpDataSource {
  /// Discovers hosts via the ARP table and optional port probing.
  Future<List<HostScanResult>> discoverHosts({
    String? targetSubnet,
    NetworkScanProfile profile = NetworkScanProfile.fast,
  }) async {
    var arpEntries = await _readArpTable();

    // Fallback for Android (where ARP table is restricted)
    if (arpEntries.isEmpty && targetSubnet != null) {
      arpEntries = await _pingScanSubnet(targetSubnet);
    }

    if (arpEntries.isEmpty) return [];

    final hosts = <HostScanResult>[];

    for (final entry in arpEntries) {
      final services = <ServiceFingerprint>[];

      // Only probe ports for non-fast profiles.
      if (profile != NetworkScanProfile.fast) {
        services.addAll(await _probePorts(entry.ip));
      }

      final deviceType = _guessDeviceType(
        services: services,
        vendor: entry.vendor,
      );

      hosts.add(
        HostScanResult(
          ip: entry.ip,
          mac: entry.mac,
          vendor: entry.vendor,
          hostName: '',
          osGuess: '',
          latency: 0,
          services: services,
          vulnerabilities: const [],
          exposureScore: (services.length * 7).toDouble().clamp(0, 100),
          deviceType: deviceType,
        ),
      );
    }

    return hosts;
  }

  Future<List<_ArpEntry>> _readArpTable() async {
    try {
      final file = File('/proc/net/arp');
      if (!await file.exists()) return [];

      final lines = await file.readAsLines();
      // First line is the header: IP address, HW type, Flags, HW address, Mask, Device
      if (lines.length <= 1) return [];

      final entries = <_ArpEntry>[];
      for (var i = 1; i < lines.length; i++) {
        final parts = lines[i].split(RegExp(r'\s+'));
        if (parts.length < 4) continue;

        final ip = parts[0];
        final mac = parts[3].toUpperCase();

        // Skip incomplete entries (00:00:00:00:00:00)
        if (mac == '00:00:00:00:00:00') continue;

        entries.add(_ArpEntry(ip: ip, mac: mac, vendor: _guessVendor(mac)));
      }
      return entries;
    } catch (_) {
      return [];
    }
  }

  /// Quick TCP connect probes on common ports.
  Future<List<ServiceFingerprint>> _probePorts(String ip) async {
    const commonPorts = <int, String>{
      22: 'ssh',
      53: 'dns',
      80: 'http',
      443: 'https',
      445: 'microsoft-ds',
      548: 'afp',
      3389: 'ms-wbt-server',
      5000: 'upnp',
      8080: 'http-proxy',
      9100: 'jetdirect',
    };

    final results = <ServiceFingerprint>[];
    final futures = <Future<ServiceFingerprint?>>[];

    for (final entry in commonPorts.entries) {
      futures.add(_probePort(ip, entry.key, entry.value));
    }

    final probed = await Future.wait(futures);
    for (final service in probed) {
      if (service != null) results.add(service);
    }

    return results;
  }

  Future<ServiceFingerprint?> _probePort(
    String ip,
    int port,
    String serviceName,
  ) async {
    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(milliseconds: 500),
      );
      await socket.close();
      return ServiceFingerprint(
        port: port,
        protocol: 'tcp',
        serviceName: serviceName,
        product: '',
        version: '',
      );
    } catch (_) {
      return null;
    }
  }

  String _guessVendor(String mac) {
    // Simple OUI-based vendor guessing from the first 3 octets.
    final oui = mac.substring(0, 8).replaceAll(':', '-');
    return _knownOuis[oui] ?? '';
  }

  String _guessDeviceType({
    required List<ServiceFingerprint> services,
    required String vendor,
  }) {
    final lowerVendor = vendor.toLowerCase();
    if (services.any((s) => s.port == 53)) return 'Router/Gateway';
    if (lowerVendor.contains('apple')) return 'Mobile Device';
    if (services.any((s) => s.port == 9100 || s.serviceName == 'ipp')) {
      return 'Printer/IoT';
    }
    if (services.any((s) => s.port == 445 || s.port == 3389)) {
      return 'Workstation';
    }
    return 'Unknown';
  }

  static const _knownOuis = <String, String>{
    'DC-A6-32': 'Raspberry Pi',
    'B8-27-EB': 'Raspberry Pi',
    'E4-5F-01': 'Raspberry Pi',
    '00-50-56': 'VMware',
    '00-0C-29': 'VMware',
    '08-00-27': 'Oracle VirtualBox',
    'AA-BB-CC': 'TP-Link',
    '00-1A-2B': 'Cisco',
    'F8-1A-67': 'TP-Link',
    'AC-84-C6': 'TP-Link',
    '50-C7-BF': 'TP-Link',
    '00-17-88': 'Philips Hue',
    '3C-22-FB': 'Apple',
    'A4-83-E7': 'Apple',
    'F0-18-98': 'Apple',
    '78-CA-39': 'Apple',
    'DC-56-E7': 'Apple',
    'B0-BE-76': 'Samsung',
    '8C-F5-A3': 'Samsung',
    'C0-97-27': 'Samsung',
    '28-6C-07': 'Xiaomi',
    '64-CE-38': 'Xiaomi',
    '78-11-DC': 'Xiaomi',
    'FC-EC-DA': 'Amazon',
    '44-65-0D': 'Amazon',
    '68-54-FD': 'Amazon',
    '94-B4-0F': 'Google',
    '30-FD-38': 'Google',
    'F4-F5-D8': 'Google',
    'BC-DD-C2': 'Huawei',
    '00-46-4B': 'Huawei',
    '48-46-FB': 'Huawei',
  };

  Future<List<_ArpEntry>> _pingScanSubnet(String ipWithMask) async {
    final parts = ipWithMask.split('/');
    if (parts.isEmpty) return [];

    final ip = parts[0];
    // Simple logic: assume /24 by taking first 3 octets
    if (ip.split('.').length != 4) return [];
    final baseIp = ip.substring(0, ip.lastIndexOf('.'));

    final entries = <_ArpEntry>[];
    const parallelBatches = 20;

    // Scan .1 to .254
    for (var i = 1; i < 255; i += parallelBatches) {
      final futures = <Future<_ArpEntry?>>[];
      for (var j = 0; j < parallelBatches; j++) {
        final hostPart = i + j;
        if (hostPart > 254) break;
        futures.add(_pingHost('$baseIp.$hostPart'));
      }

      final results = await Future.wait(futures);
      entries.addAll(results.whereType<_ArpEntry>());
    }
    return entries;
  }

  Future<_ArpEntry?> _pingHost(String ip) async {
    try {
      // Android ping command supports these flags
      final result = await Process.run('ping', ['-c', '1', '-W', '1', ip]);
      if (result.exitCode == 0) {
        return _ArpEntry(
          ip: ip,
          mac: '00:00:00:00:00:00', // Cannot get MAC on Android 11+
          vendor: 'Unknown (Android Limited)',
        );
      }
    } catch (_) {}
    return null;
  }
}

class _ArpEntry {
  final String ip;
  final String mac;
  final String vendor;

  const _ArpEntry({required this.ip, required this.mac, required this.vendor});
}
