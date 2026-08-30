import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';
import 'package:torcav/core/settings/app_settings.dart';
import 'package:torcav/core/settings/app_settings_store.dart';
import 'package:torcav/features/wifi_scan/domain/entities/scan_request.dart';

class MockHiveStorageService extends Mock implements HiveStorageService {}

void main() {
  late MockHiveStorageService mockStorage;

  setUp(() {
    mockStorage = MockHiveStorageService();
    when(() => mockStorage.save(any(), any())).thenAnswer((_) async {});
  });

  group('AppSettingsStore', () {
    test('loads defaults when no persisted settings exist', () async {
      when(() => mockStorage.get<String>(any())).thenReturn(null);

      final store = AppSettingsStore(mockStorage);
      await store.init();

      expect(store.value, const AppSettings());
    });

    test('persists settings and reloads them on a new instance', () async {
      String? persistedData;
      when(() => mockStorage.save(any(), any())).thenAnswer((invocation) async {
        persistedData = invocation.positionalArguments[1] as String;
      });
      when(
        () => mockStorage.get<String>(any()),
      ).thenAnswer((_) => persistedData);

      final store = AppSettingsStore(mockStorage);
      await store.init();
      
      const updated = AppSettings(
        scanIntervalSeconds: 12,
        defaultScanPasses: 4,
        defaultBackendPreference: WifiBackendPreference.android,
        strictSafetyMode: false,
      );

      store.update(updated);
      await Future<void>.delayed(Duration.zero);

      final reloaded = AppSettingsStore(mockStorage);
      await reloaded.init();

      expect(reloaded.value, updated);
    });

    test(
      'falls back to defaults when persisted settings are corrupt',
      () async {
        when(() => mockStorage.get<String>(any())).thenReturn('{not-json');

        final store = AppSettingsStore(mockStorage);
        await store.init();

        expect(store.value, const AppSettings());
      },
    );

    test('init() emits the loaded value on the changes stream', () async {
      when(() => mockStorage.get<String>(any())).thenReturn(null);
      final store = AppSettingsStore(mockStorage);

      final firstEvent = store.changes.first;
      await store.init();

      expect(await firstEvent, const AppSettings());
    });

    test('update() broadcasts on the changes stream', () async {
      when(() => mockStorage.get<String>(any())).thenReturn(null);
      final store = AppSettingsStore(mockStorage);
      await store.init();

      final emissions = <AppSettings>[];
      final sub = store.changes.listen(emissions.add);

      const next = AppSettings(scanIntervalSeconds: 12, autoScanEnabled: true);
      store.update(next);
      await Future<void>.delayed(Duration.zero);

      expect(emissions, [next]);
      await sub.cancel();
    });

    test('update() mutates value synchronously', () async {
      when(() => mockStorage.get<String>(any())).thenReturn(null);
      final store = AppSettingsStore(mockStorage);
      await store.init();

      const next = AppSettings(scanIntervalSeconds: 99);
      store.update(next);

      expect(store.value, next);
    });

    test('update() persists JSON to storage with the configured key', () async {
      when(() => mockStorage.get<String>(any())).thenReturn(null);
      final store = AppSettingsStore(mockStorage);
      await store.init();

      const next = AppSettings(scanIntervalSeconds: 77, strictSafetyMode: false);
      store.update(next);
      await Future<void>.delayed(Duration.zero);

      final captured =
          verify(() => mockStorage.save(captureAny(), captureAny())).captured;
      expect(captured.first, 'scan_behavior_settings');
      expect(captured.last, contains('"scanIntervalSeconds":77'));
    });
  });
}
