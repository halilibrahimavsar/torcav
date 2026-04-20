import 'package:injectable/injectable.dart';

import '../../../../core/utils/oui_lookup.dart';

import '../../domain/entities/band_analysis_stat.dart';
import '../../domain/entities/channel_occupancy_stat.dart';
import '../../domain/entities/scan_snapshot.dart';
import '../../domain/entities/wifi_network.dart';
import '../../domain/entities/wifi_observation.dart';
import '../../domain/entities/wifi_band.dart';

@injectable
class ScanSnapshotBuilder {
  final OuiLookup _ouiLookup;

  const ScanSnapshotBuilder(this._ouiLookup);

  Future<ScanSnapshot> build({
    required DateTime timestamp,
    required String backendUsed,
    required String interfaceName,
    required List<List<WifiNetwork>> passes,
    bool isFromCache = false,
  }) async {
    final observations = await _buildObservations(passes);
    final channelStats = _buildChannelStats(observations);
    final bandStats = _buildBandStats(observations, channelStats);

    return ScanSnapshot(
      timestamp: timestamp,
      backendUsed: backendUsed,
      interfaceName: interfaceName,
      networks: observations,
      channelStats: channelStats,
      bandStats: bandStats,
      isFromCache: isFromCache,
    );
  }

  Future<List<WifiObservation>> _buildObservations(
    List<List<WifiNetwork>> passes,
  ) async {
    final accumulators = <String, _ObservationAccumulator>{};

    for (final pass in passes) {
      for (final network in pass) {
        final normalizedBssid = network.bssid.toUpperCase();
        final entry =
            accumulators[normalizedBssid] ??= _ObservationAccumulator(network);
        entry.addSample(network.signalStrength);
        entry.updateFrom(network);
      }
    }

    final observations = await Future.wait(
      accumulators.values.map((entry) async {
        final isRandomized = ScanSnapshotBuilder.detectBssidRandomization(
          entry.bssid,
        );
        final vendor = await _ouiLookup.lookup(entry.bssid);
        final spatialStreams = ScanSnapshotBuilder.estimateSpatialStreams(
          entry.wifiStandard,
        );
        final throughput = ScanSnapshotBuilder.estimateThroughput(
          standard: entry.wifiStandard,
          widthMhz: entry.channelWidthMhz,
          streams: spatialStreams,
        );

        return WifiObservation.fromSamples(
          ssid: entry.ssid,
          bssid: entry.bssid,
          samples: entry.samples,
          channel: entry.channel,
          frequency: entry.frequency,
          security: entry.security,
          vendor: vendor,
          isHidden: entry.isHidden || entry.ssid.isEmpty,
          seenCount: entry.samples.length,
          channelWidthMhz: entry.channelWidthMhz,
          wifiStandard: entry.wifiStandard,
          hasWps: entry.hasWps,
          hasPmf: entry.hasPmf,
          rawCapabilities: entry.rawCapabilities,
          apMldMac: entry.apMldMac,
          estimatedMaxThroughputMbps: throughput,
          spatialStreams: spatialStreams,
          isRandomizedBssid: isRandomized,
        );
      }),
    );

    observations.sort((a, b) => b.avgSignalDbm.compareTo(a.avgSignalDbm));
    return observations;
  }

  static bool detectBssidRandomization(String bssid) {
    if (bssid.length < 2) return false;
    // Check the LAA (Locally Administered Address) bit:
    // The second hex digit of the first byte must be 2, 6, A, or E.
    final secondChar = bssid[1].toUpperCase();
    return secondChar == '2' ||
        secondChar == '6' ||
        secondChar == 'A' ||
        secondChar == 'E';
  }

  static int estimateSpatialStreams(WifiStandard? standard) {
    if (standard == null) return 1;
    return switch (standard) {
      WifiStandard.legacy => 1,
      WifiStandard.n => 2,
      WifiStandard.ac => 2,
      WifiStandard.ax => 2,
      WifiStandard.be => 2,
      WifiStandard.unknown => 1,
    };
  }

  static double? estimateThroughput({
    required WifiStandard? standard,
    required int? widthMhz,
    required int streams,
  }) {
    if (standard == null || widthMhz == null) return null;

    // Simplified max PHY rates (Mbps) per spatial stream
    final baseRates = switch (standard) {
      WifiStandard.legacy => widthMhz >= 20 ? 54.0 : 11.0,
      WifiStandard.n => widthMhz == 40 ? 150.0 : 72.2,
      WifiStandard.ac => switch (widthMhz) {
        20 => 86.7,
        40 => 200.0,
        80 => 433.3,
        160 => 866.7,
        _ => 433.3,
      },
      WifiStandard.ax => switch (widthMhz) {
        20 => 143.4,
        40 => 286.8,
        80 => 600.5,
        160 => 1201.0,
        _ => 600.5,
      },
      WifiStandard.be => switch (widthMhz) {
        20 => 160.0,
        40 => 320.0,
        80 => 680.0,
        160 => 1440.0,
        320 => 2880.0,
        _ => 680.0,
      },
      WifiStandard.unknown => 54.0,
    };

    return baseRates * streams;
  }

