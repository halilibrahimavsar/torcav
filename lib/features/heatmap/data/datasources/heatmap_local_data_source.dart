import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/heatmap_point.dart';
import '../../domain/entities/heatmap_session.dart';
import '../models/floor_plan_dto.dart';

/// Persists [HeatmapSession]s as JSON in SharedPreferences.
///
/// This avoids a separate SQLite table while keeping data across restarts.
/// Each session is stored under key `'heatmap_session_<id>'`.  An index list
/// of session IDs is kept under `'heatmap_session_ids'`.
@lazySingleton
class HeatmapLocalDataSource {
  HeatmapLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _indexKey = 'heatmap_session_ids';

  Future<List<HeatmapSession>> getSessions() async {
    final ids = _prefs.getStringList(_indexKey) ?? [];
    final sessions = <HeatmapSession>[];
    for (final id in ids) {
      final raw = _prefs.getString('heatmap_session_$id');
      if (raw == null) continue;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      sessions.add(_fromJson(map));
    }
    sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sessions;
  }

  Future<void> saveSession(HeatmapSession session) async {
    final ids = _prefs.getStringList(_indexKey) ?? [];
    if (!ids.contains(session.id)) {
      ids.add(session.id);
      await _prefs.setStringList(_indexKey, ids);
    }
    await _prefs.setString(
      'heatmap_session_${session.id}',
      jsonEncode(_toJson(session)),
    );
  }

  Future<void> deleteSession(String sessionId) async {
    final ids = _prefs.getStringList(_indexKey) ?? [];
    ids.remove(sessionId);
    await _prefs.setStringList(_indexKey, ids);
    await _prefs.remove('heatmap_session_$sessionId');
  }

  // ── JSON helpers ───────────────────────────────────────────────────────────

  Map<String, dynamic> _toJson(HeatmapSession s) => {
        'id': s.id,
        'name': s.name,
        'createdAt': s.createdAt.toIso8601String(),
        'points': s.points
            .map(
              (p) => {
                'x': p.x,
                'y': p.y,
                'floorX': p.floorX,
                'floorY': p.floorY,
                'floorZ': p.floorZ,
                'heading': p.heading,
                'rssi': p.rssi,
                'timestamp': p.timestamp.toIso8601String(),
                'ssid': p.ssid,
                'floor': p.floor,
              },
            )
            .toList(),
        'floorPlan': s.floorPlan != null
            ? FloorPlanDto.fromEntity(s.floorPlan!).toJson()
            : null,
      };

  HeatmapSession _fromJson(Map<String, dynamic> map) => HeatmapSession(
        id: map['id'] as String,
        name: map['name'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        points: (map['points'] as List<dynamic>)
            .map(
              (e) {
                final rssiNum = e['rssi'] as num;
                return HeatmapPoint(
                  x: (e['x'] as num).toDouble(),
                  y: (e['y'] as num).toDouble(),
                  floorX: (e['floorX'] as num? ?? 0.0).toDouble(),
                  floorY: (e['floorY'] as num? ?? 0.0).toDouble(),
                  floorZ: (e['floorZ'] as num? ?? 0.0).toDouble(),
                  heading: (e['heading'] as num? ?? 0.0).toDouble(),
                  rssi: rssiNum.toInt(),
                  timestamp: DateTime.parse(e['timestamp'] as String),
                  ssid: e['ssid'] as String? ?? '',
                  floor: (e['floor'] as num? ?? 0).toInt(),
                );
              },
            )
            .toList(),
        floorPlan: map['floorPlan'] != null
            ? FloorPlanDto.fromJson(map['floorPlan'] as Map<String, dynamic>)
                .toEntity()
            : null,
      );
}
