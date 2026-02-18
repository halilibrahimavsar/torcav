import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/host_scan_result.dart';
import '../../domain/entities/network_device.dart';
import '../../domain/entities/network_scan_profile.dart';
import '../../domain/repositories/network_scan_repository.dart';
import '../datasources/arp_data_source.dart';
import '../datasources/nmap_data_source.dart';

@LazySingleton(as: NetworkScanRepository)
class NetworkScanRepositoryImpl implements NetworkScanRepository {
  final NmapDataSource _dataSource;
  final ArpDataSource _arpDataSource;

  NetworkScanRepositoryImpl(this._dataSource, this._arpDataSource);

  @override
  Future<Either<Failure, List<NetworkDevice>>> scanNetwork(
    String subnet,
  ) async {
    try {
      final devices = await _dataSource.scanSubnet(subnet);
      if (devices.isNotEmpty) return Right(devices);

      // Fallback to ARP-based discovery (with Ping Scan fallback)
      final arpHosts = await _arpDataSource.discoverHosts(targetSubnet: subnet);
      return Right(
        arpHosts
            .map(
              (h) => NetworkDevice(
                ip: h.ip,
                mac: h.mac,
                vendor: h.vendor,
                hostName: h.hostName,
                latency: h.latency,
              ),
            )
            .toList(),
      );
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HostScanResult>>> scanWithProfile(
    String target, {
    NetworkScanProfile profile = NetworkScanProfile.fast,
    PortScanMethod method = PortScanMethod.auto,
  }) async {
    try {
      final hosts = await _dataSource.scanTarget(
        target,
        profile: profile,
        method: method,
      );

      if (hosts.isNotEmpty) return Right(hosts);

      // Fallback to ARP-based discovery
      final arpHosts = await _arpDataSource.discoverHosts(
        targetSubnet: target,
        profile: profile,
      );
      return Right(arpHosts);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }
}
