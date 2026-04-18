import 'package:injectable/injectable.dart';
import '../entities/channel_rating.dart';
import '../entities/wifi_network.dart';

/// Service that calculates quality ratings for Wi-Fi channels based on
/// detected network interference.
@lazySingleton
class ChannelRatingEngine {
  /// Standard 2.4GHz and 5GHz channels to analyze.
  static const _channels24 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];

  static const _channels5 = [
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
    149,
    153,
    157,
    161,
    165,
  ];

  static const _channels6 = [
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
  ];

  /// Calculates ratings for all standard channels based on the provided [networks].
  List<ChannelRating> calculateRatings(List<WifiNetwork> networks) {
    final ratings = <ChannelRating>[];

    // Combine standard channels with any non-standard ones detected in the scan
    final usedChannels =
        networks.map((n) => n.channel).where((c) => c > 0).toSet();
    final allChannels =
        <int>{
            ..._channels24,
            ..._channels5,
            ..._channels6,
            ...usedChannels,
          }.toList()
          ..sort();

    for (final channel in allChannels) {
      final frequency = _guessFrequency(channel, networks);
      if (frequency <= 0) continue;

      final is24 = frequency >= 2400 && frequency < 2500;
      final is5 = frequency >= 5000 && frequency < 6000;
      final is6 = frequency >= 5925 && frequency < 7200;

      double score = 10.0;
      int count = 0;

      for (final network in networks) {
        if (network.channel <= 0) continue;

        final dist = (network.channel - channel).abs();
        final nFreq = network.frequency;

        // Check if network is in the same band
        final sameBand =
            (nFreq >= 2400 && nFreq < 2500 && is24) ||
            (nFreq >= 5000 && nFreq < 6000 && is5) ||
            (nFreq >= 5925 && nFreq < 7200 && is6);

        if (!sameBand) continue;

        // Signal weight: -30dBm (Strong) -> ~2.0, -100dBm (Weak) -> ~1.0
        final signalWeight =
            1.0 + ((network.signalStrength + 100) / 70.0).clamp(0.0, 1.0);

        if (dist == 0) {
          // Co-Channel Interference (CCI)
          score -= 2.0 * signalWeight;
          count++;
        } else if (is24 && dist < 5) {
          // Adjacent Channel Interference (ACI) - Significant for 2.4GHz
          final penalty = switch (dist) {
            1 => 1.5,
            2 => 1.0,
            3 => 0.5,
            4 => 0.2,
            _ => 0.0,
          };
          score -= penalty * signalWeight;
        }
      }

      // Apply a subtle penalty for DFS channels (radar interference risk)
      if (is5 && isDfsChannel(channel, frequency)) {
        score -= 0.5;
      }

      score = score.clamp(0.0, 10.0);

      ratings.add(
        ChannelRating(
          channel: channel,
          frequency: frequency,
          rating: score,
          networkCount: count,
          quality: _getQuality(score),
        ),
      );
    }

    return ratings;
  }

  /// Checks if a 5GHz channel is subject to Dynamic Frequency Selection (DFS).
  bool isDfsChannel(int channel, int frequency) {
    if (frequency < 5000 || frequency >= 6000) return false;
    // 5GHz DFS ranges: 52-64 (U-NII-2A) and 100-144 (U-NII-2C)
    return (channel >= 52 && channel <= 64) ||
        (channel >= 100 && channel <= 144);
  }

  int _guessFrequency(int channel, List<WifiNetwork> networks) {
    // 1. Try to find frequency from actual scan results
    for (final network in networks) {
      if (network.channel == channel) {
        return network.frequency;
      }
    }

    // 2. Math fallback for standard channels
    // 2.4 GHz Band
    if (channel >= 1 && channel <= 13) {
      return 2412 + (channel - 1) * 5;
    }
    if (channel == 14) {
      return 2484;
    }

    // 5 GHz Band
    if (channel >= 36 && channel <= 177) {
      return 5000 + (channel * 5);
    }

    // 6 GHz Band (U-NII-5 through 8)
    // Formula for 6GHz: frequency = 5950 + (channel * 5)
    // Note: This block handles channels where channel * 5 > 900+ usually.
    if (channel >= 1 && channel <= 233) {
      // If we are here, it's not 2.4GHz 1-13.
      return 5950 + (channel * 5);
    }

    return 0;
  }

  ChannelQuality _getQuality(double score) {
    if (score >= 8.5) return ChannelQuality.excellent;
    if (score >= 7.0) return ChannelQuality.veryGood;
    if (score >= 5.0) return ChannelQuality.good;
    if (score >= 3.0) return ChannelQuality.fair;
    return ChannelQuality.congested;
  }
}
