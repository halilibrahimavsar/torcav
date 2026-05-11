import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/security/domain/entities/evil_twin_assessment.dart';
import 'package:torcav/features/security/domain/services/evil_twin_classifier.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

void main() {
  const classifier = EvilTwinClassifier();

  WifiNetwork net({
    String ssid = 'Home',
    String bssid = 'AA:BB:CC:DD:EE:01',
    int channel = 36,
    int frequency = 5180,
    SecurityType security = SecurityType.wpa3,
    String vendor = 'Asus',
    bool isHidden = false,
    int? channelWidthMhz,
    bool? hasWps,
    bool? hasPmf,
    String? apMldMac,
  }) {
    return WifiNetwork(
      ssid: ssid,
      bssid: bssid,
      signalStrength: -45,
      channel: channel,
      frequency: frequency,
      security: security,
      vendor: vendor,
      isHidden: isHidden,
      channelWidthMhz: channelWidthMhz,
      hasWps: hasWps,
      hasPmf: hasPmf,
      apMldMac: apMldMac,
    );
  }

  group('early dismissal — dual-band / mesh / Wi-Fi 7', () {
    test(
      'legitimate dual-band sibling (2.4 + 5 GHz, same vendor) dismissed',
      () {
        final target = net(channel: 36, frequency: 5180);
        final peer = net(
          bssid: 'AA:BB:CC:DD:EE:11',
          channel: 6,
          frequency: 2437,
        );
        final result = classifier.assess(target, peer);
        expect(result.dismissedAsLegitimate, isTrue);
        expect(result.confidence, 0);
        expect(result.isCandidate, isFalse);
        expect(result.mitigations, contains(EvilTwinSignal.crossBandSibling));
      },
    );

    test('Wi-Fi 7 multi-link (shared MLD MAC) dismissed', () {
      const mld = 'AB:CD:EF:00:11:22';
      final target = net(apMldMac: mld);
      final peer = net(
        bssid: 'FF:EE:DD:CC:BB:AA',
        channel: 6,
        frequency: 2437,
        vendor: 'Other',
        security: SecurityType.wpa2,
        apMldMac: mld,
      );
      final result = classifier.assess(target, peer);
      expect(result.dismissedAsLegitimate, isTrue);
      expect(result.mitigations, contains(EvilTwinSignal.sharedMldMac));
    });

    test('mesh sibling with sequential BSSID dismissed', () {
      final target = net(bssid: 'AA:BB:CC:DD:EE:01');
      final peer = net(bssid: 'AA:BB:CC:DD:EE:02');
      final result = classifier.assess(target, peer);
      expect(result.dismissedAsLegitimate, isTrue);
      expect(result.mitigations, contains(EvilTwinSignal.bssidProximity));
    });
  });

  group('genuine evil-twin patterns', () {
    test('flags vendor mismatch + security downgrade as high confidence', () {
      final target = net(
        bssid: 'AA:BB:CC:DD:EE:01',
        security: SecurityType.wpa3,
        vendor: 'Asus',
      );
      final peer = net(
        bssid: '11:22:33:44:55:66',
        security: SecurityType.open,
        vendor: 'Generic',
      );
      final result = classifier.assess(target, peer);
      expect(result.dismissedAsLegitimate, isFalse);
      expect(result.isCandidate, isTrue);
      expect(result.confidence, greaterThanOrEqualTo(0.75));
      expect(result.suspicions, contains(EvilTwinSignal.ouiMismatch));
      expect(result.suspicions, contains(EvilTwinSignal.securityDowngrade));
    });

    test('same band, far apart channel + width mismatch flagged', () {
      final target = net(
        bssid: 'AA:BB:CC:DD:EE:01',
        channel: 36,
        frequency: 5180,
        channelWidthMhz: 80,
      );
      final peer = net(
        bssid: '11:22:33:44:55:66',
        channel: 161,
        frequency: 5805,
        channelWidthMhz: 20,
      );
      final result = classifier.assess(target, peer);
      expect(result.isCandidate, isTrue);
      expect(
        result.suspicions,
        containsAll([
          EvilTwinSignal.sameBandChannelDrift,
          EvilTwinSignal.channelWidthMismatch,
        ]),
      );
    });

    test('hidden vs visible alone (same OUI, same security) does not flag', () {
      // Same OUI prefix → no ouiMismatch. Same security → no downgrade.
      // Same band, channels are 4 apart so channel-drift doesn't fire either.
      // Only the hiddenVsVisible signal (0.20) is below threshold (0.50).
      final target = net(
        bssid: 'AA:BB:CC:DD:EE:01',
        channel: 36,
        frequency: 5180,
        isHidden: false,
      );
      final peer = net(
        bssid: 'AA:BB:CC:99:88:77',
        channel: 36,
        frequency: 5180,
        isHidden: true,
      );
      final result = classifier.assess(target, peer);
      expect(result.isCandidate, isFalse);
      expect(result.suspicions, contains(EvilTwinSignal.hiddenVsVisible));
    });
  });

  group('confidence scaling', () {
    test('downgrade alone with same OUI falls below threshold', () {
      final target = net(
        bssid: 'AA:BB:CC:DD:EE:01',
        security: SecurityType.wpa3,
      );
      // Pure downgrade with same OUI prefix should sit below threshold.
      final samePrefix = net(
        bssid: 'AA:BB:CC:99:88:77',
        security: SecurityType.open,
        vendor: 'Different', // breaks crossBandSibling mitigation for same band
        channel: 36,
        frequency: 5180,
      );
      final result = classifier.assess(target, samePrefix);
      // OUI prefix matches (AA:BB:CC), so only securityDowngrade fires.
      // 0.4 < 0.5 threshold.
      expect(
        result.confidence,
        lessThan(EvilTwinClassifier.candidateThreshold),
      );
    });

    test('high confidence pair triggers candidate flag', () {
      final target = net(
        bssid: 'AA:BB:CC:DD:EE:01',
        security: SecurityType.wpa3,
        channelWidthMhz: 80,
        hasWps: false,
      );
      final peer = net(
        bssid: '11:22:33:44:55:66',
        security: SecurityType.open,
        channelWidthMhz: 20,
        hasWps: true,
      );
      final result = classifier.assess(target, peer);
      expect(result.confidence, greaterThanOrEqualTo(0.75));
      expect(result.isCandidate, isTrue);
    });
  });

  group('assessAll', () {
    test('returns the worst peer when multiple are present', () {
      final target = net(bssid: 'AA:BB:CC:DD:EE:01');
      final peers = [
        net(bssid: 'AA:BB:CC:DD:EE:02'), // legit mesh sibling (BSSID close)
        net(
          bssid: '11:22:33:44:55:66',
          security: SecurityType.open,
          vendor: 'Generic',
        ), // suspicious
      ];
      final result = classifier.assessAll(target, peers);
      expect(result.dismissedAsLegitimate, isFalse);
      expect(result.isCandidate, isTrue);
      expect(result.peerBssid, '11:22:33:44:55:66');
    });

    test('returns dismissal when every peer is legit', () {
      final target = net(bssid: 'AA:BB:CC:DD:EE:01');
      final peers = [
        net(bssid: 'AA:BB:CC:DD:EE:02'), // BSSID close
      ];
      final result = classifier.assessAll(target, peers);
      expect(result.dismissedAsLegitimate, isTrue);
    });

    test('returns "none" when no same-SSID peer exists', () {
      final target = net();
      final peers = [net(ssid: 'OtherNet', bssid: '11:22:33:44:55:66')];
      final result = classifier.assessAll(target, peers);
      expect(result.suspicions, isEmpty);
      expect(result.confidence, 0);
      expect(result.dismissedAsLegitimate, isFalse);
    });

    test('user-trusted peer BSSID short-circuits to legitimate', () {
      final target = net(bssid: 'AA:BB:CC:DD:EE:01');
      final peers = [
        // Would normally flag — different OUI + open security.
        net(
          bssid: '11:22:33:44:55:66',
          security: SecurityType.open,
          vendor: 'Generic',
        ),
      ];
      final result = classifier.assessAll(
        target,
        peers,
        trustedBssids: {'11:22:33:44:55:66'},
      );
      expect(result.dismissedAsLegitimate, isTrue);
      expect(result.isCandidate, isFalse);
    });
  });
}
