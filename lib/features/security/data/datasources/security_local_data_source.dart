import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/app_database.dart';
import '../../domain/entities/assessment_session.dart';
import '../../domain/entities/known_network.dart';
import '../../domain/entities/security_event.dart';
import '../../domain/entities/trusted_network_profile.dart';
import 'dart:convert';

abstract class SecurityLocalDataSource {
  Future<List<KnownNetwork>> getKnownNetworks();
  Future<void> saveKnownNetwork(KnownNetwork network);
  Future<void> deleteKnownNetwork(String bssid);
  Future<List<TrustedNetworkProfile>> getTrustedNetworkProfiles();
  Future<void> saveTrustedNetworkProfile(TrustedNetworkProfile profile);
  Future<void> deleteTrustedNetworkProfile(String bssid);
  Future<List<SecurityEvent>> getSecurityEvents();
  Future<void> saveSecurityEvent(SecurityEvent event);
  Future<void> saveSecurityEvents(List<SecurityEvent> events);
  Future<void> markSecurityEventAsRead(int id);
  Future<void> markAllSecurityEventsAsRead();
  Future<void> deleteSecurityEvent(int id);
  Future<void> clearAllSecurityEvents();
  Future<AssessmentSession?> getLatestAssessmentSession();
  Future<void> saveAssessmentSession(AssessmentSession session);
  Future<void> incrementSeenCount(String bssid);
}

@LazySingleton(as: SecurityLocalDataSource)
class SecurityLocalDataSourceImpl implements SecurityLocalDataSource {
  final AppDatabase _database;

  SecurityLocalDataSourceImpl(this._database);

  @override
  Future<List<KnownNetwork>> getKnownNetworks() async {
    final db = await _database.database;
    final maps = await db.query('known_networks', orderBy: 'last_seen DESC');
    return maps.map(_mapToKnownNetwork).toList();
  }

  KnownNetwork _mapToKnownNetwork(Map<String, dynamic> map) => KnownNetwork(
    ssid: map['ssid'] as String? ?? '',
    bssid: map['bssid'] as String? ?? '',
    security: map['security'] as String? ?? 'unknown',
    firstSeen: DateTime.parse(map['first_seen'] as String),
    lastSeen: DateTime.parse(map['last_seen'] as String),
    seenCount: map['seen_count'] as int? ?? 1,
    gateway: map['gateway'] as String?,
  );

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
  Future<List<TrustedNetworkProfile>> getTrustedNetworkProfiles() async {
    final db = await _database.database;
    final maps = await db.query(
      'trusted_network_profiles',
      orderBy: 'last_confirmed_at DESC',
    );
    return maps.map(_mapToTrustedProfile).toList();
  }

  @override
  Future<void> saveTrustedNetworkProfile(TrustedNetworkProfile profile) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.insert(
        'trusted_network_profiles',
        _trustedProfileToMap(profile),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert('known_networks', {
        'ssid': profile.ssid,
        'bssid': profile.bssid,
        'security': profile.fingerprint.security,
        'gateway': profile.gateway,
        'first_seen': profile.trustedAt.toIso8601String(),
        'last_seen': profile.lastConfirmedAt.toIso8601String(),
        'seen_count': 100, // Trusted profiles are considered highly seen/stable
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  @override
  Future<void> deleteTrustedNetworkProfile(String bssid) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete(
        'trusted_network_profiles',
        where: 'bssid = ?',
        whereArgs: [bssid],
      );
      await txn.delete(
        'known_networks',
        where: 'bssid = ?',
        whereArgs: [bssid],
      );
    });
  }

