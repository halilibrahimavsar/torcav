import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/data/database_helper.dart';
import '../../domain/entities/known_network.dart';
import '../../domain/entities/security_event.dart';

abstract class SecurityLocalDataSource {
  Future<List<KnownNetwork>> getKnownNetworks();
  Future<void> saveKnownNetwork(KnownNetwork network);
  Future<List<SecurityEvent>> getSecurityEvents();
  Future<void> saveSecurityEvent(SecurityEvent event);
  Future<void> saveSecurityEvents(List<SecurityEvent> events);
}

@LazySingleton(as: SecurityLocalDataSource)
class SecurityLocalDataSourceImpl implements SecurityLocalDataSource {
  final DatabaseHelper _dbHelper;

  SecurityLocalDataSourceImpl(this._dbHelper);

  @override
  Future<List<KnownNetwork>> getKnownNetworks() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('known_networks');

    return List.generate(maps.length, (i) {
      return KnownNetwork(
        ssid: maps[i]['ssid'] as String,
        bssid: maps[i]['bssid'] as String,
        security: maps[i]['security'] as String,
        firstSeen: DateTime.fromMillisecondsSinceEpoch(
          maps[i]['first_seen'] as int,
        ),
        lastSeen: DateTime.fromMillisecondsSinceEpoch(
          maps[i]['last_seen'] as int,
        ),
      );
    });
  }

  @override
  Future<void> saveKnownNetwork(KnownNetwork network) async {
    final db = await _dbHelper.database;
    await db.insert('known_networks', {
      'ssid': network.ssid,
      'bssid': network.bssid,
      'security': network.security,
      'first_seen': network.firstSeen.millisecondsSinceEpoch,
      'last_seen': network.lastSeen.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<SecurityEvent>> getSecurityEvents() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'security_alerts',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return SecurityEvent(
        type: SecurityEventType.values.firstWhere(
          (e) => e.toString() == maps[i]['type'],
          orElse: () => SecurityEventType.rogueApSuspected,
        ),
        severity: SecurityEventSeverity.values.firstWhere(
          (e) => e.toString() == maps[i]['severity'],
          orElse: () => SecurityEventSeverity.warning,
        ),
        ssid:
            maps[i]['message']
                .split(' SSID: ')[1]
                .split(',')[0], // Simple parsing for demo
        bssid:
            maps[i]['message'].split(' BSSID: ')[1], // Simple parsing for demo
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          maps[i]['timestamp'] as int,
        ),
        evidence: maps[i]['message'] as String,
      );
    });
  }

  @override
  Future<void> saveSecurityEvent(SecurityEvent event) =>
      saveSecurityEvents([event]);

  @override
  Future<void> saveSecurityEvents(List<SecurityEvent> events) async {
    if (events.isEmpty) return;
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final event in events) {
        batch.insert('security_alerts', {
          'type': event.type.toString(),
          'message':
              'Alert: ${event.type.name} SSID: ${event.ssid}, BSSID: ${event.bssid}',
          'timestamp': event.timestamp.millisecondsSinceEpoch,
          'severity': event.severity.toString(),
        });
      }
      await batch.commit(noResult: true);
    });
  }
}
