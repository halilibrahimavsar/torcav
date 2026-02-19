import 'package:injectable/injectable.dart';
import '../entities/channel_rating.dart';
import '../entities/wifi_network.dart';

/// Service that calculates quality ratings for Wi-Fi channels based on
/// detected network interference.
@lazySingleton
class ChannelRatingEngine {
  /// Standard 2.4GHz and 5GHz channels to analyze.
  static const _channels24 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
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

  /// Calculates ratings for all standard channels based on the provided [networks].
  List<ChannelRating> calculateRatings(List<WifiNetwork> networks) {
    final ratings = <ChannelRating>[];

    // Combine standard channels with any non-standard ones detected in the scan
    final usedChannels =
        networks.map((n) => n.channel).where((c) => c > 0).toSet();
    final allChannels =
        <int>{..._channels24, ..._channels5, ...usedChannels}.toList()..sort();

    for (final channel in allChannels) {
      final frequency = _guessFrequency(channel, networks);
      final is24 = frequency < 3000;

      double score = 10.0;
      int count = 0;

      for (final network in networks) {
        if (network.channel <= 0) continue;

        final dist = (network.channel - channel).abs();
        final sameBand = (network.frequency < 3000) == is24;

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
          // Count only same channel for density, but we could add overlap count too
        }
      }

      score = score.clamp(0.0, 10.0);

      ratings.add(
        ChannelRating(
          channel: channel,
          frequency: frequency,
          rating: score,
          networkCount: count,
          recommendation: _getRecommendation(score),
        ),
      );
    }

    return ratings;
  }

  int _guessFrequency(int channel, List<WifiNetwork> networks) {
    // Try to find frequency from actual scan
    try {
      final match = networks.firstWhere((n) => n.channel == channel);
      return match.frequency;
    } catch (_) {
      // Math fallback
      if (channel >= 1 && channel <= 14) {
        return 2412 + (channel - 1) * 5;
      }
      if (channel >= 36) {
        return 5000 + (channel * 5); // Approximate
      }
      return 0;
    }
  }

  String _getRecommendation(double score) {
    if (score >= 8.5) return 'Excellent';
    if (score >= 7.0) return 'Very Good';
    if (score >= 5.0) return 'Good';
    if (score >= 3.0) return 'Fair';
    return 'Congested';
  }
}
