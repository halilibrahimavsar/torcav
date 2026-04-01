import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torcav/features/settings/domain/entities/app_settings.dart';
import 'package:torcav/features/settings/domain/services/app_settings_store.dart';
import 'package:torcav/features/wifi_scan/domain/entities/scan_request.dart';

void main() {
  group('AppSettingsStore', () {
    test('loads defaults when no persisted settings exist', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final store = AppSettingsStore(prefs);

      expect(store.value, const AppSettings());
    });

    test('persists settings and reloads them on a new instance', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = AppSettingsStore(prefs);
      const updated = AppSettings(
        scanIntervalSeconds: 12,
        defaultScanPasses: 4,
        defaultBackendPreference: WifiBackendPreference.android,
        includeHiddenSsids: false,
        strictSafetyMode: false,
      );

      store.update(updated);
      await Future<void>.delayed(Duration.zero);

      final reloaded = AppSettingsStore(prefs);

      expect(reloaded.value, updated);
    });

    test(
      'falls back to defaults when persisted settings are corrupt',
      () async {
        SharedPreferences.setMockInitialValues({
          'scan_behavior_settings': '{not-json',
        });
        final prefs = await SharedPreferences.getInstance();

        final store = AppSettingsStore(prefs);

        expect(store.value, const AppSettings());
      },
    );
  });
}
