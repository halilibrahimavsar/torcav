import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/monitoring/data/repositories/topology_repository_impl.dart';
import 'package:torcav/features/monitoring/domain/services/topology_builder.dart';
import 'package:torcav/features/network_scan/domain/entities/network_device.dart';
import 'package:torcav/features/network_scan/domain/repositories/network_scan_repository.dart';
import 'package:torcav/features/wifi_scan/domain/services/scan_session_store.dart';

import '../../../../helpers/fixtures.dart';

class _MockNetworkInfo extends Mock implements NetworkInfo {}

class _MockScanSessionStore extends Mock implements ScanSessionStore {}

class _MockNetworkScanRepository extends Mock
    implements NetworkScanRepository {}

void main() {
  late _MockNetworkInfo networkInfo;
  late _MockScanSessionStore scanStore;
  late _MockNetworkScanRepository scanRepo;
  late TopologyRepositoryImpl repo;

  setUp(() {
    networkInfo = _MockNetworkInfo();
    scanStore = _MockScanSessionStore();
    scanRepo = _MockNetworkScanRepository();
    repo = TopologyRepositoryImpl(
      networkInfo,
      scanStore,
      scanRepo,
      TopologyBuilder(),
    );

    when(() => networkInfo.getWifiIP())
        .thenAnswer((_) async => '192.168.1.10');
    when(() => networkInfo.getWifiGatewayIP())
        .thenAnswer((_) async => '192.168.1.1');
    when(() => networkInfo.getWifiName()).thenAnswer((_) async => '"Lab AP"');
    when(() => networkInfo.getWifiBSSID())
        .thenAnswer((_) async => 'AA:BB:CC:DD:EE:FF');

    when(() => scanStore.latest).thenReturn(null);
  });

  group('getTopologyStream', () {
    test('yields topology built from LAN scan results', () async {
      when(() => scanStore.latest).thenReturn(
        buildScanSnapshot(
          networks: [
            buildWifiNetwork(),
          ],
        ),
      );
      when(() => scanRepo.scanNetwork(any())).thenAnswer(
        (_) => Stream.value(
          Right<Failure, List<NetworkDevice>>([
            buildNetworkDevice(ip: '192.168.1.42'),
          ]),
        ),
      );

      final result = await repo.getTopologyStream().first;
      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (topology) {
        // Current device, gateway, AP, plus one LAN device.
        expect(topology.nodes.where((n) => n.isCurrentDevice), hasLength(1));
        expect(topology.gateway, isNotNull);
        expect(topology.currentDeviceIp, '192.168.1.10');
      });

      verify(() => scanRepo.scanNetwork('192.168.1.0/24')).called(1);
    });

    test('falls back to building without LAN when currentIp is null', () async {
      when(() => networkInfo.getWifiIP()).thenAnswer((_) async => null);

      final result = await repo.getTopologyStream().first;
      expect(result.isRight(), isTrue);
      verifyNever(() => scanRepo.scanNetwork(any()));
    });

    test('yields Left(ScanFailure) when network info throws', () async {
      when(
        () => networkInfo.getWifiIP(),
      ).thenAnswer((_) async => throw StateError('denied'));

      final result = await repo.getTopologyStream().first;
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ScanFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('strips quotes from SSID', () async {
      when(() => networkInfo.getWifiName()).thenAnswer((_) async => '"Q"');
      when(() => scanStore.latest).thenReturn(
        buildScanSnapshot(
          networks: [
            buildWifiNetwork(ssid: 'Q'),
          ],
        ),
      );
      when(() => scanRepo.scanNetwork(any())).thenAnswer(
        (_) => Stream.value(
          const Right<Failure, List<NetworkDevice>>([]),
        ),
      );

      final result = await repo.getTopologyStream().first;
      result.fold((_) => fail('expected Right'), (topology) {
        // AP labeled by stripped SSID; original quoted form should not appear.
        expect(
          topology.nodes.where((n) => n.label == 'Q'),
          isNotEmpty,
        );
      });
    });
  });

  group('buildFromDevices', () {
    test('returns Right(topology) built from supplied devices', () async {
      when(() => scanStore.latest).thenReturn(
        buildScanSnapshot(
          networks: [
            buildWifiNetwork(),
          ],
        ),
      );

      final result = await repo.buildFromDevices([
        buildNetworkDevice(ip: '192.168.1.42'),
      ]);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (topology) {
        expect(
          topology.nodes.where((n) => n.id == 'device_192.168.1.42'),
          hasLength(1),
        );
      });
    });

    test('returns Left when network info throws', () async {
      when(
        () => networkInfo.getWifiIP(),
      ).thenAnswer((_) async => throw StateError('denied'));

      final result = await repo.buildFromDevices([]);
      expect(result.isLeft(), isTrue);
    });
  });

  group('reverseLookup', () {
    test('returns Left when input is not a resolvable host', () async {
      // 0.0.0.0 reliably returns itself / no resolvable hostname.
      final result = await repo.reverseLookup('0.0.0.0');
      // Either Left('Hostname not found') or Left(ServerFailure('...')) — both Left.
      expect(result.isLeft(), isTrue);
    });
  });
}
