import 'package:injectable/injectable.dart';
import '../../../../core/data/database_helper.dart';
import '../../domain/entities/channel_rating_sample.dart';

abstract class ChannelRatingLocalDataSource {
  Future<void> saveRatingSamples(List<ChannelRatingSample> samples);
  Future<List<ChannelRatingSample>> getHistory({Duration? limit});
}

@LazySingleton(as: ChannelRatingLocalDataSource)
class ChannelRatingLocalDataSourceImpl implements ChannelRatingLocalDataSource {
  final DatabaseHelper _dbHelper;

  ChannelRatingLocalDataSourceImpl(this._dbHelper);

  @override
  Future<void> saveRatingSamples(List<ChannelRatingSample> samples) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      for (final sample in samples) {
        await txn.insert('channel_rating_history', sample.toMap());
      }
    });
  }

  @override
  Future<List<ChannelRatingSample>> getHistory({Duration? limit}) async {
    final db = await _dbHelper.database;
    String? where;
    List<dynamic>? whereArgs;

    if (limit != null) {
      final cutoff = DateTime.now().subtract(limit).millisecondsSinceEpoch;
      where = 'timestamp >= ?';
      whereArgs = [cutoff];
    }

    final maps = await db.query(
      'channel_rating_history',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => ChannelRatingSample.fromMap(map)).toList();
  }
}
