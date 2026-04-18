import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/wifi_scan/data/datasources/scan_snapshot_builder.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

void main() {
  group('ScanSnapshotBuilder Hardware Logic', () {
    test('Heuristic spatial streams estimation', () {
      final streams = ScanSnapshotBuilder.estimateSpatialStreams(
        WifiStandard.ax,
      );
      expect(streams, greaterThanOrEqualTo(2));
    });

    test('BSSID randomization detection (LAA bit)', () {
      expect(
        ScanSnapshotBuilder.detectBssidRandomization('02:00:00:00:00:00'),
        isTrue,
      );
      expect(
        ScanSnapshotBuilder.detectBssidRandomization('00:00:00:00:00:11'),
        isFalse,
      );
      expect(
        ScanSnapshotBuilder.detectBssidRandomization('a2:00:00:00:00:00'),
        isTrue,
      );
    });

    test('Throughput estimation logic', () {
      final throughput = ScanSnapshotBuilder.estimateThroughput(
        standard: WifiStandard.ax,
        widthMhz: 80,
        streams: 2,
      );

      expect(throughput, greaterThan(1000)); // ~1201 Mbps

      final throughputN = ScanSnapshotBuilder.estimateThroughput(
        standard: WifiStandard.n,
        widthMhz: 20,
        streams: 1,
      );
      expect(throughputN, lessThan(100)); // ~72.2 Mbps
    });
  });
}
