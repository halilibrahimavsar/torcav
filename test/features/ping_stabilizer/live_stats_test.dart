import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/ping_stabilizer/domain/entities/jitter_sample.dart';
import 'package:torcav/features/ping_stabilizer/domain/entities/live_stats.dart';

JitterSample _s(double latency, {double jitter = 0, double loss = 0}) =>
    JitterSample(
      ts: DateTime.now(),
      latencyMs: latency,
      jitterMs: jitter,
      lossPct: loss,
    );

void main() {
  group('LiveStats EWMA', () {
    test('first sample seeds the EWMA', () {
      final s = LiveStats.empty().add(_s(20));
      expect(s.ewmaLatencyMs, closeTo(20, 0.001));
      expect(s.ewmaJitterMs, closeTo(0, 0.001));
    });

    test('subsequent samples weight recent values more heavily', () {
      var s = LiveStats.empty().add(_s(20));
      s = s.add(_s(60));
      // alpha=0.25 → 0.25*60 + 0.75*20 = 30
      expect(s.ewmaLatencyMs, closeTo(30, 0.001));
    });

    test('rolling window caps at LiveStats.windowSize', () {
      var s = LiveStats.empty();
      for (var i = 0; i < LiveStats.windowSize + 20; i++) {
        s = s.add(_s(i.toDouble()));
      }
      expect(s.samples.length, LiveStats.windowSize);
    });
  });

  group('jitterBreached', () {
    test('returns false if not enough samples', () {
      final s = LiveStats.empty().add(_s(0, jitter: 100));
      expect(s.jitterBreached(50, 3), isFalse);
    });

    test('triggers when N consecutive samples exceed threshold', () {
      var s = LiveStats.empty();
      s = s.add(_s(0, jitter: 5));
      s = s.add(_s(0, jitter: 60));
      s = s.add(_s(0, jitter: 70));
      s = s.add(_s(0, jitter: 80));
      expect(s.jitterBreached(50, 3), isTrue);
    });

    test('does not trigger if a recent sample dipped below threshold', () {
      var s = LiveStats.empty();
      s = s.add(_s(0, jitter: 60));
      s = s.add(_s(0, jitter: 10));
      s = s.add(_s(0, jitter: 80));
      expect(s.jitterBreached(50, 3), isFalse);
    });
  });
}
