import 'dart:io';
import 'dart:isolate';

import 'package:injectable/injectable.dart';

import '../../../../core/utils/oui_lookup.dart';
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
    // Offload the heavy process spawning and port probing to a background isolate
    // so the main UI thread never freezes.
    return Isolate.run(() async {
      final source = ArpDataSource();
      return source._discoverHostsInternal(
        targetSubnet: targetSubnet,
        profile: profile,
      );
    });
  }

  Future<List<HostScanResult>> _discoverHostsInternal({
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
          exposureFindings: const [],
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
    // Delegate to the centralised OUI table in core/utils.
    return OuiLookup.getVendor(mac);
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

  // Vendor guessing is now fully delegated to OuiLookup in core/utils.

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
