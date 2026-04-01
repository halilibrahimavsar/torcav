import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/host_scan_result.dart';
import '../../domain/entities/network_device.dart';
import '../../domain/entities/network_scan_profile.dart';
import '../../domain/repositories/network_scan_repository.dart';
import '../datasources/arp_data_source.dart';

@LazySingleton(as: NetworkScanRepository)
class NetworkScanRepositoryImpl implements NetworkScanRepository {
  final ArpDataSource _arpDataSource;

  NetworkScanRepositoryImpl(this._arpDataSource);

  @override
  Future<Either<Failure, List<NetworkDevice>>> scanNetwork(
    String subnet,
  ) async {
    try {
      final results =
          (await _arpDataSource.discoverHosts(targetSubnet: subnet))
              .map(
                (h) => NetworkDevice(
                  ip: h.ip,
                  mac: h.mac,
                  vendor: h.vendor,
                  hostName: h.hostName,
                  latency: h.latency,
                ),
              )
              .toList();

      return Right(results);
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
      final results = await _arpDataSource.discoverHosts(
        targetSubnet: target,
        profile: profile,
      );

      return Right(results);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }
}
