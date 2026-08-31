import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/security/domain/services/auto_trust_policy.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

/// Trust here means "this fingerprint is the reference every later comparison
/// is measured against", so promoting the wrong network is not a cosmetic
/// mistake — it makes an impostor the baseline.
void main() {
  const policy = AutoTrustPolicy();

  test('a network seen once is not trusted', () {
    expect(
      policy.shouldTrust(seenCount: 0, security: SecurityType.wpa2),
      isFalse,
    );
  });

  test('a network seen twice is not yet trusted', () {
    expect(
      policy.shouldTrust(seenCount: 1, security: SecurityType.wpa2),
      isFalse,
    );
  });

  test('the third sighting earns trust', () {
    expect(
      policy.shouldTrust(seenCount: 2, security: SecurityType.wpa2),
      isTrue,
    );
  });

  test('an open network never earns trust, however often it is used', () {
    for (final count in [0, 2, 5, 50]) {
      expect(
        policy.shouldTrust(seenCount: count, security: SecurityType.open),
        isFalse,
        reason: 'open network trusted after $count sightings',
      );
    }
  });

  test('every non-open encryption type can earn trust', () {
    for (final security in SecurityType.values) {
      if (security == SecurityType.open) continue;
      expect(
        policy.shouldTrust(seenCount: 9, security: security),
        isTrue,
        reason: '$security never reaches trust',
      );
    }
  });
}
