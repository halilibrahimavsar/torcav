import 'package:injectable/injectable.dart';

import '../../../../core/storage/app_database.dart';
import '../../domain/entities/speed_test_result.dart';
import '../../domain/repositories/speed_test_history_repository.dart';

@LazySingleton(as: SpeedTestHistoryRepository)
class SpeedTestHistoryRepositoryImpl implements SpeedTestHistoryRepository {
  final AppDatabase _db;
  SpeedTestHistoryRepositoryImpl(this._db);

  static const _table = 'speed_test_results';

  @override
  Future<void> save(SpeedTestResult result) async {
    final db = await _db.database;
    await db.insert(_table, {
      'recorded_at': result.recordedAt.toIso8601String(),
      'latency_ms': result.latencyMs,
      'jitter_ms': result.jitterMs,
      'download_mbps': result.downloadMbps,
      'upload_mbps': result.uploadMbps,
      'packet_loss': result.packetLoss,
      'loaded_latency_ms': result.loadedLatencyMs,
    });
  }

  @override
  Future<List<SpeedTestResult>> getRecent({int limit = 20}) async {
    final db = await _db.database;
    final rows = await db.query(
      _table,
      orderBy: 'recorded_at DESC',
      limit: limit,
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> deleteById(int id) async {
    final db = await _db.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteAll() async {
    final db = await _db.database;
    await db.delete(_table);
  }

  SpeedTestResult _fromRow(Map<String, dynamic> row) => SpeedTestResult(
    id: row['id'] as int?,
    recordedAt: DateTime.parse(row['recorded_at'] as String),
    latencyMs: (row['latency_ms'] as num).toDouble(),
    jitterMs: (row['jitter_ms'] as num).toDouble(),
    downloadMbps: (row['download_mbps'] as num).toDouble(),
    uploadMbps: (row['upload_mbps'] as num).toDouble(),
    packetLoss: (row['packet_loss'] as num?)?.toDouble() ?? 0.0,
    loadedLatencyMs: (row['loaded_latency_ms'] as num?)?.toDouble() ?? 0.0,
  );
}
