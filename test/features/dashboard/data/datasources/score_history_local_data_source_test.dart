import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:torcav/core/storage/app_database.dart';
import 'package:torcav/features/dashboard/data/datasources/score_history_local_data_source.dart';

class _MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late Database db;
  late _MockAppDatabase mockAppDb;
  late ScoreHistoryLocalDataSourceImpl dataSource;

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
            CREATE TABLE security_score_history (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              score INTEGER NOT NULL,
              recorded_at INTEGER NOT NULL
            )
          ''');
        },
      ),
    );
    mockAppDb = _MockAppDatabase();
    when(() => mockAppDb.database).thenAnswer((_) async => db);
    dataSource = ScoreHistoryLocalDataSourceImpl(mockAppDb);
  });

  tearDown(() async {
    await db.close();
  });

  group('ScoreHistoryLocalDataSourceImpl', () {
    test('saveScore inserts a row with score and timestamp', () async {
      final before = DateTime.now().millisecondsSinceEpoch;
      await dataSource.saveScore(85);
      final after = DateTime.now().millisecondsSinceEpoch;

      final rows = await db.query('security_score_history');
      expect(rows, hasLength(1));
      expect(rows.first['score'], 85);
      final recordedAt = rows.first['recorded_at'] as int;
      expect(recordedAt, greaterThanOrEqualTo(before));
      expect(recordedAt, lessThanOrEqualTo(after));
    });

    test(
      'getRecentScores returns rows in ascending recorded_at order (impl reverses DESC query)',
      () async {
        await db.insert('security_score_history', {
          'score': 60,
          'recorded_at': 1000,
        });
        await db.insert('security_score_history', {
          'score': 70,
          'recorded_at': 2000,
        });
        await db.insert('security_score_history', {
          'score': 80,
          'recorded_at': 3000,
        });

        final result = await dataSource.getRecentScores();

        expect(result.map((r) => r.score).toList(), [60, 70, 80]);
        expect(
          result.map((r) => r.at.millisecondsSinceEpoch).toList(),
          [1000, 2000, 3000],
        );
      },
    );

    test('getRecentScores honors the limit parameter', () async {
      for (var i = 0; i < 5; i++) {
        await db.insert('security_score_history', {
          'score': 50 + i,
          'recorded_at': 1000 + i,
        });
      }

      final result = await dataSource.getRecentScores(limit: 3);

      // Most recent 3, then reversed to ascending: 52, 53, 54.
      expect(result.map((r) => r.score).toList(), [52, 53, 54]);
    });

    test('deleteAll empties the table', () async {
      await dataSource.saveScore(70);
      await dataSource.saveScore(80);
      expect(await db.query('security_score_history'), hasLength(2));

      await dataSource.deleteAll();

      expect(await db.query('security_score_history'), isEmpty);
    });

    test(
      'round-trip: saving 12 rows then fetching default limit returns 10 most recent ascending',
      () async {
        for (var i = 0; i < 12; i++) {
          await db.insert('security_score_history', {
            'score': i,
            'recorded_at': i,
          });
        }

        final result = await dataSource.getRecentScores();

        expect(result, hasLength(10));
        expect(result.first.score, 2);
        expect(result.last.score, 11);
      },
    );
  });
}
