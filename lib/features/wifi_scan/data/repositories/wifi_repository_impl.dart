import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wifi_network.dart';
import '../../domain/repositories/wifi_repository.dart';
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
    try {
      if (Platform.isLinux) {
        final networks = await _linuxDataSource.scanNetworks();
        return Right(networks);
      } else if (Platform.isAndroid) {
        final networks = await _androidDataSource.scanNetworks();
        return Right(networks);
      } else {
        return Left(const ScanFailure('Platform not supported'));
      }
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }
}
