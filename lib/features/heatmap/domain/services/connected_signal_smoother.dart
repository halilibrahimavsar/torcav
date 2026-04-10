import 'dart:math' as math;

import 'package:injectable/injectable.dart';

class SmoothedSignal {
  const SmoothedSignal({
    required this.rssi,
    required this.stdDev,
    required this.sampleCount,
  });

  final int rssi;
  final double stdDev;
  final int sampleCount;
}

@lazySingleton
class ConnectedSignalSmoother {
  const ConnectedSignalSmoother();

  SmoothedSignal? smooth(List<int> samples) {
    if (samples.isEmpty) return null;

    final sorted = [...samples]..sort();
    final median =
        sorted.length.isOdd
            ? sorted[sorted.length ~/ 2].toDouble()
            : (sorted[(sorted.length ~/ 2) - 1] + sorted[sorted.length ~/ 2]) /
                2;
    final average = samples.reduce((a, b) => a + b) / samples.length.toDouble();
    final variance =
        samples
            .map((sample) => math.pow(sample - average, 2).toDouble())
            .fold<double>(0, (a, b) => a + b) /
        samples.length.toDouble();

    return SmoothedSignal(
      rssi: ((median * 0.7) + (average * 0.3)).round(),
      stdDev: math.sqrt(variance),
      sampleCount: samples.length,
    );
  }
}
