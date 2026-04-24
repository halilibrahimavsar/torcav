import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';
import 'package:torcav/features/heatmap/data/datasources/heatmap_local_data_source.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';

class MockHiveStorageService extends Mock implements HiveStorageService {}

void main() {
  late MockHiveStorageService mockStorage;

  setUp(() {
    mockStorage = MockHiveStorageService();
    when(() => mockStorage.save(any(), any())).thenAnswer((_) async {});
  });

  test('round-trips new heatmap point fields', () async {
    final Map<String, dynamic> data = {};
    when(() => mockStorage.save(any(), any())).thenAnswer((invocation) async {
      data[invocation.positionalArguments[0] as String] = invocation.positionalArguments[1];
    });
    when(() => mockStorage.get<List<dynamic>>(any())).thenAnswer((inv) => data[inv.positionalArguments[0]] as List<dynamic>?);
    when(() => mockStorage.get<Map<dynamic, dynamic>>(any())).thenAnswer((inv) => data[inv.positionalArguments[0]] as Map<dynamic, dynamic>?);

    final source = HeatmapLocalDataSource(mockStorage);

    final session = HeatmapSession(
      id: 's1',
      name: 'Living room',
      points: [
        HeatmapPoint(
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
    final Map<String, dynamic> data = {
      'heatmap_session_ids': ['legacy-1'],
      'heatmap_session_legacy-1': {
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
      },
    };

    when(() => mockStorage.get<List<dynamic>>(any())).thenAnswer((inv) => data[inv.positionalArguments[0]] as List<dynamic>?);
    when(() => mockStorage.get<Map<dynamic, dynamic>>(any())).thenAnswer((inv) => data[inv.positionalArguments[0]] as Map<dynamic, dynamic>?);

    final source = HeatmapLocalDataSource(mockStorage);
    final sessions = await source.getSessions();
    final point = sessions.single.points.single;

    expect(point.bssid, isEmpty);
    expect(point.sampleCount, 1);
    expect(point.rssiStdDev, 0);
    expect(point.isFlagged, isFalse);
  });
}

