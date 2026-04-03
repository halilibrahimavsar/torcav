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
}
