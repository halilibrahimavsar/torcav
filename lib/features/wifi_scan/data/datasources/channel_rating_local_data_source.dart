import 'package:injectable/injectable.dart';
import '../../../../core/storage/app_database.dart';
import '../../domain/entities/channel_rating_sample.dart';

abstract class ChannelRatingLocalDataSource {
  Future<void> saveRatingSamples(List<ChannelRatingSample> samples);
  Future<List<ChannelRatingSample>> getHistory({Duration? limit});
}

@LazySingleton(as: ChannelRatingLocalDataSource)
class ChannelRatingLocalDataSourceImpl implements ChannelRatingLocalDataSource {
  final AppDatabase _appDatabase;

  ChannelRatingLocalDataSourceImpl(this._appDatabase);

  @override
  Future<void> saveRatingSamples(List<ChannelRatingSample> samples) async {
    final db = await _appDatabase.database;
    await db.transaction((txn) async {
      for (final sample in samples) {
        await txn.insert('channel_rating_history', {
          if (sample.id != null) 'id': sample.id,
          'channel': sample.channel,
          'rating': sample.rating,
          'timestamp': sample.timestamp.toIso8601String(),
        });
      }
    });
  }

  @override
  Future<List<ChannelRatingSample>> getHistory({Duration? limit}) async {
    final db = await _appDatabase.database;
    String? where;
    List<dynamic>? whereArgs;

    if (limit != null) {
      final cutoff = DateTime.now().subtract(limit).toIso8601String();
      where = 'timestamp >= ?';
      whereArgs = [cutoff];
    }

    final maps = await db.query(
      'channel_rating_history',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) {
      return ChannelRatingSample(
        id: map['id'] as int?,
        channel: map['channel'] as int,
        rating: map['rating'] as double,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
    }).toList();
  }
}
