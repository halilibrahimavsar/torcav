import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/core/network/network_context_type.dart';
import 'package:torcav/features/security/domain/entities/security_assessment.dart';
import 'package:torcav/features/security/domain/entities/vulnerability.dart';
import 'package:torcav/features/security/domain/services/evil_twin_classifier.dart';
import 'package:torcav/features/security/domain/usecases/security_analyzer.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

void main() {
  late SecurityAnalyzer analyzer;

  setUp(() {
    analyzer = SecurityAnalyzer(const EvilTwinClassifier());
  });

  test('should identify Open network as critical risk', () {
    const network = WifiNetwork(
      ssid: 'OpenWifi',
      bssid: '00:00:00:00:00:00',
      signalStrength: -50,
      channel: 1,
      frequency: 2412,
      security: SecurityType.open,
      vendor: '',
    );

    final report = analyzer.assess(network);

    expect(report.score, lessThan(40));
    expect(report.status, SecurityStatus.critical);
    expect(
      report.findings.any(
        (v) => v.severity == VulnerabilitySeverity.critical,
      ),
      true,
    );
  });

  test('should identify WEP network as critical risk', () {
    const network = WifiNetwork(
      ssid: 'WEPWifi',
      bssid: '00:00:00:00:00:00',
      signalStrength: -50,
      channel: 1,
      frequency: 2412,
      security: SecurityType.wep,
      vendor: '',
    );

    final report = analyzer.assess(network);

    expect(report.score, lessThan(40));
    expect(report.status, SecurityStatus.critical);
  });

  test('should identify WPA network as high risk', () {
    const network = WifiNetwork(
      ssid: 'WPAWifi',
      bssid: '00:00:00:00:00:00',
      signalStrength: -50,
      channel: 1,
      frequency: 2412,
      security: SecurityType.wpa,
      vendor: '',
    );

    final report = analyzer.assess(network);

    expect(report.score, lessThan(70));
    expect(report.status, SecurityStatus.atRisk);
  });

  test('should identify Hidden SSID as vulnerability', () {
    const network = WifiNetwork(
      ssid: '',
      bssid: '00:00:00:00:00:00',
      signalStrength: -50,
      channel: 1,
      frequency: 2412,
      security: SecurityType.wpa2,
      vendor: '',
      isHidden: true,
    );

    final report = analyzer.assess(network);

    expect(report.findings.any((v) => v.title == 'Hidden SSID'), true);
    // WPA2 is secure (100), but hidden deduction (-5) = 95. Status Secure.
    expect(report.score, 95);
    expect(report.status, SecurityStatus.secure);
  });

  test('should return perfect score for WPA3/WPA2 visible network', () {
    const network = WifiNetwork(
      ssid: 'SecureWifi',
      bssid: '00:00:00:00:00:00',
      signalStrength: -50,
      channel: 1,
      frequency: 2412,
      security: SecurityType.wpa3,
      vendor: '',
    );

    final report = analyzer.assess(network);

    expect(report.score, 100);
    expect(report.findings, isEmpty);
  });

  group('context-aware scoring', () {
    const wpsNetwork = WifiNetwork(
      ssid: 'TestNet',
      bssid: '00:00:00:00:00:00',
      signalStrength: -50,
      channel: 1,
      frequency: 2412,
      security: SecurityType.wpa2,
      vendor: '',
      hasWps: true,
    );

    test('home context penalises WPS more heavily than unknown', () {
      final neutral = analyzer.assess(wpsNetwork);
      final home = analyzer.assess(
        wpsNetwork,
        context: NetworkContextType.home,
      );
      // Base WPS deduction is 30; home multiplier 1.5 → 45.
      expect(100 - neutral.score, 30);
      expect(100 - home.score, 45);
    });

    test('public context softens WPS — router is not the user\'s', () {
      final public = analyzer.assess(
        wpsNetwork,
        context: NetworkContextType.public,
      );
      // Base 30 × 0.5 → 15.
      expect(100 - public.score, 15);
    });

    test('public context amplifies suspicious SSID lure', () {
      const lureNetwork = WifiNetwork(
        ssid: 'Free WiFi',
        bssid: '00:00:00:00:00:00',
        signalStrength: -50,
        channel: 1,
        frequency: 2412,
        security: SecurityType.wpa2,
        vendor: '',
      );
      final neutral = analyzer.assess(lureNetwork);
      final public = analyzer.assess(
        lureNetwork,
        context: NetworkContextType.public,
      );
      // Base 15 → 23 (round of 22.5) under public.
      expect(100 - neutral.score, 15);
      expect(100 - public.score, 23);
    });

    test('unknown context preserves legacy behaviour', () {
      final legacy = analyzer.assess(wpsNetwork);
      final explicit = analyzer.assess(
        wpsNetwork,
      );
      expect(legacy.score, explicit.score);
    });
  });
}
