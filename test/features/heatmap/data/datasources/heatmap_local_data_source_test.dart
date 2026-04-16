import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torcav/features/heatmap/data/datasources/heatmap_local_data_source.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('round-trips new heatmap point fields', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final source = HeatmapLocalDataSource(prefs);

    final session = HeatmapSession(
      id: 's1',
      name: 'Living room',
      points: [
        HeatmapPoint(
          x: 0,
          y: 0,
          floorX: 1.2,
          floorY: 2.4,
          floorZ: 0,
          heading: 90,
          rssi: -61,
          timestamp: DateTime(2026, 4, 10, 12),
          ssid: 'HomeNet',
          bssid: 'AA:BB:CC:DD:EE:FF',
          sampleCount: 5,
          rssiStdDev: 2.2,
          isFlagged: true,
        ),
      ],
      createdAt: DateTime(2026, 4, 10, 12),
    );

    await source.saveSession(session);
    final sessions = await source.getSessions();

    expect(sessions.single.points.single.bssid, 'AA:BB:CC:DD:EE:FF');
    expect(sessions.single.points.single.sampleCount, 5);
    expect(sessions.single.points.single.rssiStdDev, 2.2);
    expect(sessions.single.points.single.isFlagged, isTrue);
  });

  test('loads legacy session payloads with defaults for new fields', () async {
    SharedPreferences.setMockInitialValues({
      'heatmap_session_ids': ['legacy-1'],
      'heatmap_session_legacy-1': jsonEncode({
        'id': 'legacy-1',
        'name': 'Legacy',
        'createdAt': DateTime(2026, 4, 10, 12).toIso8601String(),
        'points': [
          {
            'x': 0,
            'y': 0,
            'floorX': 0,
            'floorY': 0,
            'rssi': -70,
            'timestamp': DateTime(2026, 4, 10, 12).toIso8601String(),
            'ssid': 'LegacyNet',
            'floor': 0,
          },
        ],
      }),
    });

    final prefs = await SharedPreferences.getInstance();
    final source = HeatmapLocalDataSource(prefs);
    final sessions = await source.getSessions();
    final point = sessions.single.points.single;

    expect(point.bssid, isEmpty);
    expect(point.sampleCount, 1);
    expect(point.rssiStdDev, 0);
    expect(point.isFlagged, isFalse);
  });
}
