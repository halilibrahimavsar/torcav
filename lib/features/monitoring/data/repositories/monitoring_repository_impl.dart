import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../features/wifi_scan/domain/entities/wifi_network.dart';
import '../../../../features/wifi_scan/domain/repositories/wifi_repository.dart';
import '../../domain/repositories/monitoring_repository.dart';

@LazySingleton(as: MonitoringRepository)
class MonitoringRepositoryImpl implements MonitoringRepository {
  final WifiRepository _wifiRepository;

  MonitoringRepositoryImpl(this._wifiRepository);

  @override
  Stream<Either<Failure, List<WifiNetwork>>> monitorNetworks({
    Duration interval = const Duration(seconds: 5),
  }) async* {
    while (true) {
      final result = await _wifiRepository.scanNetworks();
      yield result;
      await Future.delayed(interval);
    }
  }

  @override
  Stream<Either<Failure, WifiNetwork>> monitorNetwork(
    String bssid, {
    Duration interval = const Duration(seconds: 5),
  }) async* {
    await for (final result in monitorNetworks(interval: interval)) {
      yield result.bind((networks) {
        final network = networks.where((n) => n.bssid == bssid).firstOrNull;
        if (network != null) {
          return Right(network);
        } else {
          return const Left(ScanFailure('Network not found'));
        }
      });
    }
  }
}