  @override
  Future<List<SecurityEvent>> getSecurityEvents() async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'security_events',
      orderBy: 'created_at DESC',
    );
    final events = <SecurityEvent>[];
    for (final map in maps) {
      final event = _mapToEvent(map);
      if (event != null) events.add(event);
    }
    return events;
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

  @override
  Future<void> markAllSecurityEventsAsRead() async {
    final db = await _database.database;
    await db.update('security_events', {'is_read': 1});
  }

  @override
  Future<void> deleteSecurityEvent(int id) async {
    final db = await _database.database;
    await db.delete('security_events', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> clearAllSecurityEvents() async {
    final db = await _database.database;
    await db.delete('security_events');
  }

  @override
  Future<AssessmentSession?> getLatestAssessmentSession() async {
    final db = await _database.database;
    final rows = await db.query(
      'assessment_sessions',
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    return AssessmentSession.fromJson({
      'sessionKey': row['session_key'],
      'createdAt': row['created_at'],
      'overallScore': row['overall_score'],
      'overallStatus': row['overall_status'],
      'wifiFindings': jsonDecode(row['wifi_findings_json'] as String? ?? '[]'),
      'lanFindings': jsonDecode(row['lan_findings_json'] as String? ?? '[]'),
      'dnsResult':
          row['dns_result_json'] == null
              ? null
              : jsonDecode(row['dns_result_json'] as String),
      'trustedProfileCount': row['trusted_profile_count'],
    });
  }

  @override
  Future<void> saveAssessmentSession(AssessmentSession session) async {
    final db = await _database.database;
    await db.insert('assessment_sessions', {
      'session_key': session.sessionKey,
      'created_at': session.createdAt.toIso8601String(),
      'overall_score': session.overallScore,
      'overall_status': session.overallStatus.name,
      'wifi_findings_json': jsonEncode(
        session.wifiFindings.map((finding) => finding.toJson()).toList(),
      ),
      'lan_findings_json': jsonEncode(
        session.lanFindings.map((finding) => finding.toJson()).toList(),
      ),
      'dns_result_json':
          session.dnsResult == null
              ? null
              : jsonEncode(session.dnsResult!.toJson()),
      'trusted_profile_count': session.trustedProfileCount,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> incrementSeenCount(String bssid) async {
    final db = await _database.database;
    await db.rawUpdate(
      'UPDATE known_networks SET seen_count = seen_count + 1, last_seen = ? WHERE bssid = ?',
      [DateTime.now().toIso8601String(), bssid],
    );
  }

  Map<String, dynamic> _networkToMap(KnownNetwork network) => {
    'ssid': network.ssid,
    'bssid': network.bssid,
    'security': network.security,
    'first_seen': network.firstSeen.toIso8601String(),
    'last_seen': network.lastSeen.toIso8601String(),
    'seen_count': network.seenCount,
    'gateway': network.gateway,
  };

  Map<String, dynamic> _trustedProfileToMap(TrustedNetworkProfile profile) => {
    'ssid': profile.ssid,
    'bssid': profile.bssid,
    'fingerprint_json': jsonEncode(profile.fingerprint.toJson()),
    'notes': profile.notes,
    'trusted_at': profile.trustedAt.toIso8601String(),
    'last_confirmed_at': profile.lastConfirmedAt.toIso8601String(),
  };

  TrustedNetworkProfile _mapToTrustedProfile(Map<String, dynamic> map) =>
      TrustedNetworkProfile.fromJson({
        'ssid': map['ssid'],
        'bssid': map['bssid'],
        'fingerprint': jsonDecode(map['fingerprint_json'] as String? ?? '{}'),
        'notes': map['notes'],
        'trustedAt': map['trusted_at'],
        'lastConfirmedAt': map['last_confirmed_at'],
      });

  Map<String, dynamic> _eventToMap(SecurityEvent event) => {
    'type': event.type.name,
    'severity': event.severity.name,
    'ssid': event.ssid,
    'bssid': event.bssid,
    'created_at': event.timestamp.toIso8601String(),
    'evidence': event.evidence,
    'is_read': event.isRead ? 1 : 0,
  };

  SecurityEvent? _mapToEvent(Map<String, dynamic> map) {
    try {
      return SecurityEvent(
        id: map['id'] as int?,
        type: SecurityEventType.values.firstWhere(
          (e) => e.name == (map['type'] as String?),
          orElse: () => SecurityEventType.unsupportedOperation,
        ),
        severity: SecurityEventSeverity.values.firstWhere(
          (e) => e.name == (map['severity'] as String?),
          orElse: () => SecurityEventSeverity.info,
        ),
        ssid: (map['ssid'] as String?) ?? '',
        bssid: (map['bssid'] as String?) ?? '',
        timestamp:
            DateTime.tryParse((map['created_at'] as String?) ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        evidence: (map['evidence'] as String?) ?? '',
        isRead: (map['is_read'] as int? ?? 0) == 1,
      );
    } catch (_) {
      return null;
    }
  }
}
