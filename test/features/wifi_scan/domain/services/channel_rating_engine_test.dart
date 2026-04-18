import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/features/wifi_scan/domain/services/channel_rating_engine.dart';

void main() {
  late ChannelRatingEngine engine;

  setUp(() {
    engine = ChannelRatingEngine();
  });

  group('ChannelRatingEngine', () {
    test('Perfect score on empty networks (minus DFS penalties)', () {
      final ratings = engine.calculateRatings([]);
      for (final r in ratings) {
        if (engine.isDfsChannel(r.channel, r.frequency)) {
          expect(r.rating, 9.5);
        } else {
          expect(r.rating, 10.0);
        }
      }
    });

    test('Penalty for same channel (CCI)', () {
      final network = WifiNetwork(
        ssid: 'Test AP',
        bssid: '00:11:22:33:44:55',
        signalStrength: -30, // Very strong
        channel: 1,
        frequency: 2412,
        security: SecurityType.wpa2,
        vendor: 'SomeVendor',
        isHidden: false,
      );

      final ratings = engine.calculateRatings([network]);
      final ch1 = ratings.firstWhere((r) => r.channel == 1);

      expect(ch1.rating, lessThan(10.0));
      expect(ch1.networkCount, 1);
    });

    test('Overlapping penalty (ACI) for 2.4GHz', () {
      final network = WifiNetwork(
        ssid: 'Strong AP on Ch 1',
        bssid: '00:11:22:33:44:55',
        signalStrength: -40,
        channel: 1,
        frequency: 2412,
        security: SecurityType.wpa2,
        vendor: 'SomeVendor',
        isHidden: false,
      );

      final ratings = engine.calculateRatings([network]);

      final ch1 = ratings.firstWhere((r) => r.channel == 1);
      final ch2 = ratings.firstWhere((r) => r.channel == 2);
      final ch6 = ratings.firstWhere((r) => r.channel == 6);

      // Ch 1 should have highest penalty
      // Ch 2 should be affected (overlap)
      // Ch 6 should be unaffected (non-overlapping)
      expect(ch1.rating, lessThan(ch2.rating));
      expect(ch2.rating, lessThan(ch6.rating));
      expect(ch6.rating, 10.0);
    });

    test('Signal strength affects penalty magnitude', () {
      final strong = WifiNetwork(
        ssid: 'Strong',
        bssid: 'AA:...',
        signalStrength: -30,
        channel: 1,
        frequency: 2412,
        security: SecurityType.wpa2,
        vendor: 'V',
        isHidden: false,
      );

      final weak = WifiNetwork(
        ssid: 'Weak',
        bssid: 'BB:...',
        signalStrength: -90,
        channel: 6,
        frequency: 2437,
        security: SecurityType.wpa2,
        vendor: 'V',
        isHidden: false,
      );

      final ratings = engine.calculateRatings([strong, weak]);

      final ch1 = ratings.firstWhere((r) => r.channel == 1);
      final ch6 = ratings.firstWhere((r) => r.channel == 6);

      expect(ch1.rating, lessThan(ch6.rating));
    });

    test('6GHz channels are included in ratings', () {
      final ratings = engine.calculateRatings([]);
      final ghz6Channels = ratings.where(
        (r) => r.channel > 165,
      ); // Simplified check for 6GHz

      expect(ghz6Channels, isNotEmpty);
      for (final r in ghz6Channels) {
        expect(r.rating, 10.0); // Should be perfect if unoccupied
      }
    });

    test('DFS channels receive baseline penalty', () {
      final ratings = engine.calculateRatings([]);

      // Ch 52 is DFS
      final ch52 = ratings.firstWhere((r) => r.channel == 52);
      // Ch 36 is Non-DFS
      final ch36 = ratings.firstWhere((r) => r.channel == 36);

      expect(ch52.rating, lessThan(ch36.rating));
      expect(ch52.rating, 9.5); // Fixed DFS penalty
    });
  });
}
