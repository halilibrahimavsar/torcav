import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/features/reports/domain/entities/home_health_report.dart';
import 'package:torcav/features/reports/presentation/widgets/home_health_labels.dart';
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
    expect(report.headlineKey, 'healthHeadlineGreat');
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
        const LanExposureFinding(
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

  // Guards the wiring that took this report from "written but unreachable"
  // to shipped: the builder emits keys, and HomeHealthCard must resolve every
  // one of them. A key it does not know is dropped, so an unregistered key
  // would silently delete a recommendation.
  testWidgets('every key the builder emits resolves to text', (tester) async {
    final reports = <HomeHealthReport>[
      // Healthy — the monthly-recheck branch.
      builder.build(
        connectedSsid: 'Home',
        connectedNetwork: connected(),
        speedTest: speed(),
        securityScore: 95,
        lanHosts: [host()],
      ),
      // Weak Wi-Fi.
      builder.build(
        connectedSsid: 'Home',
        connectedNetwork: connected(rssi: -88),
        speedTest: speed(),
        securityScore: 95,
      ),
      // Weak security.
      builder.build(
        connectedSsid: 'Home',
        connectedNetwork: connected(),
        speedTest: speed(),
        securityScore: 10,
      ),
      // Risky LAN host — the branch that carries ip/vendor parameters.
      builder.build(
        connectedSsid: 'Home',
        connectedNetwork: connected(),
        speedTest: speed(),
        securityScore: 95,
        lanHosts: [
          host(
            findings: const [
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
          ),
        ],
      ),
    ];

    for (final report in reports) {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              // Headline and every action must produce words, not keys.
              expect(
                HomeHealthLabels.headline(l10n, report),
                isNot(contains(report.headlineKey)),
              );
              for (final action in report.topActions) {
                expect(
                  HomeHealthLabels.action(l10n, action),
                  isNotNull,
                  reason: '${action.key} has no localized text',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    }
  });
}
