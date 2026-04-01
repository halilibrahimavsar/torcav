import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/app_database.dart';
import '../../domain/entities/known_network.dart';
import '../../domain/entities/security_event.dart';

abstract class SecurityLocalDataSource {
  Future<List<KnownNetwork>> getKnownNetworks();
  Future<void> saveKnownNetwork(KnownNetwork network);
  Future<void> deleteKnownNetwork(String bssid);
  Future<List<SecurityEvent>> getSecurityEvents();
  Future<void> saveSecurityEvent(SecurityEvent event);
  Future<void> saveSecurityEvents(List<SecurityEvent> events);
  Future<void> markSecurityEventAsRead(int id);
}

@LazySingleton(as: SecurityLocalDataSource)
class SecurityLocalDataSourceImpl implements SecurityLocalDataSource {
  final AppDatabase _database;

  SecurityLocalDataSourceImpl(this._database);

  @override
  Future<List<KnownNetwork>> getKnownNetworks() async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query('known_networks');
    return List.generate(maps.length, (i) => _mapToNetwork(maps[i]));
  }

  @override
  Future<void> saveKnownNetwork(KnownNetwork network) async {
    final db = await _database.database;
    await db.insert(
      'known_networks',
      _networkToMap(network),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteKnownNetwork(String bssid) async {
    final db = await _database.database;
    await db.delete('known_networks', where: 'bssid = ?', whereArgs: [bssid]);
  }

  @override
  Future<List<SecurityEvent>> getSecurityEvents() async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'security_events',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => _mapToEvent(maps[i]));
  }

  @override
  Future<void> saveSecurityEvent(SecurityEvent event) async {
    final db = await _database.database;
    await db.insert('security_events', _eventToMap(event));
  }

  @override
  Future<void> saveSecurityEvents(List<SecurityEvent> events) async {
    final db = await _database.database;
    final batch = db.batch();
    for (final event in events) {
      batch.insert('security_events', _eventToMap(event));
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> markSecurityEventAsRead(int id) async {
    final db = await _database.database;
    await db.update(
      'security_events',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _networkToMap(KnownNetwork network) => {
    'ssid': network.ssid,
    'bssid': network.bssid,
    'security': network.security,
    'first_seen': network.firstSeen.toIso8601String(),
    'last_seen': network.lastSeen.toIso8601String(),
  };

  KnownNetwork _mapToNetwork(Map<String, dynamic> map) => KnownNetwork(
    ssid: map['ssid'] as String,
    bssid: map['bssid'] as String,
    security: map['security'] as String,
    firstSeen: DateTime.parse(map['first_seen'] as String),
    lastSeen: DateTime.parse(map['last_seen'] as String),
  );

  Map<String, dynamic> _eventToMap(SecurityEvent event) => {
    'type': event.type.toString(),
    'severity': event.severity.toString(),
    'ssid': event.ssid,
    'bssid': event.bssid,
    'created_at': event.timestamp.toIso8601String(),
    'evidence': event.evidence,
    'is_read': event.isRead ? 1 : 0,
  };

  SecurityEvent _mapToEvent(Map<String, dynamic> map) => SecurityEvent(
    id: map['id'] as int,
    type: SecurityEventType.values.firstWhere(
      (e) => e.toString() == (map['type'] as String),
    ),
    severity: SecurityEventSeverity.values.firstWhere(
      (e) => e.toString() == (map['severity'] as String),
    ),
    ssid: map['ssid'] as String,
    bssid: map['bssid'] as String,
    timestamp: DateTime.parse(map['created_at'] as String),
    evidence: map['evidence'] as String,
    isRead: (map['is_read'] as int) == 1,
  );
}
