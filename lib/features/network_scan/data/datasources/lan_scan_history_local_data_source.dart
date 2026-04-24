import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'package:torcav/core/storage/app_database.dart';
import 'package:torcav/features/network_scan/domain/entities/host_scan_result.dart';
import 'package:torcav/features/network_scan/domain/entities/lan_exposure_finding.dart';
import 'package:torcav/features/network_scan/domain/entities/lan_scan_session.dart';
import 'package:torcav/features/network_scan/domain/entities/service_fingerprint.dart';

abstract class LanScanHistoryLocalDataSource {
  Future<void> saveSession({
    required String target,
    required String profile,
    required List<HostScanResult> hosts,
  });
  Future<LanScanSession?> getLatestSession();
  Future<void> deleteAllSessions();
}

@LazySingleton(as: LanScanHistoryLocalDataSource)
class LanScanHistoryLocalDataSourceImpl
    implements LanScanHistoryLocalDataSource {
  LanScanHistoryLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<void> saveSession({
    required String target,
    required String profile,
    required List<HostScanResult> hosts,
  }) async {
    final db = await _database.database;
    final createdAt = DateTime.now();
    final sessionKey = 'lan_${createdAt.microsecondsSinceEpoch}';
    final payload = hosts.map(_hostToJson).toList(growable: false);

    await db.transaction((txn) async {
      await txn.insert('lan_scan_sessions', {
        'session_key': sessionKey,
        'created_at': createdAt.toIso8601String(),
        'target': target,
        'profile': profile,
        'payload_json': jsonEncode(payload),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      final batch = txn.batch();
      for (final host in hosts) {
        for (final finding in host.exposureFindings) {
          batch.insert('lan_exposure_findings', {
            'session_key': sessionKey,
            'host_ip': finding.hostIp,
            'host_mac': finding.hostMac,
            'rule_id': finding.ruleId,
            'summary': finding.summary,
            'risk': finding.risk.name,
            'evidence': finding.evidence,
            'remediation': finding.remediation,
            'service_name': finding.serviceName,
            'port': finding.port,
          });
        }
      }
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<LanScanSession?> getLatestSession() async {
    final db = await _database.database;
    final rows = await db.query(
      'lan_scan_sessions',
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    final hosts =
        (jsonDecode(row['payload_json'] as String? ?? '[]') as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(_hostFromJson)
            .toList();

    return LanScanSession(
      sessionKey: row['session_key'] as String? ?? '',
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      target: row['target'] as String? ?? '',
      profile: row['profile'] as String? ?? '',
      hosts: hosts,
    );
  }

  @override
  Future<void> deleteAllSessions() async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete('lan_exposure_findings');
      await txn.delete('lan_scan_sessions');
    });
  }

  Map<String, dynamic> _hostToJson(HostScanResult host) {
    return {
      'ip': host.ip,
      'mac': host.mac,
      'vendor': host.vendor,
      'hostName': host.hostName,
      'osGuess': host.osGuess,
      'latency': host.latency,
      'services':
          host.services
              .map(
                (service) => {
                  'port': service.port,
                  'protocol': service.protocol,
                  'serviceName': service.serviceName,
                  'product': service.product,
                  'version': service.version,
                },
              )
              .toList(),
      'exposureFindings':
          host.exposureFindings.map((finding) => finding.toJson()).toList(),
      'exposureScore': host.exposureScore,
      'deviceType': host.deviceType,
    };
  }

  HostScanResult _hostFromJson(Map<String, dynamic> json) {
    return HostScanResult(
      ip: json['ip'] as String? ?? '',
      mac: json['mac'] as String? ?? '',
      vendor: json['vendor'] as String? ?? 'Unknown',
      hostName: json['hostName'] as String? ?? '',
      osGuess: json['osGuess'] as String? ?? '',
      latency: (json['latency'] as num? ?? 0).toDouble(),
      services:
          (json['services'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(
                (service) => ServiceFingerprint(
                  port: service['port'] as int? ?? 0,
                  protocol: service['protocol'] as String? ?? 'tcp',
                  serviceName: service['serviceName'] as String? ?? '',
                  product: service['product'] as String? ?? '',
                  version: service['version'] as String? ?? '',
                ),
              )
              .toList(),
      exposureFindings:
          (json['exposureFindings'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(LanExposureFinding.fromJson)
              .toList(),
      exposureScore: (json['exposureScore'] as num? ?? 0).toDouble(),
      deviceType: json['deviceType'] as String? ?? 'Unknown',
    );
  }
}
