import 'dart:io';
import 'dart:isolate';

import 'package:fpdart/fpdart.dart';
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
  Future<Either<Failure, List<ArpEntry>>> readArpTable() => readArpTableStatic();
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

  /// Deprecated: Discovers hosts in a single batch. Use [discoverHostsStream] instead.
  Future<Either<Failure, List<HostScanResult>>> discoverHosts({
    String? targetSubnet,
    NetworkScanProfile profile = NetworkScanProfile.fast,
  }) async {
    try {
      final hosts = await discoverHostsStream(
        targetSubnet: targetSubnet,
        profile: profile,
      ).toList();
      return Right(hosts);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }

  /// --- Isolate Worker Logic ---

  static Future<void> _discoveryIsolateWorker(_IsolateConfig config) async {
    final sendPort = config.sendPort;
    final targetSubnet = config.targetSubnet;
    final profile = config.profile;

    try {
      final List<ArpEntry> finalArpEntries = [];
      
      final arpResult = await readArpTableStatic();
      arpResult.fold((_) => null, (entries) => finalArpEntries.addAll(entries));

      if (finalArpEntries.isNotEmpty) {
        // We have ARP table entries, this is fast. Process them concurrently in batches
        const parallelBatches = 10;
        for (var i = 0; i < finalArpEntries.length; i += parallelBatches) {
          final futures = <Future<void>>[];
          for (var j = 0; j < parallelBatches; j++) {
            if (i + j >= finalArpEntries.length) break;
            futures.add(_processAndSendEntry(finalArpEntries[i+j], profile, sendPort));
          }
          await Future.wait(futures);
        }
      } else if (targetSubnet != null) {
        // Fallback for Android (where ARP table is restricted)
        final parts = targetSubnet.split('/');
        if (parts.isNotEmpty) {
          final ip = parts[0];
          if (ip.split('.').length == 4) {
            final baseIp = ip.substring(0, ip.lastIndexOf('.'));
            const parallelBatches = 30; // Increased batch size for faster discovery

            for (var i = 1; i < 255; i += parallelBatches) {
              final futures = <Future<void>>[];
              for (var j = 0; j < parallelBatches; j++) {
                final hostPart = i + j;
                if (hostPart > 254) break;
                
                futures.add(() async {
                   final entry = await _pingHostStatic('$baseIp.$hostPart');
                   if (entry != null) {
                     await _processAndSendEntry(entry, profile, sendPort);
                   }
                }());
              }
              await Future.wait(futures);
            }
          }
        }
      }
    } catch (e) {
      sendPort.send(ScanFailure(e.toString()));
    } finally {
      sendPort.send('DONE');
    }
  }

  static Future<void> _processAndSendEntry(ArpEntry entry, NetworkScanProfile profile, SendPort sendPort) async {
    final services = <ServiceFingerprint>[];

    // Only probe ports for non-fast profiles.
    if (profile != NetworkScanProfile.fast) {
      services.addAll(await _probePortsStatic(entry.ip));
    }

    // Send partial result back to main thread immediately
    sendPort.send(HostScanResult(
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
    ));
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

        entries.add(ArpEntry(
          ip: ip, 
          mac: mac, 
          vendor: mac == '00:00:00:00:00:00' ? 'Android Device (Restricted)' : 'Unknown',
        ));
      }
      return Right(entries);
    } catch (e) {
      return Left(ScanFailure('Failed to read /proc/net/arp: $e'));
    }
  }

  static Future<List<ServiceFingerprint>> _probePortsStatic(String ip) async {
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
      futures.add(_probePortStatic(ip, entry.key, entry.value));
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
    } catch (e) {
      return null;
    }
  }



  static Future<ArpEntry?> _pingHostStatic(String ip) async {
    try {
      final watch = Stopwatch()..start();
      final result = await Process.run('ping', ['-c', '1', '-W', '1', ip]);
      watch.stop();
      if (result.exitCode == 0) {
        return ArpEntry(
          ip: ip,
          mac: '00:00:00:00:00:00',
          vendor: 'Unknown (Android Limited)',
          latency: watch.elapsedMilliseconds.toDouble(),
        );
      }
    } catch (_) {}
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

