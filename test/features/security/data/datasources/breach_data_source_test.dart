import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/security/data/datasources/breach_data_source.dart';

void main() {
  group('BreachDataSource.matchExposureCount', () {
    // A Pwned Passwords range response is a list of `SUFFIX:COUNT` lines.
    const sampleBody =
        '0018A45C4D1DEF81644B54AB7F969B88D65:1\r\n'
        '00D4F6E8FA6EECAD2A3AA415EEC418D38EC:2\r\n'
        '011053FD0102E94D6AE2F8B83D76FAF94F6:1';

    test('returns the exposure count for a matching suffix', () {
      expect(
        BreachDataSource.matchExposureCount(
          sampleBody,
          '00D4F6E8FA6EECAD2A3AA415EEC418D38EC',
        ),
        2,
      );
    });

    test('matching is case-insensitive on the suffix', () {
      expect(
        BreachDataSource.matchExposureCount(
          sampleBody,
          '0018a45c4d1def81644b54ab7f969b88d65',
        ),
        1,
      );
    });

    test('returns 0 when the suffix is absent', () {
      expect(
        BreachDataSource.matchExposureCount(sampleBody, 'FFFFFFFFFFFFFFF'),
        0,
      );
    });

    test('ignores malformed lines without crashing', () {
      expect(
        BreachDataSource.matchExposureCount('garbage\n\n:::\nABC', 'ABC'),
        0,
      );
    });

    test('k-anonymity: only a 5-char hash prefix identifies the query', () {
      // The well-known leaked password "password" — SHA-1 split into the
      // prefix that would be sent and the suffix matched locally.
      final digest =
          sha1.convert('password'.codeUnits).toString().toUpperCase();
      final prefix = digest.substring(0, 5);
      final suffix = digest.substring(5);

      expect(prefix, '5BAA6');
      expect(prefix.length, 5);

      // The suffix is resolved locally against the range body.
      final body = '$suffix:9999999\r\nOTHERSUFFIX:1';
      expect(BreachDataSource.matchExposureCount(body, suffix), 9999999);
    });
  });
}
