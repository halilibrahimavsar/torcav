import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/network_scan/domain/entities/lan_exposure_finding.dart';
import 'package:torcav/features/network_scan/domain/entities/vulnerability_finding.dart';

void main() {
  group('LanExposureFinding.fromJson', () {
    test('parses a full payload', () {
      final finding = LanExposureFinding.fromJson(const {
        'ruleId': 'lan.telnet_open',
        'hostIp': '192.168.1.42',
        'hostMac': 'AA:BB:CC:DD:EE:FF',
        'hostVendor': 'Synology',
        'summary': 'Telnet port is open',
        'risk': 'high',
        'evidence': 'TCP 23 responded',
        'remediation': 'Disable telnet',
        'serviceName': 'telnet',
        'port': 23,
      });

      expect(finding.ruleId, 'lan.telnet_open');
      expect(finding.risk, VulnerabilityRisk.high);
      expect(finding.port, 23);
      expect(finding.serviceName, 'telnet');
    });

    test('falls back to safe defaults when fields are missing', () {
      final finding = LanExposureFinding.fromJson(const <String, dynamic>{});
      expect(finding.ruleId, 'lan.unknown');
      expect(finding.risk, VulnerabilityRisk.info);
      expect(finding.hostVendor, 'Unknown');
    });

    test('unknown risk string falls back to info', () {
      final finding =
          LanExposureFinding.fromJson(const {'risk': 'apocalyptic'});
      expect(finding.risk, VulnerabilityRisk.info);
    });
  });

  group('LanExposureFinding.toJson', () {
    test('round-trips fromJson <-> toJson without losing fields', () {
      const source = LanExposureFinding(
        ruleId: 'lan.smb',
        hostIp: '10.0.0.5',
        hostMac: '00:11:22:33:44:55',
        hostVendor: 'Apple',
        summary: 'SMB exposed',
        risk: VulnerabilityRisk.medium,
        evidence: 'TCP 445 responded',
        remediation: 'Restrict to localhost',
        serviceName: 'smb',
        port: 445,
      );

      final round = LanExposureFinding.fromJson(source.toJson());
      expect(round, source);
    });
  });

  group('toLegacyFinding', () {
    test('produces a VulnerabilityFinding mirroring summary + risk', () {
      const finding = LanExposureFinding(
        ruleId: 'lan.foo',
        hostIp: '1.1.1.1',
        hostMac: '',
        hostVendor: '',
        summary: 'foo open',
        risk: VulnerabilityRisk.critical,
        evidence: '',
        remediation: '',
      );

      final legacy = finding.toLegacyFinding();
      expect(legacy.id, 'lan.foo');
      expect(legacy.summary, 'foo open');
      expect(legacy.risk, VulnerabilityRisk.critical);
    });
  });
}
