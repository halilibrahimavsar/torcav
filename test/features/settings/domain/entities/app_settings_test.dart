import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/core/network/network_context_type.dart';
import 'package:torcav/core/settings/app_settings.dart';
import 'package:torcav/features/wifi_scan/domain/entities/scan_request.dart';

void main() {
  group('AppSettings defaults', () {
    test('default constructor matches documented safety posture', () {
      const s = AppSettings();
      expect(s.scanIntervalSeconds, 30);
      expect(s.defaultScanPasses, 3);
      expect(s.defaultBackendPreference, WifiBackendPreference.auto);
      expect(s.includeHiddenSsids, isFalse);
      expect(s.strictSafetyMode, isTrue);
      expect(s.autoScanEnabled, isFalse);
      expect(s.isDeepScanEnabled, isFalse);
      // Public-network deep-scan guard is on by default — the dominant
      // legal/ethical safeguard.
      expect(s.restrictDeepScanOnPublic, isTrue);
      expect(s.portScanTimeoutMs, 500);
      expect(s.isAiEnabled, isTrue);
      expect(s.backgroundType, AppBackgroundType.aegisShield);
      expect(s.defaultNetworkContext, NetworkContextType.unknown);
      // Background monitoring opt-in by default.
      expect(s.backgroundMonitoringEnabled, isFalse);
    });
  });

  group('copyWith', () {
    test('overrides only the supplied fields; others retained', () {
      const original = AppSettings();
      final updated = original.copyWith(scanIntervalSeconds: 90);
      expect(updated.scanIntervalSeconds, 90);
      expect(updated.isAiEnabled, isTrue);
    });

    test('returns an equatable instance with mutated fields', () {
      const a = AppSettings();
      final b = a.copyWith(autoScanEnabled: true);
      expect(a == b, isFalse);
      expect(b.autoScanEnabled, isTrue);
    });
  });

  group('JSON round-trip', () {
    test('toJson → fromJson reconstructs identical settings', () {
      const original = AppSettings(
        scanIntervalSeconds: 45,
        defaultScanPasses: 5,
        defaultBackendPreference: WifiBackendPreference.android,
        includeHiddenSsids: true,
        strictSafetyMode: false,
        autoScanEnabled: true,
        isDeepScanEnabled: true,
        restrictDeepScanOnPublic: false,
        portScanTimeoutMs: 250,
        isAiEnabled: false,
        backgroundType: AppBackgroundType.holoSphere,
        scanHistoryRetentionDays: 7,
        speedTestRetentionDays: 14,
        securityEventRetentionDays: 60,
        defaultNetworkContext: NetworkContextType.home,
        backgroundMonitoringEnabled: true,
      );

      final json = original.toJson();
      final reconstructed = AppSettings.fromJson(json);

      expect(reconstructed, original);
    });

    test('fromJson tolerates unknown enum names with safe fallbacks', () {
      final result = AppSettings.fromJson(const {
        'defaultBackendPreference': 'martian-radio',
        'backgroundType': 'wormhole',
        'defaultNetworkContext': 'mystery',
      });

      expect(result.defaultBackendPreference, WifiBackendPreference.auto);
      expect(result.backgroundType, AppBackgroundType.aegisShield);
      expect(result.defaultNetworkContext, NetworkContextType.unknown);
    });

    test('fromJson coerces num scan interval (e.g. doubles) to int', () {
      final result = AppSettings.fromJson(const {
        'scanIntervalSeconds': 45.9,
      });
      // 45.9.round() == 46
      expect(result.scanIntervalSeconds, 46);
    });

    test('fromJson uses defaults when a field is null', () {
      final result = AppSettings.fromJson(const {});
      expect(result, const AppSettings());
    });

    test('fromJson ignores non-bool values for boolean fields', () {
      final result = AppSettings.fromJson(const {
        'strictSafetyMode': 'yes', // not a bool
      });
      // Falls back to default (true).
      expect(result.strictSafetyMode, isTrue);
    });
  });
}
