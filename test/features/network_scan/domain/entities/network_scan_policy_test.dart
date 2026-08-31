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
      // A prefix length outside 0..32 is malformed. It used to yield a host
      // count of 0, which compared under the limit and read as "safe".
      expect(policy.isTargetSafe('10.0.0.0/-1'), isFalse);
      expect(policy.isTargetSafe('10.0.0.0/33'), isFalse);
    });

    test('honors custom maxSubnetSize', () {
      const tight = NetworkScanPolicy(maxSubnetSize: 16);
      expect(tight.isTargetSafe('192.168.1.0/28'), isTrue); // 16 hosts
      expect(tight.isTargetSafe('192.168.1.0/27'), isFalse); // 32 hosts
    });
  });

  group('locality', () {
    // The finding this closes: `isTargetSafe` was named like a safety gate but
    // only checked range size, so a public IP passed unconditionally.
    test('private ranges are accepted', () {
      for (final ip in [
        '192.168.1.10',
        '10.0.0.1',
        '172.16.5.4',
        '172.31.255.254',
        '169.254.1.1', // link-local, used when DHCP fails
      ]) {
        expect(
          NetworkScanPolicy.isPrivateAddress(ip),
          isTrue,
          reason: '$ip should be treated as local',
        );
      }
    });

    test('public and near-miss ranges are refused', () {
      for (final ip in [
        '8.8.8.8',
        '1.1.1.1',
        '172.15.0.1', // just below the 172.16/12 block
        '172.32.0.1', // just above it
        '192.169.1.1', // one off 192.168/16
        '11.0.0.1',
      ]) {
        expect(
          NetworkScanPolicy.isPrivateAddress(ip),
          isFalse,
          reason: '$ip is not on the user\'s own network',
        );
      }
    });

    test('malformed addresses are refused, not assumed safe', () {
      for (final ip in ['', 'localhost', '192.168.1', '192.168.1.1.1', '999.1.1.1', '192.168.a.1']) {
        expect(NetworkScanPolicy.isPrivateAddress(ip), isFalse, reason: ip);
      }
    });

    test('a public single IP is no longer waved through', () {
      const policy = NetworkScanPolicy.standard;
      expect(policy.isTargetSafe('8.8.8.8'), isFalse);
      expect(policy.isTargetSafe('192.168.1.10'), isTrue);
    });

    test('size limit still applies inside private space', () {
      const policy = NetworkScanPolicy.standard;
      expect(policy.isTargetSafe('192.168.1.0/24'), isTrue);
      expect(policy.isTargetSafe('10.0.0.0/8'), isFalse);
      expect(policy.isTargetSafe('192.168.0.0/16'), isFalse);
    });
  });
}
