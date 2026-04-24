import 'package:injectable/injectable.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';

import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';

/// Persists [HeatmapSession]s in Hive.
///
/// Each session is stored under key `'heatmap_session_<id>'`. An index list
/// of session IDs is kept under `'heatmap_session_ids'`.
@lazySingleton
class HeatmapLocalDataSource {
  HeatmapLocalDataSource(this._storage);

  final HiveStorageService _storage;

  static const _indexKey = 'heatmap_session_ids';

  Future<List<HeatmapSession>> getSessions() async {
    final ids = _storage.get<List<dynamic>>(_indexKey) ?? [];
    final sessions = <HeatmapSession>[];
    for (final id in ids) {
      final map = _storage.get<Map<dynamic, dynamic>>('heatmap_session_$id');
      if (map == null) continue;
      sessions.add(_fromJson(map.cast<String, dynamic>()));
    }
    sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sessions;
  }

  Future<void> saveSession(HeatmapSession session) async {
    final ids = (_storage.get<List<dynamic>>(_indexKey) ?? []).cast<String>().toList();
    if (!ids.contains(session.id)) {
      ids.add(session.id);
      await _storage.save(_indexKey, ids);
    }
    await _storage.save(
      'heatmap_session_${session.id}',
      _toJson(session),
    );
  }

  Future<void> deleteSession(String sessionId) async {
    final ids = (_storage.get<List<dynamic>>(_indexKey) ?? []).cast<String>().toList();
    ids.remove(sessionId);
    await _storage.save(_indexKey, ids);
    await _storage.delete('heatmap_session_$sessionId');
  }

  Future<void> deleteAll() async {
    final ids = (_storage.get<List<dynamic>>(_indexKey) ?? []).cast<String>().toList();
    for (final id in ids) {
      await _storage.delete('heatmap_session_$id');
    }
    await _storage.delete(_indexKey);
  }

  // ── JSON helpers ───────────────────────────────────────────────────────────

  Map<String, dynamic> _toJson(HeatmapSession s) => {
    'id': s.id,
    'name': s.name,
    'createdAt': s.createdAt.toIso8601String(),
    'points':
        s.points
            .map(
              (p) => {
                'floorX': p.floorX,
                'floorY': p.floorY,
                'floorZ': p.floorZ,
                'heading': p.heading,
                'rssi': p.rssi,
                'timestamp': p.timestamp.toIso8601String(),
                'ssid': p.ssid,
                'bssid': p.bssid,
                'floor': p.floor,
                'sampleCount': p.sampleCount,
                'rssiStdDev': p.rssiStdDev,
                'isFlagged': p.isFlagged,
              },
            )
            .toList(),
  };

  HeatmapSession _fromJson(Map<String, dynamic> map) => HeatmapSession(
    id: map['id'] as String,
    name: map['name'] as String,
    createdAt: DateTime.parse(map['createdAt'] as String),
    points:
        (map['points'] as List<dynamic>).map((e) {
          final pointMap = e as Map<dynamic, dynamic>;
          final rssiNum = pointMap['rssi'] as num;
          return HeatmapPoint(
            floorX: (pointMap['floorX'] as num? ?? 0.0).toDouble(),
            floorY: (pointMap['floorY'] as num? ?? 0.0).toDouble(),
            floorZ: (pointMap['floorZ'] as num? ?? 0.0).toDouble(),
            heading: (pointMap['heading'] as num? ?? 0.0).toDouble(),
            rssi: rssiNum.toInt(),
            timestamp: DateTime.parse(pointMap['timestamp'] as String),
            ssid: pointMap['ssid'] as String? ?? '',
            bssid: pointMap['bssid'] as String? ?? '',
            floor: (pointMap['floor'] as num? ?? 0).toInt(),
            sampleCount: (pointMap['sampleCount'] as num? ?? 1).toInt(),
            rssiStdDev: (pointMap['rssiStdDev'] as num? ?? 0.0).toDouble(),
            isFlagged: pointMap['isFlagged'] as bool? ?? false,
          );
        }).toList(),
  );
}

