import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/network_scan/domain/entities/network_scan_policy.dart';

void main() {
  group('NetworkScanPolicy.standard', () {
    test('defaults to /24 cap (256 hosts) and requires consent', () {
      const policy = NetworkScanPolicy.standard;
      expect(policy.maxSubnetSize, 256);
      expect(policy.requireConsent, isTrue);
    });
  });

  group('isTargetSafe', () {
    const policy = NetworkScanPolicy.standard;

    test('treats single IP (no /) as safe', () {
      expect(policy.isTargetSafe('192.168.1.10'), isTrue);
    });

    test('rejects malformed CIDR (extra parts)', () {
      expect(policy.isTargetSafe('192.168.1.0/24/extra'), isFalse);
    });

    test('rejects non-numeric mask', () {
      expect(policy.isTargetSafe('192.168.1.0/foo'), isFalse);
    });

    test('accepts /24 (256 hosts)', () {
      expect(policy.isTargetSafe('192.168.1.0/24'), isTrue);
    });

    test('accepts /32 (1 host) and /25 (128 hosts)', () {
      expect(policy.isTargetSafe('192.168.1.10/32'), isTrue);
      expect(policy.isTargetSafe('192.168.1.0/25'), isTrue);
    });

    test('rejects /16 (65 536 hosts) under default policy', () {
      expect(policy.isTargetSafe('10.0.0.0/16'), isFalse);
    });

    test('out-of-range mask values resolve to 0 hosts (treated as safe)', () {
      // Implementation clamps out-of-range masks to 0 hosts; this documents
      // that behaviour. 0 hosts is harmless even if the input is malformed.
      expect(policy.isTargetSafe('10.0.0.0/-1'), isTrue);
      expect(policy.isTargetSafe('10.0.0.0/33'), isTrue);
    });

    test('honors custom maxSubnetSize', () {
      const tight = NetworkScanPolicy(maxSubnetSize: 16);
      expect(tight.isTargetSafe('192.168.1.0/28'), isTrue); // 16 hosts
      expect(tight.isTargetSafe('192.168.1.0/27'), isFalse); // 32 hosts
    });
  });
}
