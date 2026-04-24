import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/scan_request.dart';
import '../../domain/entities/scan_snapshot.dart';
import '../../domain/entities/wifi_network.dart';
import '../../domain/repositories/wifi_repository.dart';
import '../datasources/wifi_data_source.dart';

@LazySingleton(as: WifiRepository)
class WifiRepositoryImpl implements WifiRepository {
  final WifiDataSource _dataSource;

  WifiRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<WifiNetwork>>> scanNetworks() async {
    final result = await scanSnapshot(const ScanRequest());
    return result.map((snapshot) => snapshot.toLegacyNetworks());
  }

  @override
  Future<Either<Failure, ScanSnapshot>> scanSnapshot(
    ScanRequest request,
  ) async {
    try {
      final snapshot = await _dataSource.scanSnapshot(request);
      return Right(snapshot);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }
}
