import 'package:injectable/injectable.dart';
import '../../../../core/storage/app_database.dart';
import '../../domain/entities/heatmap_point.dart';
import '../../domain/repositories/heatmap_repository.dart';

@LazySingleton(as: HeatmapRepository)
class HeatmapRepositoryImpl implements HeatmapRepository {
  final AppDatabase _appDatabase;

  HeatmapRepositoryImpl(this._appDatabase);

  @override
  Future<void> addPoint(HeatmapPoint point) async {
    final db = await _appDatabase.database;
    await db.insert('heatmap_points', {
      'created_at': point.timestamp.toIso8601String(),
      'bssid': point.bssid,
      'zone_tag': point.zoneTag,
      'signal_dbm': point.signalDbm,
    });
  }

  @override
  Future<List<HeatmapPoint>> getPointsFor(String bssid) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'heatmap_points',
      where: 'bssid = ?',
      whereArgs: [bssid],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) {
      return HeatmapPoint(
        timestamp: DateTime.parse(map['created_at'] as String),
        bssid: map['bssid'] as String,
        zoneTag: map['zone_tag'] as String,
        signalDbm: map['signal_dbm'] as int,
      );
    }).toList(growable: false);
  }
}
