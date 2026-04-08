import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../../../core/errors/failures.dart';
import '../../../network_scan/domain/entities/network_device.dart';
import '../../../network_scan/domain/repositories/network_scan_repository.dart';
import '../../../wifi_scan/domain/services/scan_session_store.dart';
import '../../domain/entities/network_topology.dart';
import '../../domain/repositories/topology_repository.dart';
import '../../domain/services/topology_builder.dart';

@LazySingleton(as: TopologyRepository)
class TopologyRepositoryImpl implements TopologyRepository {
  final NetworkInfo _networkInfo;
  final ScanSessionStore _scanStore;
  final NetworkScanRepository _networkScanRepo;
  final TopologyBuilder _topologyBuilder;

  const TopologyRepositoryImpl(
    this._networkInfo,
    this._scanStore,
    this._networkScanRepo,
    this._topologyBuilder,
  );

  @override
  Future<Either<Failure, NetworkTopology>> getTopology() async {
    try {
      final results = await Future.wait([
        _networkInfo.getWifiIP(),
        _networkInfo.getWifiGatewayIP(),
        _networkInfo.getWifiName(),
        _networkInfo.getWifiBSSID(),
      ]);

      final currentIp = results[0];
      final gatewayIp = results[1];
      final ssid = (results[2] ?? '').replaceAll('"', '');
      final bssid = results[3];

      List<NetworkDevice> lanDevices = [];
      if (currentIp != null) {
        final subnet = currentIp.substring(0, currentIp.lastIndexOf('.'));
        final result = await _networkScanRepo.scanNetwork('$subnet.0/24');
        result.fold((_) {}, (devices) => lanDevices = devices);
      }

      final latestSnapshot = _scanStore.latest;
      final wifiNetworks = latestSnapshot?.toLegacyNetworks() ?? [];

      final topology = _topologyBuilder.build(
        wifiNetworks: wifiNetworks,
        lanDevices: lanDevices,
        currentIp: currentIp,
        gatewayIp: gatewayIp,
        connectedSsid: ssid,
        connectedBssid: bssid,
      );

      return Right(topology);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> pingNode(String ip) async {
    try {
      // Standard ICMP ping via system shell
      // -c 1: one packet
      // -W 1: 1 second timeout
      final result = await Process.run('ping', ['-c', '1', '-W', '1', ip]);
      
      if (result.exitCode == 0) {
        final output = result.stdout as String;
        // Parse time=XX.X ms
        final match = RegExp(r'time=([\d.]+)').firstMatch(output);
        if (match != null) {
          final ms = double.parse(match.group(1)!).round();
          return Right(ms);
        }
      }
      return const Left(ServerFailure('Host Unreachable'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TraceHop>>> traceRoute(String ip) async {
    try {
      // Use traceroute with max 15 hops, 1s timeout per hop
      final result = await Process.run(
        'traceroute',
        ['-m', '15', '-w', '1', ip],
      ).timeout(const Duration(seconds: 20));

      final hops = <TraceHop>[];
      final lines = (result.stdout as String).split('\n');

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.contains('*')) continue;

        final parts = trimmed.split(RegExp(r'\s+'));
        if (parts.length < 4) continue;

        final hopNumber = int.tryParse(parts[0]);
        if (hopNumber == null) continue;

        // Find IP address (often in parentheses or as a standalone string)
        String? ipAddress;
        for (final part in parts) {
          final cleanPart = part.replaceAll('(', '').replaceAll(')', '');
          if (RegExp(r'^\d{1,3}(?:\.\d{1,3}){3}$').hasMatch(cleanPart)) {
            ipAddress = cleanPart;
            break;
          }
        }

        // Find first occurrence of "ms" and get previous value
        int? latency;
        for (int i = 1; i < parts.length; i++) {
          if (parts[i] == 'ms') {
            final val = double.tryParse(parts[i - 1]);
            if (val != null) {
              latency = val.round();
              break;
            }
          }
        }

        if (ipAddress != null && latency != null) {
          hops.add(TraceHop(
            hopNumber: hopNumber,
            ip: ipAddress,
            latencyMs: latency,
          ));
        }
      }

      return Right(hops);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<int>>> scanPorts(String ip, {List<int>? ports}) async {
    final targetPorts = ports ?? [21, 22, 53, 80, 443, 3000, 8080];
    final openPorts = <int>[];

    try {
      final futures = targetPorts.map((port) async {
        try {
          final socket = await Socket.connect(ip, port, timeout: const Duration(milliseconds: 500));
          socket.destroy();
          return port;
        } catch (_) {
          return null;
        }
      });

      final results = await Future.wait(futures);
      openPorts.addAll(results.whereType<int>());
      return Right(openPorts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> reverseLookup(String ip) async {
    try {
      final addresses = await InternetAddress.lookup(ip);
      if (addresses.isNotEmpty) {
        final host = addresses.first.host;
        if (host != ip) return Right(host);
      }
      return const Left(ServerFailure('Hostname not found'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getArpInfo(String ip) async {
    try {
      // Try to get info from ARP cache
      if (Platform.isLinux || Platform.isAndroid) {
        final result = await Process.run('arp', ['-n', ip]);
        if (result.exitCode == 0) {
          final output = result.stdout as String;
          // Look for MAC address in output
          final macMatch = RegExp(r'(([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2}))').firstMatch(output);
          if (macMatch != null) {
            return Right('ARP: ${macMatch.group(1)}');
          }
        }
        
        // Fallback: Read /proc/net/arp
        final arpTable = await File('/proc/net/arp').readAsString();
        final lines = arpTable.split('\n');
        for (final line in lines) {
          if (line.contains(ip)) {
             final macMatch = RegExp(r'(([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2}))').firstMatch(line);
             if (macMatch != null) {
               return Right('ARP Cache Match: ${macMatch.group(1)}');
             }
          }
        }
      }
      return const Left(ServerFailure('ARP Info unavailable'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
