import 'dart:io';

import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:torcav/core/di/injection.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';

class MockHiveStorageService extends Mock implements HiveStorageService {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

/// Default Wi-Fi values used by [MockNetworkInfo] inside [setupHarness] when
/// the caller does not pass [networkInfoOverride].
const _defaultSsid = '"Lab AP"';
const _defaultIp = '192.168.1.10';
const _defaultGateway = '192.168.1.1';
const _defaultBssid = 'AA:BB:CC:DD:EE:FF';

/// Bootstraps the DI container, Hive temp storage, mock HiveStorageService and
/// (optionally) a mock NetworkInfo. Returns the [MockNetworkInfo] in use so
/// callers can override or verify specific stubs.
///
/// Every test that touches [getIt] must call this in `setUp` and pair it with
/// [tearDownHarness] in `tearDown`.
Future<MockNetworkInfo> setupHarness({
  MockNetworkInfo? networkInfoOverride,
}) async {
  GoogleFonts.config.allowRuntimeFetching = false;

  await getIt.reset();

  final tempDir = Directory.systemTemp.createTempSync('torcav_test');
  Hive.init(tempDir.path);
  await Hive.openBox('torcav_preferences');

  await configureDependencies();

  if (getIt.isRegistered<HiveStorageService>()) {
    getIt.unregister<HiveStorageService>();
  }
  final mockStorage = MockHiveStorageService();
  when(
    () => mockStorage.get<String>(
      any(),
      defaultValue: any(named: 'defaultValue'),
    ),
  ).thenReturn(null);
  when(
    () =>
        mockStorage.get<bool>(any(), defaultValue: any(named: 'defaultValue')),
  ).thenReturn(null);
  when(
    () => mockStorage.get<int>(any(), defaultValue: any(named: 'defaultValue')),
  ).thenReturn(null);
  when(() => mockStorage.save(any(), any())).thenAnswer((_) async {});
  getIt.registerSingleton<HiveStorageService>(mockStorage);

  final networkInfo = networkInfoOverride ?? MockNetworkInfo();
  when(() => networkInfo.getWifiName()).thenAnswer((_) async => _defaultSsid);
  when(() => networkInfo.getWifiIP()).thenAnswer((_) async => _defaultIp);
  when(
    () => networkInfo.getWifiGatewayIP(),
  ).thenAnswer((_) async => _defaultGateway);
  when(() => networkInfo.getWifiBSSID()).thenAnswer((_) async => _defaultBssid);

  if (getIt.isRegistered<NetworkInfo>()) {
    getIt.unregister<NetworkInfo>();
  }
  getIt.registerSingleton<NetworkInfo>(networkInfo);

  return networkInfo;
}

Future<void> tearDownHarness() async {
  await getIt.reset();
}

/// Replace a DI-registered singleton with a test double, unregistering the
/// original first if present. Useful for swapping repositories/services after
/// [setupHarness] is done.
void replaceSingleton<T extends Object>(T instance) {
  if (getIt.isRegistered<T>()) {
    getIt.unregister<T>();
  }
  getIt.registerSingleton<T>(instance);
}
