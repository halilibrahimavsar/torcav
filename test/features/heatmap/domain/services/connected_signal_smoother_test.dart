import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/heatmap/domain/services/connected_signal_smoother.dart';

void main() {
  const smoother = ConnectedSignalSmoother();

  test('stabilizes a noisy 5-sample RSSI window', () {
    final result = smoother.smooth(const [-58, -57, -61, -59, -80]);

    expect(result, isNotNull);
    expect(result!.rssi, inInclusiveRange(-62, -58));
    expect(result.sampleCount, 5);
    expect(result.stdDev, greaterThan(0));
  });

  test('returns null for an empty window', () {
    expect(smoother.smooth(const []), isNull);
  });
}
