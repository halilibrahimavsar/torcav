import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_band.dart';

void main() {
  group('bandFromFrequency', () {
    test('classifies 2.4 GHz', () {
      expect(bandFromFrequency(2412), WifiBand.ghz24);
      expect(bandFromFrequency(2484), WifiBand.ghz24);
      expect(bandFromFrequency(2400), WifiBand.ghz24);
    });

    test('classifies 5 GHz', () {
      expect(bandFromFrequency(5180), WifiBand.ghz5);
      expect(bandFromFrequency(5825), WifiBand.ghz5);
      expect(bandFromFrequency(5000), WifiBand.ghz5);
    });

    test('classifies 6 GHz', () {
      expect(bandFromFrequency(5955), WifiBand.ghz6);
      expect(bandFromFrequency(6175), WifiBand.ghz6);
      expect(bandFromFrequency(7115), WifiBand.ghz6);
    });

    test('disambiguates channel 1 by frequency', () {
      // bandFromChannel(1) returns ghz24 for both rows — the bug we documented.
      expect(bandFromChannel(1), WifiBand.ghz24);
      // bandFromFrequency uses MHz so 5955 (6 GHz CH 1) is correctly classified.
      expect(bandFromFrequency(5955), WifiBand.ghz6);
      expect(bandFromFrequency(2412), WifiBand.ghz24);
    });
  });

  group('bandIndex / bandShortLabel', () {
    test('produces tab indices', () {
      expect(bandIndex(WifiBand.ghz24), 0);
      expect(bandIndex(WifiBand.ghz5), 1);
      expect(bandIndex(WifiBand.ghz6), 2);
    });

    test('produces short labels', () {
      expect(bandShortLabel(WifiBand.ghz24), '2.4 GHz');
      expect(bandShortLabel(WifiBand.ghz5), '5 GHz');
      expect(bandShortLabel(WifiBand.ghz6), '6 GHz');
    });
  });
}