  List<ChannelOccupancyStat> _buildChannelStats(
    List<WifiObservation> observations,
  ) {
    final grouped = <int, List<WifiObservation>>{};
    for (final network in observations) {
      if (network.channel <= 0) {
        continue;
      }
      grouped.putIfAbsent(network.channel, () => []).add(network);
    }

    final stats = <ChannelOccupancyStat>[];
    for (final entry in grouped.entries) {
      final networks = entry.value;
      final averageSignal =
          networks.map((item) => item.avgSignalDbm).reduce((a, b) => a + b) /
          networks.length;
      final strongestSignal = networks
          .map((item) => item.avgSignalDbm)
          .reduce((a, b) => a > b ? a : b);

      final congestionScore = _computeCongestionScore(
        networkCount: networks.length,
        strongestSignalDbm: strongestSignal,
      );

      stats.add(
        ChannelOccupancyStat(
          channel: entry.key,
          frequency: networks.first.frequency,
          networkCount: networks.length,
          avgSignalDbm: averageSignal.round(),
          congestionScore: congestionScore,
          recommendation: _recommendationForCongestion(congestionScore),
        ),
      );
    }

    stats.sort((a, b) => a.congestionScore.compareTo(b.congestionScore));
    return stats;
  }

  List<BandAnalysisStat> _buildBandStats(
    List<WifiObservation> observations,
    List<ChannelOccupancyStat> channelStats,
  ) {
    final bands = <WifiBand, List<WifiObservation>>{
      WifiBand.ghz24: [],
      WifiBand.ghz5: [],
      WifiBand.ghz6: [],
    };

    for (final network in observations) {
      bands[_frequencyToBand(network.frequency)]?.add(network);
    }

    final stats = <BandAnalysisStat>[];
    for (final entry in bands.entries) {
      final networks = entry.value;
      if (networks.isEmpty) {
        continue;
      }

      final averageSignal =
          networks.map((item) => item.avgSignalDbm).reduce((a, b) => a + b) /
          networks.length;
      final recommendedChannels = _bestChannelsForBand(entry.key, channelStats);

      stats.add(
        BandAnalysisStat(
          band: entry.key,
          networkCount: networks.length,
          avgSignalDbm: averageSignal.round(),
          recommendedChannels: recommendedChannels,
          recommendation:
              recommendedChannels.isEmpty
                  ? 'No channel recommendation available'
                  : 'Use CH ${recommendedChannels.join(', ')}',
        ),
      );
    }

    stats.sort((a, b) => a.band.index.compareTo(b.band.index));
    return stats;
  }

  double _computeCongestionScore({
    required int networkCount,
    required int strongestSignalDbm,
  }) {
    // Lower score is better. Nearby strong networks add more pressure.
    final countWeight = networkCount * 18.0;
    final signalWeight = (100 + strongestSignalDbm).clamp(0, 80).toDouble();
    final value = (countWeight + signalWeight).clamp(0, 100);
    return value.toDouble();
  }

  String _recommendationForCongestion(double congestionScore) {
    if (congestionScore < 30) {
      return 'Excellent';
    }
    if (congestionScore < 60) {
      return 'Fair';
    }
    return 'Congested';
  }

  WifiBand _frequencyToBand(int frequency) {
    if (frequency >= 5925) {
      return WifiBand.ghz6;
    }
    if (frequency >= 5000) {
      return WifiBand.ghz5;
    }
    return WifiBand.ghz24;
  }

  List<int> _bestChannelsForBand(
    WifiBand band,
    List<ChannelOccupancyStat> channelStats,
  ) {
    final candidateChannels = switch (band) {
      WifiBand.ghz24 => const [1, 6, 11],
      WifiBand.ghz5 => const [36, 40, 44, 48, 149, 153, 157, 161],
      WifiBand.ghz6 => const [1, 5, 37, 69, 133, 197],
    };

    final byChannel = <int, ChannelOccupancyStat>{
      for (final stat in channelStats) stat.channel: stat,
    };
    final scored =
        candidateChannels.map((channel) {
            final stat = byChannel[channel];
            return _ChannelScore(
              channel: channel,
              score: stat?.congestionScore ?? 0,
            );
          }).toList()
          ..sort((a, b) => a.score.compareTo(b.score));

    return scored.take(3).map((entry) => entry.channel).toList();
  }
}

class _ObservationAccumulator {
  String ssid;
  final String bssid;
  final List<int> samples = [];
  int channel;
  int frequency;
  SecurityType security;
  bool isHidden;
  int? channelWidthMhz;
  WifiStandard? wifiStandard;
  bool? hasWps;
  bool? hasPmf;
  String? rawCapabilities;
  String? apMldMac;

  _ObservationAccumulator(WifiNetwork network)
    : ssid = network.ssid,
      bssid = network.bssid,
      channel = network.channel,
      frequency = network.frequency,
      security = network.security,
      isHidden = network.isHidden,
      channelWidthMhz = network.channelWidthMhz,
      wifiStandard = network.wifiStandard,
      hasWps = network.hasWps,
      hasPmf = network.hasPmf,
      rawCapabilities = network.rawCapabilities,
      apMldMac = network.apMldMac;

  void addSample(int signalDbm) {
    samples.add(signalDbm);
  }

  void updateFrom(WifiNetwork network) {
    if (ssid.isEmpty && network.ssid.isNotEmpty) {
      ssid = network.ssid;
    }
    if (channel == 0 && network.channel != 0) {
      channel = network.channel;
    }
    if (frequency == 0 && network.frequency != 0) {
      frequency = network.frequency;
    }
    security = network.security;
    isHidden = isHidden || network.isHidden;
    // Keep extended fields from first pass that provided them.
    channelWidthMhz ??= network.channelWidthMhz;
    wifiStandard ??= network.wifiStandard;
    hasWps ??= network.hasWps;
    hasPmf ??= network.hasPmf;
    rawCapabilities ??= network.rawCapabilities;
    apMldMac ??= network.apMldMac;
  }
}

class _ChannelScore {
  final int channel;
  final double score;

  const _ChannelScore({required this.channel, required this.score});
}
