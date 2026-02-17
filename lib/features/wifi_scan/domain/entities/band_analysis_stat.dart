import 'package:equatable/equatable.dart';

enum WifiBand { ghz24, ghz5, ghz6 }

class BandAnalysisStat extends Equatable {
  final WifiBand band;
  final int networkCount;
  final int avgSignalDbm;
  final List<int> recommendedChannels;
  final String recommendation;

  const BandAnalysisStat({
    required this.band,
    required this.networkCount,
    required this.avgSignalDbm,
    required this.recommendedChannels,
    required this.recommendation,
  });

  String get label {
    switch (band) {
      case WifiBand.ghz24:
        return '2.4 GHz';
      case WifiBand.ghz5:
        return '5 GHz';
      case WifiBand.ghz6:
        return '6 GHz';
    }
  }

  @override
  List<Object?> get props => [
    band,
    networkCount,
    avgSignalDbm,
    recommendedChannels,
    recommendation,
  ];
}
