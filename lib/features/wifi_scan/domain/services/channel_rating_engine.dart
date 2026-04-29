import 'package:injectable/injectable.dart';
import '../entities/channel_rating.dart';
import '../entities/wifi_network.dart';

/// Service that calculates quality ratings for Wi-Fi channels based on
/// detected network interference.
@lazySingleton
class ChannelRatingEngine {
  /// Standard 2.4 GHz channels with their canonical center frequencies (MHz).
  static final Map<int, int> _channels24 = {
    for (var c = 1; c <= 13; c++) c: 2412 + (c - 1) * 5,
    14: 2484,
  };

  /// Standard 5 GHz channels with canonical frequencies. 5000 + ch*5.
  static final Map<int, int> _channels5 = {
    for (final c in const [
      36, 40, 44, 48, 52, 56, 60, 64,
      100, 104, 108, 112, 116, 120, 124, 128, 132, 136, 140, 144,
      149, 153, 157, 161, 165, 169, 173, 177,
    ])
      c: 5000 + c * 5,
  };

  /// Standard 6 GHz channels (UNII-5..8). 5950 + ch*5.
  static final Map<int, int> _channels6 = {
    for (var c = 1; c <= 233; c += 4) c: 5950 + c * 5,
  };

  /// Calculates ratings for all standard channels based on the provided [networks].
  List<ChannelRating> calculateRatings(List<WifiNetwork> networks) {
    // Build a band-aware seed: a (channel, frequency) pair for every standard
    // slot, plus any non-standard channels actually observed in the scan.
    // Using frequency as a tiebreaker prevents 6 GHz CH 1 (5955 MHz) from
    // colliding with 2.4 GHz CH 1 (2412 MHz) — they are distinct rows.
    final seeds = <_ChannelKey>{};
    for (final entry in _channels24.entries) {
      seeds.add(_ChannelKey(entry.key, entry.value));
    }
    for (final entry in _channels5.entries) {
      seeds.add(_ChannelKey(entry.key, entry.value));
    }
    for (final entry in _channels6.entries) {
      seeds.add(_ChannelKey(entry.key, entry.value));
    }
    for (final n in networks) {
      if (n.channel > 0 && n.frequency > 0) {
        seeds.add(_ChannelKey(n.channel, n.frequency));
      }
    }

    final sorted =
        seeds.toList()..sort((a, b) {
          final c = a.frequency.compareTo(b.frequency);
          return c != 0 ? c : a.channel.compareTo(b.channel);
        });

    final ratings = <ChannelRating>[];
    for (final key in sorted) {
      final channel = key.channel;
      final frequency = key.frequency;

      final is24 = frequency >= 2400 && frequency < 2500;
      final is5 = frequency >= 5000 && frequency < 5925;
      final is6 = frequency >= 5925 && frequency < 7200;
      if (!is24 && !is5 && !is6) continue;

      double score = 10.0;
      int count = 0;

      for (final network in networks) {
        if (network.channel <= 0) continue;
        final nFreq = network.frequency;

        // Same-band test by frequency (not channel number, to avoid the
        // 2.4/6 GHz channel-number overlap).
        final sameBand =
            (is24 && nFreq >= 2400 && nFreq < 2500) ||
            (is5 && nFreq >= 5000 && nFreq < 5925) ||
            (is6 && nFreq >= 5925 && nFreq < 7200);
        if (!sameBand) continue;

        // Signal weight: -30dBm (Strong) -> ~2.0, -100dBm (Weak) -> ~1.0
        final signalWeight =
            1.0 + ((network.signalStrength + 100) / 70.0).clamp(0.0, 1.0);

        final dist = (network.channel - channel).abs();
        if (dist == 0) {
          // Co-Channel Interference (CCI)
          score -= 2.0 * signalWeight;
          count++;
        } else if (is24 && dist < 5) {
          // Adjacent Channel Interference (ACI) — significant on 2.4 GHz only.
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

      final dfs = is5 && isDfsChannel(channel, frequency);
      if (dfs) score -= 0.5;

      score = score.clamp(0.0, 10.0);

      ratings.add(
        ChannelRating(
          channel: channel,
          frequency: frequency,
          rating: score,
          networkCount: count,
          quality: _getQuality(score),
          isDfs: dfs,
        ),
      );
    }

    return ratings;
  }

  /// Checks if a 5 GHz channel is subject to Dynamic Frequency Selection (DFS).
  bool isDfsChannel(int channel, int frequency) {
    if (frequency < 5000 || frequency >= 5925) return false;
    // 5GHz DFS ranges: 52-64 (U-NII-2A) and 100-144 (U-NII-2C)
    return (channel >= 52 && channel <= 64) ||
        (channel >= 100 && channel <= 144);
  }

  ChannelQuality _getQuality(double score) {
    if (score >= 8.5) return ChannelQuality.excellent;
    if (score >= 7.0) return ChannelQuality.veryGood;
    if (score >= 5.0) return ChannelQuality.good;
    if (score >= 3.0) return ChannelQuality.fair;
    return ChannelQuality.congested;
  }
}

class _ChannelKey {
  final int channel;
  final int frequency;
  const _ChannelKey(this.channel, this.frequency);

  @override
  bool operator ==(Object other) =>
      other is _ChannelKey &&
      other.channel == channel &&
      other.frequency == frequency;

  @override
  int get hashCode => Object.hash(channel, frequency);
}
