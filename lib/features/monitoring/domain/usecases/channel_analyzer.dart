import 'package:injectable/injectable.dart';
import '../../../../features/wifi_scan/domain/entities/wifi_network.dart';
import '../entities/channel_rating.dart';

@lazySingleton
class ChannelAnalyzer {
  List<ChannelRating> analyzeChannels(List<WifiNetwork> networks) {
    if (networks.isEmpty) return [];

    // Analyze 2.4GHz and 5GHz separately
    final networks24 = networks.where((n) => n.frequency < 3000).toList();
    final networks5 = networks.where((n) => n.frequency >= 5000).toList();

    final ratings24 = _rate24GHzChannels(networks24);
    final ratings5 = _rate5GHzChannels(networks5);

    // Return combined sorted list (highest rating first)
    return [...ratings24, ...ratings5]
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  List<ChannelRating> _rate24GHzChannels(List<WifiNetwork> networks) {
    // 2.4GHz channels: 1-14. Focus on 1, 6, 11 (non-overlapping usually)
    const channels = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
    final ratings = <ChannelRating>[];

    for (final channel in channels) {
      double score = 10.0;
      int count = 0;

      for (final network in networks) {
        // Interference calculation
        // Same channel: Heavy penalty
        // Adjacent +/- 1: Medium penalty
        // Adjacent +/- 2: Low penalty
        if (network.channel == channel) {
          score -= 2.0; // Heavy penalty for direct overlap
          count++;
        } else if ((network.channel - channel).abs() == 1) {
          score -= 1.0;
        } else if ((network.channel - channel).abs() == 2) {
          score -= 0.5;
        }
      }

      if (score < 0) score = 0;

      String recommendation = 'Excellent';
      if (score < 3) {
        recommendation = 'Congested';
      } else if (score < 7) {
        recommendation = 'Fair';
      }

      ratings.add(
        ChannelRating(
          channel: channel,
          frequency: 2412 + (channel - 1) * 5, // Approx calc
          rating: score,
          networkCount: count,
          recommendation: recommendation,
        ),
      );
    }
    return ratings;
  }

  List<ChannelRating> _rate5GHzChannels(List<WifiNetwork> networks) {
    // 5GHz channels are less overlapping, mainly check for direct contention
    // Simplified list of common 5GHz channels
    const channels = [36, 40, 44, 48, 149, 153, 157, 161, 165];
    // In reality, there are many more (DFS etc), but let's stick to common ones for now or dynamic

    // Dynamic approach: Identify all used channels + standard non-overlapping ones
    final usedChannels = networks.map((n) => n.channel).toSet();
    final allChannels = {...channels, ...usedChannels}.toList()..sort();

    final ratings = <ChannelRating>[];

    for (final channel in allChannels) {
      double score = 10.0;
      int count = 0;

      for (final network in networks) {
        if (network.channel == channel) {
          score -= 2.0;
          count++;
        }
      }

      if (score < 0) score = 0;

      String recommendation = 'Excellent';
      if (score < 3) {
        recommendation = 'Congested';
      } else if (score < 7) {
        recommendation = 'Fair';
      }

      // Approximate frequency
      int freq = 5000 + channel * 5;

      ratings.add(
        ChannelRating(
          channel: channel,
          frequency: freq,
          rating: score,
          networkCount: count,
          recommendation: recommendation,
        ),
      );
    }

    return ratings;
  }
}
