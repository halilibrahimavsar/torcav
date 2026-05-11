import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/network_scan/domain/entities/host_scan_result.dart';
import 'package:torcav/features/network_scan/domain/entities/lan_exposure_finding.dart';
import 'package:torcav/features/network_scan/domain/entities/vulnerability_finding.dart';
import 'package:torcav/features/network_scan/domain/services/host_trust_classifier.dart';
import 'package:torcav/features/performance/domain/entities/speed_test_result.dart';
import 'package:torcav/features/reports/domain/services/home_health_report_builder.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

void main() {
  const builder = HomeHealthReportBuilder(HostTrustClassifier());

  WifiNetwork connected({int rssi = -50, double phy = 866}) {
    return WifiNetwork(
      ssid: 'Home',
      bssid: 'AA:BB:CC:DD:EE:01',
      signalStrength: rssi,
      channel: 36,
      frequency: 5180,
      security: SecurityType.wpa3,
      estimatedMaxThroughputMbps: phy,
    );
  }

  SpeedTestResult speed({
    double download = 200,
    double latency = 12,
    double loaded = 16,
  }) {
    return SpeedTestResult(
      recordedAt: DateTime.now(),
      latencyMs: latency,
      jitterMs: 1,
      downloadMbps: download,
      uploadMbps: download,
      loadedLatencyMs: loaded,
    );
  }

  HostScanResult host({
    double exposureScore = 10,
    List<LanExposureFinding> findings = const [],
  }) {
    return HostScanResult(
      ip: '192.168.1.10',
      mac: 'AA:BB:CC:DD:EE:10',
      vendor: 'Acme',
      hostName: 'host',
      osGuess: 'unknown',
      latency: 4,
      services: const [],
      exposureFindings: findings,
      exposureScore: exposureScore,
      deviceType: 'Laptop',
    );
  }

  test('all-strong inputs produce a high overall score', () {
    final report = builder.build(
      connectedSsid: 'Home',
      connectedNetwork: connected(),
      speedTest: speed(),
      securityScore: 95,
      lanHosts: [host(), host()],
    );
    expect(report.overallScore, greaterThanOrEqualTo(80));
    expect(report.headline.toLowerCase(), contains('great shape'));
  });

  test('low Wi-Fi signal drags the wifi score down', () {
    final report = builder.build(
      connectedSsid: 'Home',
      connectedNetwork: connected(rssi: -85),
      speedTest: speed(),
      securityScore: 90,
    );
    expect(report.wifiScore, lessThan(40));
  });

  test('a risky LAN host pulls LAN score down meaningfully', () {
    final risky = host(
      findings: [
        LanExposureFinding(
          ruleId: 'lan.test',
          hostIp: '192.168.1.10',
          hostMac: '00',
          hostVendor: '',
          summary: '',
          risk: VulnerabilityRisk.high,
          evidence: '',
          remediation: '',
        ),
      ],
    );
    final report = builder.build(
      connectedSsid: 'Home',
      lanHosts: [risky, host(), host()],
    );
    expect(report.lanScore, lessThan(80));
  });

  test('missing inputs land at neutral scores', () {
    final report = builder.build(connectedSsid: 'Home');
    expect(report.wifiScore, 50);
    expect(report.securityScore, 50);
    expect(report.internetScore, 50);
  });
}
