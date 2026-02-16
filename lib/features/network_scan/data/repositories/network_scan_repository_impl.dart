import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/network_device.dart';
import '../../domain/repositories/network_scan_repository.dart';
import '../datasources/nmap_data_source.dart';

@LazySingleton(as: NetworkScanRepository)
class NetworkScanRepositoryImpl implements NetworkScanRepository {
  final NmapDataSource _dataSource;

  NetworkScanRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<NetworkDevice>>> scanNetwork(
    String subnet,
  ) async {
    try {
      final devices = await _dataSource.scanSubnet(subnet);
      return Right(devices);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }
}
