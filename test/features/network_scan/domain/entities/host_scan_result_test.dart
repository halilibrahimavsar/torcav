import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/network_scan/domain/entities/host_scan_result.dart';
import 'package:torcav/features/network_scan/domain/entities/lan_exposure_finding.dart';
import 'package:torcav/features/network_scan/domain/entities/vulnerability_finding.dart';

HostScanResult _host({
  List<LanExposureFinding> findings = const [],
}) {
  return HostScanResult(
    ip: '192.168.1.42',
    mac: 'AA:BB:CC:DD:EE:FF',
    vendor: 'Apple',
    hostName: 'Alice Phone',
    osGuess: 'iOS',
    latency: 12,
    services: const [],
    exposureFindings: findings,
    exposureScore: 0.4,
    deviceType: 'mobile',
  );
}

void main() {
  group('HostScanResult.vulnerabilities', () {
    test('returns empty when no exposure findings', () {
      expect(_host().vulnerabilities, isEmpty);
    });

    test('maps each exposure finding to its legacy VulnerabilityFinding', () {
      final host = _host(
        findings: const [
          LanExposureFinding(
            ruleId: 'lan.telnet',
            hostIp: '',
            hostMac: '',
            hostVendor: '',
            summary: 'telnet',
            risk: VulnerabilityRisk.high,
            evidence: '',
            remediation: '',
          ),
          LanExposureFinding(
            ruleId: 'lan.upnp',
            hostIp: '',
            hostMac: '',
            hostVendor: '',
            summary: 'upnp',
            risk: VulnerabilityRisk.medium,
            evidence: '',
            remediation: '',
          ),
        ],
      );

      final vulns = host.vulnerabilities;
      expect(vulns, hasLength(2));
      expect(vulns.map((v) => v.id), ['lan.telnet', 'lan.upnp']);
      expect(vulns.first.risk, VulnerabilityRisk.high);
    });
  });

  group('HostScanResult.copyWith', () {
    test('overrides only the supplied fields', () {
      final original = _host();
      final updated = original.copyWith(
        ip: '10.0.0.5',
        isAiClassified: true,
        netbiosName: 'NAS',
      );

      expect(updated.ip, '10.0.0.5');
      expect(updated.isAiClassified, isTrue);
      expect(updated.netbiosName, 'NAS');
      expect(updated.mac, original.mac);
      expect(updated.vendor, original.vendor);
    });
  });
}
