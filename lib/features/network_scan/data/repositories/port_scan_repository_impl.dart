import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/service_fingerprint.dart';
import '../../domain/repositories/port_scan_repository.dart';
import '../datasources/port_scan_data_source.dart';

@LazySingleton(as: PortScanRepository)
class PortScanRepositoryImpl implements PortScanRepository {
  final PortScanDataSource _dataSource;

  PortScanRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ServiceFingerprint>>> scanPorts(String ip) async {
    try {
      final results = await _dataSource.scanPorts(ip);
      return Right(results);
    } catch (e) {
      return Left(ScanFailure('Port scan failed: $e'));
    }
  }
}
