import 'dart:io';
import 'dart:isolate';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/oui_lookup.dart';
import '../../domain/entities/arp_entry.dart';
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
  final OuiLookup _ouiLookup;

  ArpDataSource(this._ouiLookup);

  /// Reads the ARP table. Wrapper for static method to allow injection and mocking.
  Future<Either<Failure, List<ArpEntry>>> readArpTable() =>
      readArpTableStatic();
  Stream<HostScanResult> discoverHostsStream({
    String? targetSubnet,
    NetworkScanProfile profile = NetworkScanProfile.fast,
  }) async* {
    final receivePort = ReceivePort();

    // Spawn isolate for heavy scanning work
    final isolate = await Isolate.spawn(
      _discoveryIsolateWorker,
      _IsolateConfig(
        sendPort: receivePort.sendPort,
        targetSubnet: targetSubnet,
        profile: profile,
      ),
    );

    try {
      await for (final message in receivePort) {
        if (message is HostScanResult) {
          // Resolve vendor and device type in the main thread to avoid Isolate DI issues
          final vendor = await _ouiLookup.lookup(message.mac);
          final deviceType = _guessDeviceType(
            services: message.services,
            vendor: vendor,
          );
          yield message.copyWith(
            vendor: vendor,
            deviceType: deviceType,
            isGateway: deviceType == 'Router/Gateway',
          );
        } else if (message == 'DONE') {
          break;
        } else if (message is Failure) {
          // For streams, we could yield an error or just stop.
          // Here we'll just log and continue if one host fails.
          continue;
        }
      }
    } finally {
      receivePort.close();
      isolate.kill(priority: Isolate.immediate);
    }
  }

  /// --- Isolate Worker Logic ---

  static Future<void> _discoveryIsolateWorker(_IsolateConfig config) async {
    final sendPort = config.sendPort;
    final targetSubnet = config.targetSubnet;
    final profile = config.profile;

    try {
      final canReadArp = Platform.isLinux;
      final baseIp = _extractBaseIp(targetSubnet);

      // Step 1: Ping-sweep the subnet to populate the kernel ARP cache.
      // Batch size and parallelism vary by profile to create meaningful speed differences:
      //   fast       – large batches (50), short ICMP timeout (500ms) → ~3-5 s
      //   balanced   – medium batches (30), 1 s ICMP timeout → ~8-10 s
      //   aggressive – small batches (15), 2 s ICMP timeout → slower but catches more hosts
      final liveIps = <String, double>{};
      if (baseIp != null) {
        final parallelBatches = switch (profile) {
          NetworkScanProfile.fast => 50,
          NetworkScanProfile.balanced => 30,
          NetworkScanProfile.aggressive => 15,
        };
        final pingTimeoutSec = switch (profile) {
          NetworkScanProfile.fast => '1',
          NetworkScanProfile.balanced => '1',
          NetworkScanProfile.aggressive => '2',
        };
        for (var i = 1; i < 255; i += parallelBatches) {
          final futures = <Future<_PingResult?>>[];
          for (var j = 0; j < parallelBatches; j++) {
            final hostPart = i + j;
            if (hostPart > 254) break;
            futures.add(_pingResultStatic('$baseIp.$hostPart', pingTimeoutSec: pingTimeoutSec));
          }
          final results = await Future.wait(futures);
          for (final r in results) {
            if (r != null) liveIps[r.ip] = r.latencyMs;
          }
        }
      }

      // Step 2: Merge with kernel ARP cache. On Linux we now have real MACs
      // for every live host; on Android /proc/net/arp is empty (API 30+) so
      // we fall back to zero MACs and rely on mDNS/UPnP/NetBIOS for identity.
      final entriesByIp = <String, ArpEntry>{};
      if (canReadArp) {
        final arpResult = await readArpTableStatic();
        arpResult.fold((_) => null, (arpEntries) {
          for (final e in arpEntries) {
            if (e.mac != '00:00:00:00:00:00') entriesByIp[e.ip] = e;
          }
        });
      }

      for (final entry in liveIps.entries) {
        final existing = entriesByIp[entry.key];
        if (existing == null) {
          entriesByIp[entry.key] = ArpEntry(
            ip: entry.key,
            mac: '00:00:00:00:00:00',
            vendor: canReadArp ? 'Unknown' : 'Unknown (Android Limited)',
            latency: entry.value,
          );
        } else if (existing.latency == 0) {
          entriesByIp[entry.key] = ArpEntry(
            ip: existing.ip,
            mac: existing.mac,
            vendor: existing.vendor,
            latency: entry.value,
          );
        }
      }

      // Fallback: ARP-only discovery if ping sweep couldn't run (no subnet).
      if (entriesByIp.isEmpty && canReadArp) {
        final arpResult = await readArpTableStatic();
        arpResult.fold((_) => null, (arpEntries) {
          for (final e in arpEntries) {
            entriesByIp[e.ip] = e;
          }
        });
      }

      // Step 3: Probe each discovered host concurrently.
      final allEntries = entriesByIp.values.toList();
      const probeBatches = 10;
      for (var i = 0; i < allEntries.length; i += probeBatches) {
        final futures = <Future<void>>[];
        for (var j = 0; j < probeBatches; j++) {
          if (i + j >= allEntries.length) break;
          futures.add(
            _processAndSendEntry(allEntries[i + j], profile, sendPort),
          );
        }
        await Future.wait(futures);
      }
    } catch (e) {
      sendPort.send(ScanFailure(e.toString()));
    } finally {
      sendPort.send('DONE');
    }
  }

  static String? _extractBaseIp(String? targetSubnet) {
    if (targetSubnet == null) return null;
    final ip = targetSubnet.split('/').first;
    final parts = ip.split('.');
    if (parts.length != 4) return null;
    return ip.substring(0, ip.lastIndexOf('.'));
  }

  static Future<void> _processAndSendEntry(
    ArpEntry entry,
    NetworkScanProfile profile,
    SendPort sendPort,
  ) async {
    final services = <ServiceFingerprint>[];

    if (profile == NetworkScanProfile.balanced) {
      // 10-port quick probe with 500ms timeout
      services.addAll(await _probePortsStatic(entry.ip, timeoutMs: 500));
    } else if (profile == NetworkScanProfile.aggressive) {
      // Extended 10-port probe with 1000ms timeout for better coverage
      services.addAll(await _probePortsStatic(entry.ip, timeoutMs: 1000));
    }
    // fast: no port probe during discovery – on-demand scan handles this

    // Send partial result back to main thread immediately
    sendPort.send(
      HostScanResult(
        ip: entry.ip,
        mac: entry.mac,
        vendor: entry.vendor, // 'Unknown' for now
        hostName: '',
        osGuess: '',
        latency: entry.latency,
        services: services,
        exposureFindings: const [],
        exposureScore: (services.length * 7).toDouble().clamp(0, 100),
        deviceType: 'Unknown',
        isGateway: false,
      ),
    );
  }

  static Future<Either<Failure, List<ArpEntry>>> readArpTableStatic() async {
    try {
      final file = File('/proc/net/arp');
      if (!await file.exists()) return const Right([]);

      final lines = await file.readAsLines();
      if (lines.length <= 1) return const Right([]);

      final entries = <ArpEntry>[];
      for (var i = 1; i < lines.length; i++) {
        final parts = lines[i].split(RegExp(r'\s+'));
        if (parts.length < 4) continue;

        final ip = parts[0];
        final mac = parts[3].toUpperCase();

        entries.add(
          ArpEntry(
            ip: ip,
            mac: mac,
            vendor:
                mac == '00:00:00:00:00:00'
                    ? 'Android Device (Restricted)'
                    : 'Unknown',
          ),
        );
      }
      return Right(entries);
    } catch (e) {
      return Left(ScanFailure('Failed to read /proc/net/arp: $e'));
    }
  }

  static Future<List<ServiceFingerprint>> _probePortsStatic(
    String ip, {
    int timeoutMs = 500,
  }) async {
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
      futures.add(_probePortStatic(ip, entry.key, entry.value, timeoutMs: timeoutMs));
    }

    final probed = await Future.wait(futures);
    for (final service in probed) {
      if (service != null) results.add(service);
    }
    return results;
  }

  static Future<ServiceFingerprint?> _probePortStatic(
    String ip,
    int port,
    String serviceName, {
    int timeoutMs = 500,
  }) async {
    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: Duration(milliseconds: timeoutMs),
      );
      await socket.close();
      return ServiceFingerprint(
        port: port,
        protocol: 'tcp',
        serviceName: serviceName,
        product: '',
        version: '',
      );
    } catch (e) {
      return null;
    }
  }

  static Future<_PingResult?> _pingResultStatic(
    String ip, {
    String pingTimeoutSec = '1',
  }) async {
    try {
      final watch = Stopwatch()..start();
      final result = await Process.run('ping', ['-c', '1', '-W', pingTimeoutSec, ip]);
      watch.stop();
      if (result.exitCode == 0) {
        return _PingResult(ip: ip, latencyMs: watch.elapsedMilliseconds.toDouble());
      }
    } catch (_) {}
    // TCP fallback for hosts that block ICMP (Windows firewall, iOS).
    const fallbackPorts = [80, 443, 22, 445];
    for (final port in fallbackPorts) {
      try {
        final watch = Stopwatch()..start();
        final socket = await Socket.connect(ip, port, timeout: const Duration(milliseconds: 400));
        watch.stop();
        socket.destroy();
        return _PingResult(ip: ip, latencyMs: watch.elapsedMilliseconds.toDouble());
      } catch (_) {}
    }
    return null;
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
}

class _IsolateConfig {
  final SendPort sendPort;
  final String? targetSubnet;
  final NetworkScanProfile profile;

  _IsolateConfig({
    required this.sendPort,
    this.targetSubnet,
    required this.profile,
  });
}

class _PingResult {
  final String ip;
  final double latencyMs;

  _PingResult({required this.ip, required this.latencyMs});
}
