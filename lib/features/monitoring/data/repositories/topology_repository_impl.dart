import 'dart:async';
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
      // 1. Try Standard ICMP ping first
      final result = await Process.run('ping', ['-c', '1', '-W', '1', ip]);
      
      if (result.exitCode == 0) {
        final output = result.stdout as String;
        final match = RegExp(r'time=([\d.]+)').firstMatch(output);
        if (match != null) {
          final ms = double.parse(match.group(1)!).round();
          return Right(ms);
        }
      }

      // 2. Fallback to TCP Connection check (TCP "Ping")
      // We try a few common ports to see if the host is alive
      final commonPorts = [80, 443, 22, 135, 445];
      final stopwatch = Stopwatch()..start();
      
      for (final port in commonPorts) {
        try {
          final socket = await Socket.connect(
            ip, 
            port, 
            timeout: const Duration(seconds: 1),
          );
          socket.destroy();
          stopwatch.stop();
          return Right(stopwatch.elapsedMilliseconds);
        } catch (_) {
          continue;
        }
      }

      return const Left(ServerFailure('Host Unreachable'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<int>>> scanPorts(String ip, {List<int>? ports}) async {
    final targetPorts = ports ?? [21, 22, 53, 80, 443, 3000, 8080];
    final openPorts = <int>[];

    try {
      // Use shorter timeout for scanning to keep it responsive
      final futures = targetPorts.map((port) async {
        try {
          final socket = await Socket.connect(
            ip, 
            port, 
            timeout: const Duration(milliseconds: 300),
          );
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
  Future<Either<Failure, String>> detectOsFromTtl(String ip) async {
    try {
      final result = await Process.run('ping', ['-c', '1', '-W', '1', ip]);
      if (result.exitCode == 0) {
        final output = result.stdout as String;
        final ttlMatch = RegExp(r'ttl=(\d+)', caseSensitive: false).firstMatch(output);
        if (ttlMatch != null) {
          final ttl = int.parse(ttlMatch.group(1)!);
          if (ttl >= 240) return const Right('Network Device (TTL≈255)');
          if (ttl >= 110) return const Right('Windows (TTL≈128)');
          if (ttl >= 50) return const Right('Linux / macOS (TTL≈64)');
          return const Right('Unknown OS');
        }
      }
      return const Left(ServerFailure('Could not determine OS'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }



}
