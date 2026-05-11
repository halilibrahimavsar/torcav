import '../../wifi_scan/domain/entities/wifi_band.dart';

/// Regional Wi-Fi channel allowlists.
///
/// Each region declares the per-band set of channel numbers that are legal
/// for unlicensed Wi-Fi use under that regulator. Channels outside these
/// sets are dimmed in the spectrum UI and excluded from the recommendation.
enum WifiRegion {
  /// Most permissive — useful when the user simply doesn't know.
  world,

  /// FCC (United States, parts of Latin America)
  us,

  /// ETSI (Europe, Türkiye, most of MENA)
  eu,

  /// Japan — extra 2.4 GHz channel 14 plus distinct 5 GHz lineup.
  jp,
}

class RegionAllowlist {
  /// Channels permitted on the 2.4 GHz band.
  final Set<int> band24;

  /// Channels permitted on 5 GHz.
  final Set<int> band5;

  /// Channels permitted on 6 GHz (Wi-Fi 6E / 7).
  final Set<int> band6;

  const RegionAllowlist({
    required this.band24,
    required this.band5,
    required this.band6,
  });

  bool isAllowed(int channel, int frequency) {
    return switch (bandFromFrequency(frequency)) {
      WifiBand.ghz24 => band24.contains(channel),
      WifiBand.ghz5 => band5.contains(channel),
      WifiBand.ghz6 => band6.contains(channel),
    };
  }

  static const _world = RegionAllowlist(
    band24: {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
    band5: {
      36,
      40,
      44,
      48,
      52,
      56,
      60,
      64,
      100,
      104,
      108,
      112,
      116,
      120,
      124,
      128,
      132,
      136,
      140,
      144,
      149,
      153,
      157,
      161,
      165,
      169,
      173,
      177,
    },
    band6: {
      // 1, 5, 9, ..., 233
      1, 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53, 57, 61, 65,
      69, 73, 77, 81, 85, 89, 93, 97, 101, 105, 109, 113, 117, 121, 125,
      129, 133, 137, 141, 145, 149, 153, 157, 161, 165, 169, 173, 177,
      181, 185, 189, 193, 197, 201, 205, 209, 213, 217, 221, 225, 229, 233,
    },
  );

  static const _us = RegionAllowlist(
    band24: {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11},
    band5: {
      36,
      40,
      44,
      48,
      52,
      56,
      60,
      64,
      100,
      104,
      108,
      112,
      116,
      120,
      124,
      128,
      132,
      136,
      140,
      144,
      149,
      153,
      157,
      161,
      165,
      169,
      173,
      177,
    },
    band6: {
      1,
      5,
      9,
      13,
      17,
      21,
      25,
      29,
      33,
      37,
      41,
      45,
      49,
      53,
      57,
      61,
      65,
      69,
      73,
      77,
      81,
      85,
      89,
      93,
      97,
      101,
      105,
      109,
      113,
      117,
      121,
      125,
      129,
      133,
      137,
      141,
      145,
      149,
      153,
      157,
      161,
      165,
      169,
      173,
      177,
      181,
      185,
      189,
      193,
      197,
      201,
      205,
      209,
      213,
      217,
      221,
      225,
      229,
      233,
    },
  );

  static const _eu = RegionAllowlist(
    // 2.4 GHz: 1-13 allowed; CH 14 reserved for Japan only.
    band24: {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13},
    // 5 GHz: 36-64 + 100-140; UNII-3 band (149-165) is restricted in EU
    // outside SRD, and CH 144 only allowed in some countries.
    band5: {
      36,
      40,
      44,
      48,
      52,
      56,
      60,
      64,
      100,
      104,
      108,
      112,
      116,
      120,
      124,
      128,
      132,
      136,
      140,
    },
    band6: {
      // Lower 6 GHz only (5945-6425 MHz, channels 1-93). Upper 6 GHz still
      // pending in most ETSI countries.
      1, 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53, 57, 61, 65,
      69, 73, 77, 81, 85, 89, 93,
    },
  );

  static const _jp = RegionAllowlist(
    band24: {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
    band5: {
      36,
      40,
      44,
      48,
      52,
      56,
      60,
      64,
      100,
      104,
      108,
      112,
      116,
      120,
      124,
      128,
      132,
      136,
      140,
    },
    band6: {
      1,
      5,
      9,
      13,
      17,
      21,
      25,
      29,
      33,
      37,
      41,
      45,
      49,
      53,
      57,
      61,
      65,
      69,
      73,
      77,
      81,
      85,
      89,
      93,
    },
  );

  static RegionAllowlist forRegion(WifiRegion r) {
    switch (r) {
      case WifiRegion.world:
        return _world;
      case WifiRegion.us:
        return _us;
      case WifiRegion.eu:
        return _eu;
      case WifiRegion.jp:
        return _jp;
    }
  }

  /// Best-effort default region from a Locale country code.
  static WifiRegion fromCountryCode(String? code) {
    if (code == null) return WifiRegion.world;
    final c = code.toUpperCase();
    if (c == 'US' || c == 'CA' || c == 'MX' || c == 'PR') return WifiRegion.us;
    if (c == 'JP') return WifiRegion.jp;
    // ETSI countries — large list; we treat the major TR/EU set explicitly.
    const etsi = {
      'TR',
      'DE',
      'FR',
      'IT',
      'ES',
      'GB',
      'NL',
      'BE',
      'AT',
      'CH',
      'SE',
      'NO',
      'DK',
      'FI',
      'IE',
      'PT',
      'GR',
      'PL',
      'CZ',
      'HU',
      'RO',
      'BG',
      'HR',
      'SK',
      'SI',
      'EE',
      'LV',
      'LT',
      'CY',
      'MT',
      'LU',
      'IS',
      'AL',
      'BA',
      'XK',
      'MK',
      'ME',
      'RS',
      'UA',
      'MD',
    };
    if (etsi.contains(c)) return WifiRegion.eu;
    return WifiRegion.world;
  }
}
