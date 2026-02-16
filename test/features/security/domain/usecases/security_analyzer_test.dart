import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/security/domain/entities/vulnerability.dart';
import 'package:torcav/features/security/domain/usecases/security_analyzer.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

void main() {
  late SecurityAnalyzer analyzer;

  setUp(() {
    analyzer = SecurityAnalyzer();
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

    final report = analyzer.analyze(network);

    expect(report.score, lessThan(40));
    expect(report.overallStatus, 'Critical');
    expect(
      report.vulnerabilities.any(
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

    final report = analyzer.analyze(network);

    expect(report.score, lessThan(40));
    expect(report.overallStatus, 'Critical');
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

    final report = analyzer.analyze(network);

    expect(report.score, lessThan(70));
    expect(report.overallStatus, 'At Risk');
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

    final report = analyzer.analyze(network);

    expect(report.vulnerabilities.any((v) => v.title == 'Hidden SSID'), true);
    // WPA2 is secure (100), but hidden deduction (-5) = 95. Status Secure.
    expect(report.score, 95);
    expect(report.overallStatus, 'Secure');
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

    final report = analyzer.analyze(network);

    expect(report.score, 100);
    expect(report.vulnerabilities, isEmpty);
  });
}
