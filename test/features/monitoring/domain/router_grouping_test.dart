import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/monitoring/domain/router_grouping.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('groupDualBandRouters', () {
    test('returns empty list when input is empty', () {
      expect(groupDualBandRouters(const []), isEmpty);
    });

    test('skips hidden / empty-SSID networks', () {
      final groups = groupDualBandRouters([
        buildWifiNetwork(
          ssid: '',
          bssid: 'AA:BB:CC:DD:EE:01',
        ),
        buildWifiNetwork(
          ssid: '',
          bssid: 'AA:BB:CC:DD:EE:11',
          frequency: 5180,
        ),
      ]);
      expect(groups, isEmpty);
    });

    test('skips single-band SSID groups', () {
      final groups = groupDualBandRouters([
        buildWifiNetwork(
          ssid: 'Home',
          bssid: 'AA:BB:CC:DD:EE:01',
        ),
        buildWifiNetwork(
          ssid: 'Home',
          bssid: 'AA:BB:CC:DD:EE:02',
          frequency: 2462,
        ),
      ]);
      expect(groups, isEmpty);
    });

    test('groups dual-band networks sharing SSID + BSSID prefix', () {
      final groups = groupDualBandRouters([
        buildWifiNetwork(
          ssid: 'Home',
          bssid: 'AA:BB:CC:DD:EE:01',
        ),
        buildWifiNetwork(
          ssid: 'Home',
          bssid: 'AA:BB:CC:DD:EE:11',
          frequency: 5180,
          signalStrength: -60,
        ),
      ]);

      expect(groups, hasLength(1));
      expect(groups.first.ssid, 'Home');
      expect(groups.first.radios, hasLength(2));
    });

    test('keeps only the strongest radio per band', () {
      final groups = groupDualBandRouters([
        buildWifiNetwork(
          ssid: 'Home',
          bssid: 'AA:BB:CC:DD:EE:01',
          signalStrength: -70,
        ),
        buildWifiNetwork(
          ssid: 'Home',
          bssid: 'AA:BB:CC:DD:EE:02',
          frequency: 2462,
          signalStrength: -50, // stronger 2.4 GHz
        ),
        buildWifiNetwork(
          ssid: 'Home',
          bssid: 'AA:BB:CC:DD:EE:11',
          frequency: 5180,
        ),
      ]);

      expect(groups, hasLength(1));
      expect(groups.first.radios, hasLength(2));
      final band24Radio = groups.first.radios.firstWhere(
        (r) => r.frequency < 5000,
      );
      expect(band24Radio.signalStrength, -50);
    });

    test('sorts groups by strongest signal first', () {
      final groups = groupDualBandRouters([
        // weaker pair
        buildWifiNetwork(
          ssid: 'WeakNet',
          bssid: '11:22:33:44:55:01',
          signalStrength: -85,
        ),
        buildWifiNetwork(
          ssid: 'WeakNet',
          bssid: '11:22:33:44:55:11',
          frequency: 5180,
          signalStrength: -80,
        ),
        // stronger pair
        buildWifiNetwork(
          ssid: 'StrongNet',
          bssid: 'AA:BB:CC:DD:EE:01',
          signalStrength: -45,
        ),
        buildWifiNetwork(
          ssid: 'StrongNet',
          bssid: 'AA:BB:CC:DD:EE:11',
          frequency: 5180,
        ),
      ]);

      expect(groups.map((g) => g.ssid).toList(), ['StrongNet', 'WeakNet']);
    });
  });

  group('crossBandSiblingsOf', () {
    test('returns empty for hidden / empty-SSID target', () {
      final target = buildWifiNetwork(ssid: '');
      expect(crossBandSiblingsOf(target, const []), isEmpty);
    });

    test('returns siblings that share SSID + prefix but differ in band', () {
      final target = buildWifiNetwork(
        ssid: 'Home',
        bssid: 'AA:BB:CC:DD:EE:01',
      );
      final all = [
        target,
        buildWifiNetwork(
          ssid: 'Home',
          bssid: 'AA:BB:CC:DD:EE:11',
          frequency: 5180,
        ),
        buildWifiNetwork(
          ssid: 'Other',
          bssid: 'AA:BB:CC:DD:EE:12',
          frequency: 5180,
        ),
      ];

      final siblings = crossBandSiblingsOf(target, all);
      expect(siblings, hasLength(1));
      expect(siblings.first.bssid, 'AA:BB:CC:DD:EE:11');
    });

    test('excludes targets with different BSSID prefix', () {
      final target = buildWifiNetwork(
        ssid: 'Home',
        bssid: 'AA:BB:CC:DD:EE:01',
      );
      final candidate = buildWifiNetwork(
        ssid: 'Home',
        bssid: '11:22:33:44:55:11', // different prefix
        frequency: 5180,
      );
      expect(crossBandSiblingsOf(target, [target, candidate]), isEmpty);
    });
  });
}
