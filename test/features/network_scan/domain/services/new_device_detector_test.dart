import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';
import 'package:torcav/features/network_scan/domain/entities/host_scan_result.dart';
import 'package:torcav/features/network_scan/domain/services/new_device_detector.dart';

class _MockHiveStorage extends Mock implements HiveStorageService {}

HostScanResult _host(String mac) => HostScanResult(
      ip: '192.168.1.${mac.codeUnitAt(0)}',
      mac: mac,
      vendor: 'Vendor',
      hostName: '',
      osGuess: '',
      latency: 0,
      services: const [],
      exposureFindings: const [],
      exposureScore: 0,
      deviceType: 'device',
    );

void main() {
  late _MockHiveStorage storage;
  late NewDeviceDetector detector;

  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    storage = _MockHiveStorage();
    when(
      () => storage.get<List<dynamic>>(any(), defaultValue: any(named: 'defaultValue')),
    ).thenReturn(null);
    when(() => storage.save(any(), any())).thenAnswer((_) async {});
    detector = NewDeviceDetector(storage);
  });

  test('returns every host as new when storage is empty', () {
    final hosts = [_host('AA'), _host('BB')];
    final result = detector.detectNew(hosts);

    expect(result.map((h) => h.mac).toList(), ['AA', 'BB']);
    verify(() => storage.save('known_mac_addresses', any())).called(1);
  });

  test('filters out hosts whose MAC is already known', () {
    when(
      () => storage.get<List<dynamic>>(any(), defaultValue: any(named: 'defaultValue')),
    ).thenReturn(['AA']);

    final result = detector.detectNew([_host('AA'), _host('CC')]);
    expect(result.map((h) => h.mac).toList(), ['CC']);
  });

  test('returns empty list and skips save when no new devices', () {
    when(
      () => storage.get<List<dynamic>>(any(), defaultValue: any(named: 'defaultValue')),
    ).thenReturn(['AA', 'BB']);

    final result = detector.detectNew([_host('AA'), _host('BB')]);
    expect(result, isEmpty);
    verifyNever(() => storage.save(any(), any()));
  });

  test('persists union of known + new MACs', () {
    when(
      () => storage.get<List<dynamic>>(any(), defaultValue: any(named: 'defaultValue')),
    ).thenReturn(['AA']);

    detector.detectNew([_host('AA'), _host('BB'), _host('CC')]);

    final captured =
        verify(() => storage.save('known_mac_addresses', captureAny()))
            .captured
            .single as List<dynamic>;
    expect(captured.toSet(), {'AA', 'BB', 'CC'});
  });
}
