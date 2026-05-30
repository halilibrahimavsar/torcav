import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/monitoring/data/repositories/monitoring_repository_impl.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/features/wifi_scan/domain/repositories/wifi_repository.dart';

import '../../../../helpers/fixtures.dart';

class _MockWifiRepository extends Mock implements WifiRepository {}

void main() {
  late _MockWifiRepository wifi;
  late MonitoringRepositoryImpl repo;

  setUp(() {
    wifi = _MockWifiRepository();
    repo = MonitoringRepositoryImpl(wifi);
  });

  group('monitorNetworks', () {
    test('yields scan results as they arrive', () async {
      final networks = [buildWifiNetwork(bssid: '00:11:22:33:44:55')];
      when(() => wifi.scanNetworks()).thenAnswer((_) async => Right(networks));

      final result = await repo
          .monitorNetworks(interval: const Duration(milliseconds: 1))
          .first;

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('should be Right'), (list) {
        expect(list, hasLength(1));
        expect(list.first.bssid, '00:11:22:33:44:55');
      });
    });

    test('yields failure when underlying scan fails', () async {
      when(
        () => wifi.scanNetworks(),
      ).thenAnswer((_) async => const Left(ScanFailure('denied')));

      final result = await repo
          .monitorNetworks(interval: const Duration(milliseconds: 1))
          .first;
      expect(result.isLeft(), isTrue);
    });
  });

  group('monitorNetwork', () {
    test('yields Right(network) when BSSID is found in scan result', () async {
      when(() => wifi.scanNetworks()).thenAnswer(
        (_) async => Right<Failure, List<WifiNetwork>>([
          buildWifiNetwork(),
          buildWifiNetwork(bssid: '11:22:33:44:55:66'),
        ]),
      );

      final result = await repo
          .monitorNetwork(
            'AA:BB:CC:DD:EE:FF',
            interval: const Duration(milliseconds: 1),
          )
          .first;

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('should be Right'), (n) {
        expect(n.bssid, 'AA:BB:CC:DD:EE:FF');
      });
    });

    test('yields Left(ScanFailure) when BSSID is absent from scan', () async {
      when(() => wifi.scanNetworks()).thenAnswer(
        (_) async => Right<Failure, List<WifiNetwork>>([
          buildWifiNetwork(bssid: '11:22:33:44:55:66'),
        ]),
      );

      final result = await repo
          .monitorNetwork(
            'AA:BB:CC:DD:EE:FF',
            interval: const Duration(milliseconds: 1),
          )
          .first;

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ScanFailure>()),
        (_) => fail('should be Left'),
      );
    });

    test('propagates failures from underlying repository', () async {
      when(
        () => wifi.scanNetworks(),
      ).thenAnswer((_) async => const Left(ScanFailure('boom')));

      final result = await repo
          .monitorNetwork(
            'AA:BB:CC:DD:EE:FF',
            interval: const Duration(milliseconds: 1),
          )
          .first;
      expect(result.isLeft(), isTrue);
    });
  });
}
