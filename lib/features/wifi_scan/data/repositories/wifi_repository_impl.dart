import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/scan_request.dart';
import '../../domain/entities/scan_snapshot.dart';
import '../../domain/entities/wifi_network.dart';
import '../../domain/repositories/wifi_repository.dart';
import '../datasources/scan_persistence_data_source.dart';
import '../datasources/wifi_data_source.dart';

@LazySingleton(as: WifiRepository)
class WifiRepositoryImpl implements WifiRepository {
  final WifiDataSource _linuxDataSource;
  final WifiDataSource _androidDataSource;

  WifiRepositoryImpl(
    @Named('linux') this._linuxDataSource,
    @Named('android') this._androidDataSource,
  );

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
      if (Platform.isLinux) {
        final snapshot = await _linuxDataSource.scanSnapshot(request);
        await _persistSnapshot(snapshot);
        return Right(snapshot);
      } else if (Platform.isAndroid) {
        final snapshot = await _androidDataSource.scanSnapshot(request);
        await _persistSnapshot(snapshot);
        return Right(snapshot);
      } else {
        return Left(const ScanFailure('Platform not supported'));
      }
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }

  Future<void> _persistSnapshot(ScanSnapshot snapshot) async {
    try {
      if (!getIt.isRegistered<ScanPersistenceDataSource>()) {
        return;
      }
      await getIt<ScanPersistenceDataSource>().saveSnapshot(snapshot);
    } catch (_) {
      // Persistence must not break scan flow.
    }
  }
}
