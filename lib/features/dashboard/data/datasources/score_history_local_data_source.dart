import 'package:injectable/injectable.dart';
import '../../../../core/storage/app_database.dart';

abstract class ScoreHistoryLocalDataSource {
  Future<void> saveScore(int score);
  Future<List<({int score, DateTime at})>> getRecentScores({int limit = 10});
}

@LazySingleton(as: ScoreHistoryLocalDataSource)
class ScoreHistoryLocalDataSourceImpl implements ScoreHistoryLocalDataSource {
  final AppDatabase _database;

  ScoreHistoryLocalDataSourceImpl(this._database);

  @override
  Future<void> saveScore(int score) async {
    final db = await _database.database;
    await db.insert('security_score_history', {
      'score': score,
      'recorded_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<List<({int score, DateTime at})>> getRecentScores({
    int limit = 10,
  }) async {
    final db = await _database.database;
    final rows = await db.query(
      'security_score_history',
      orderBy: 'recorded_at DESC',
      limit: limit,
    );
    return rows.reversed
        .map(
          (r) => (
            score: r['score'] as int,
            at: DateTime.fromMillisecondsSinceEpoch(r['recorded_at'] as int),
          ),
        )
        .toList();
  }
}
