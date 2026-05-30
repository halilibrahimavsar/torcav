import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/monitoring/domain/wifi_region.dart';

void main() {
  group('RegionAllowlist.isAllowed', () {
    test('US 2.4 GHz allows 1..11 but rejects 12, 13, 14', () {
      final us = RegionAllowlist.forRegion(WifiRegion.us);
      for (var ch = 1; ch <= 11; ch++) {
        // frequency irrelevant aside from band; use 2412 + (ch-1)*5
        expect(us.isAllowed(ch, 2412), isTrue, reason: 'CH $ch should be ok');
      }
      expect(us.isAllowed(12, 2467), isFalse);
      expect(us.isAllowed(13, 2472), isFalse);
      expect(us.isAllowed(14, 2484), isFalse);
    });

    test('EU 2.4 GHz allows 1..13 but rejects 14', () {
      final eu = RegionAllowlist.forRegion(WifiRegion.eu);
      expect(eu.isAllowed(13, 2472), isTrue);
      expect(eu.isAllowed(14, 2484), isFalse);
    });

    test('JP 2.4 GHz allows CH 14', () {
      final jp = RegionAllowlist.forRegion(WifiRegion.jp);
      expect(jp.isAllowed(14, 2484), isTrue);
    });

    test('EU 5 GHz rejects UNII-3 (149..165)', () {
      final eu = RegionAllowlist.forRegion(WifiRegion.eu);
      expect(eu.isAllowed(149, 5745), isFalse);
      expect(eu.isAllowed(165, 5825), isFalse);
    });

    test('US 5 GHz allows UNII-3 (149..165)', () {
      final us = RegionAllowlist.forRegion(WifiRegion.us);
      expect(us.isAllowed(149, 5745), isTrue);
      expect(us.isAllowed(165, 5825), isTrue);
    });

    test('EU 6 GHz allows lower band (1..93) and rejects upper', () {
      final eu = RegionAllowlist.forRegion(WifiRegion.eu);
      expect(eu.isAllowed(93, 6425), isTrue);
      expect(eu.isAllowed(97, 6445), isFalse);
    });
  });

  group('WifiRegion.fromCountryCode', () {
    test('returns world for null code', () {
      expect(RegionAllowlist.fromCountryCode(null), WifiRegion.world);
    });

    test('returns us for US/CA/MX/PR', () {
      for (final c in ['US', 'CA', 'MX', 'PR']) {
        expect(RegionAllowlist.fromCountryCode(c), WifiRegion.us);
      }
    });

    test('returns jp for JP', () {
      expect(RegionAllowlist.fromCountryCode('JP'), WifiRegion.jp);
    });

    test('returns eu for ETSI codes including TR, DE, GB', () {
      for (final c in ['TR', 'DE', 'GB', 'FR', 'IT']) {
        expect(RegionAllowlist.fromCountryCode(c), WifiRegion.eu);
      }
    });

    test('lower-case codes are accepted', () {
      expect(RegionAllowlist.fromCountryCode('jp'), WifiRegion.jp);
      expect(RegionAllowlist.fromCountryCode('us'), WifiRegion.us);
    });

    test('unknown code falls back to world', () {
      expect(RegionAllowlist.fromCountryCode('ZZ'), WifiRegion.world);
    });
  });
}
