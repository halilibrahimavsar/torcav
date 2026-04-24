import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';
import 'package:torcav/features/settings/domain/entities/app_settings.dart';
import 'package:torcav/features/settings/domain/services/app_settings_store.dart';
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

      expect(store.value, const AppSettings());
    });

    test('persists settings and reloads them on a new instance', () async {
      String? persistedData;
      when(() => mockStorage.save(any(), any())).thenAnswer((invocation) async {
        persistedData = invocation.positionalArguments[1] as String;
      });
      when(() => mockStorage.get<String>(any())).thenAnswer((_) => persistedData);

      final store = AppSettingsStore(mockStorage);
      const updated = AppSettings(
        scanIntervalSeconds: 12,
        defaultScanPasses: 4,
        defaultBackendPreference: WifiBackendPreference.android,
        includeHiddenSsids: false,
        strictSafetyMode: false,
      );

      store.update(updated);
      await Future<void>.delayed(Duration.zero);

      final reloaded = AppSettingsStore(mockStorage);

      expect(reloaded.value, updated);
    });

    test(
      'falls back to defaults when persisted settings are corrupt',
      () async {
        when(() => mockStorage.get<String>(any())).thenReturn('{not-json');

        final store = AppSettingsStore(mockStorage);

        expect(store.value, const AppSettings());
      },
    );
  });
}

