import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/network_scan/domain/entities/host_scan_result.dart';
import 'package:torcav/features/network_scan/domain/entities/host_trust_assessment.dart';
import 'package:torcav/features/network_scan/domain/entities/lan_exposure_finding.dart';
import 'package:torcav/features/network_scan/domain/entities/vulnerability_finding.dart';
import 'package:torcav/features/network_scan/domain/services/host_trust_classifier.dart';

void main() {
  const classifier = HostTrustClassifier();

  HostScanResult host({
    double exposureScore = 10,
    List<LanExposureFinding> findings = const [],
    bool isSuspicious = false,
    bool isGateway = false,
  }) {
    return HostScanResult(
      ip: '192.168.1.10',
      mac: 'AA:BB:CC:DD:EE:01',
      vendor: 'Acme',
      hostName: 'host.local',
      osGuess: 'unknown',
      latency: 4,
      services: const [],
      exposureFindings: findings,
      exposureScore: exposureScore,
      deviceType: 'Laptop',
      isGateway: isGateway,
      isSuspicious: isSuspicious,
    );
  }

  LanExposureFinding finding(VulnerabilityRisk risk) => LanExposureFinding(
    ruleId: 'lan.test',
    hostIp: '192.168.1.10',
    hostMac: 'AA:BB:CC:DD:EE:01',
    hostVendor: 'Acme',
    summary: 'Test ${risk.name}',
    risk: risk,
    evidence: '',
    remediation: 'do something',
  );

  test('clean host with no findings is safe', () {
    final result = classifier.classify(host());
    expect(result.level, HostTrustLevel.safe);
    expect(result.reasons, isEmpty);
  });

  test('high-severity finding escalates to risky', () {
    final result = classifier.classify(
      host(findings: [finding(VulnerabilityRisk.high)]),
    );
    expect(result.level, HostTrustLevel.risky);
    expect(result.reasons.length, 1);
  });

  test('medium-severity finding escalates only to caution', () {
    final result = classifier.classify(
      host(findings: [finding(VulnerabilityRisk.medium)]),
    );
    expect(result.level, HostTrustLevel.caution);
  });

  test('exposure score >= 80 escalates to risky', () {
    final result = classifier.classify(host(exposureScore: 85));
    expect(result.level, HostTrustLevel.risky);
  });

  test('suspicious flag adds caution + reason', () {
    final result = classifier.classify(host(isSuspicious: true));
    expect(result.level, HostTrustLevel.caution);
    expect(result.reasons, isNotEmpty);
  });

  test('gateway with no findings carries the "your router" headline', () {
    final result = classifier.classify(host(isGateway: true));
    expect(result.level, HostTrustLevel.safe);
    expect(result.headline.toLowerCase(), contains('router'));
  });
}
