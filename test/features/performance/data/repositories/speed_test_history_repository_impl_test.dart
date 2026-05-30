import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:torcav/core/storage/app_database.dart';
import 'package:torcav/features/performance/data/repositories/speed_test_history_repository_impl.dart';
import 'package:torcav/features/performance/domain/entities/speed_test_result.dart';

class _MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late Database db;
  late _MockAppDatabase mockAppDb;
  late SpeedTestHistoryRepositoryImpl repo;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE speed_test_results (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              recorded_at TEXT NOT NULL,
              latency_ms REAL NOT NULL,
              jitter_ms REAL NOT NULL,
              download_mbps REAL NOT NULL,
              upload_mbps REAL NOT NULL,
              packet_loss REAL NOT NULL DEFAULT 0,
              loaded_latency_ms REAL NOT NULL DEFAULT 0
            )
          ''');
        },
      ),
    );
    mockAppDb = _MockAppDatabase();
    when(() => mockAppDb.database).thenAnswer((_) async => db);
    repo = SpeedTestHistoryRepositoryImpl(mockAppDb);
  });

  tearDown(() async {
    await db.close();
  });

  SpeedTestResult sample({
    DateTime? at,
    double latency = 12,
    double jitter = 1,
    double dl = 150,
    double ul = 30,
    double loss = 0,
    double loadedLatency = 14,
  }) =>
      SpeedTestResult(
        recordedAt: at ?? DateTime(2026, 5, 25, 12),
        latencyMs: latency,
        jitterMs: jitter,
        downloadMbps: dl,
        uploadMbps: ul,
        packetLoss: loss,
        loadedLatencyMs: loadedLatency,
      );

  group('SpeedTestHistoryRepositoryImpl', () {
    test('save inserts a row with all fields', () async {
      await repo.save(sample(
        at: DateTime.utc(2026, 1, 2, 3, 4, 5),
        latency: 20,
        jitter: 3,
        dl: 250,
        ul: 50,
        loss: 1.5,
        loadedLatency: 35,
      ),);

      final rows = await db.query('speed_test_results');
      expect(rows, hasLength(1));
      expect(rows.first['recorded_at'], '2026-01-02T03:04:05.000Z');
      expect(rows.first['latency_ms'], 20);
      expect(rows.first['jitter_ms'], 3);
      expect(rows.first['download_mbps'], 250);
      expect(rows.first['upload_mbps'], 50);
      expect(rows.first['packet_loss'], 1.5);
      expect(rows.first['loaded_latency_ms'], 35);
    });

    test('getRecent returns rows ordered by recorded_at descending', () async {
      await repo.save(sample(at: DateTime(2026), dl: 100));
      await repo.save(sample(at: DateTime(2026, 1, 3), dl: 300));
      await repo.save(sample(at: DateTime(2026, 1, 2), dl: 200));

      final result = await repo.getRecent();

      expect(result.map((r) => r.downloadMbps).toList(), [300, 200, 100]);
    });

    test('getRecent honors the limit parameter', () async {
      for (var i = 0; i < 5; i++) {
        await repo.save(sample(at: DateTime(2026, 1, 1 + i), dl: 100.0 + i));
      }

      final result = await repo.getRecent(limit: 2);

      expect(result, hasLength(2));
      expect(result.first.downloadMbps, 104);
      expect(result.last.downloadMbps, 103);
    });

    test('getRecent default limit is 20', () async {
      for (var i = 0; i < 25; i++) {
        await repo.save(sample(at: DateTime(2026).add(Duration(days: i))));
      }

      final result = await repo.getRecent();

      expect(result, hasLength(20));
    });

    test('deleteById removes only the matching row', () async {
      await repo.save(sample(dl: 100));
      await repo.save(sample(dl: 200));

      final rows = await db.query('speed_test_results');
      final firstId = rows.first['id'] as int;

      await repo.deleteById(firstId);

      final remaining = await db.query('speed_test_results');
      expect(remaining, hasLength(1));
      expect(remaining.first['download_mbps'], 200);
    });

    test('deleteAll empties the table', () async {
      await repo.save(sample());
      await repo.save(sample());

      await repo.deleteAll();

      expect(await db.query('speed_test_results'), isEmpty);
    });

    test('row → entity preserves id and all numeric fields', () async {
      await repo.save(sample(latency: 11, dl: 222.5, loss: 2.5));

      final result = await repo.getRecent();
      expect(result, hasLength(1));
      final r = result.first;
      expect(r.id, isNotNull);
      expect(r.latencyMs, 11);
      expect(r.downloadMbps, 222.5);
      expect(r.packetLoss, 2.5);
    });
  });
}
