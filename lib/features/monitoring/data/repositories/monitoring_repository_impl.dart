import 'dart:async';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../features/wifi_scan/domain/entities/wifi_network.dart';
import '../../../../features/wifi_scan/domain/repositories/wifi_repository.dart';
import '../../domain/entities/bandwidth_sample.dart';
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

  @override
  Stream<Either<Failure, BandwidthSample>> monitorBandwidth(
    String interfaceName, {
    Duration interval = const Duration(seconds: 2),
  }) async* {
    if (!Platform.isLinux) {
      yield const Left(
        ScanFailure(
          'Bandwidth monitoring is currently supported on Linux only',
        ),
      );
      return;
    }

    int? prevRx;
    int? prevTx;
    DateTime? prevTime;

    while (true) {
      try {
        final rxFile = File(
          '/sys/class/net/$interfaceName/statistics/rx_bytes',
        );
        final txFile = File(
          '/sys/class/net/$interfaceName/statistics/tx_bytes',
        );
        if (!await rxFile.exists() || !await txFile.exists()) {
          yield Left(
            ScanFailure('Interface stats unavailable for $interfaceName'),
          );
          await Future<void>.delayed(interval);
          continue;
        }

        final rx = int.parse((await rxFile.readAsString()).trim());
        final tx = int.parse((await txFile.readAsString()).trim());
        final now = DateTime.now();

        if (prevRx != null && prevTx != null && prevTime != null) {
          final elapsedSec = now.difference(prevTime).inMilliseconds / 1000.0;
          if (elapsedSec > 0) {
            final rxBps = (rx - prevRx) / elapsedSec;
            final txBps = (tx - prevTx) / elapsedSec;
            yield Right(
              BandwidthSample(
                timestamp: now,
                interfaceName: interfaceName,
                txBps: txBps,
                rxBps: rxBps,
              ),
            );
          }
        }

        prevRx = rx;
        prevTx = tx;
        prevTime = now;
      } catch (e) {
        yield Left(ScanFailure('Bandwidth monitor error: $e'));
      }

      await Future<void>.delayed(interval);
    }
  }
}
