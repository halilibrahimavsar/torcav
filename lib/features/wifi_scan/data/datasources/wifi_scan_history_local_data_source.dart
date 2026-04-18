import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import 'package:torcav/core/storage/app_database.dart';
import 'package:torcav/features/wifi_scan/domain/entities/band_analysis_stat.dart';
import 'package:torcav/features/wifi_scan/domain/entities/channel_occupancy_stat.dart';
import 'package:torcav/features/wifi_scan/domain/entities/scan_snapshot.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_observation.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_band.dart';

abstract class WifiScanHistoryLocalDataSource {
  Future<void> saveSnapshot(ScanSnapshot snapshot);
  Future<List<ScanSnapshot>> loadSnapshots({int limit = 20});
  Future<void> clear();
}

@LazySingleton(as: WifiScanHistoryLocalDataSource)
class WifiScanHistoryLocalDataSourceImpl
    implements WifiScanHistoryLocalDataSource {
  WifiScanHistoryLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<void> saveSnapshot(ScanSnapshot snapshot) async {
    final db = await _database.database;
    final sessionKey = _sessionKeyFor(snapshot.timestamp);

    await db.transaction((txn) async {
      await txn.insert('scan_sessions', {
        'session_key': sessionKey,
        'created_at': snapshot.timestamp.toIso8601String(),
        'backend_used': snapshot.backendUsed,
        'interface_name': snapshot.interfaceName,
        'channel_stats_json': jsonEncode(
          snapshot.channelStats.map(_channelStatToJson).toList(),
        ),
        'band_stats_json': jsonEncode(
          snapshot.bandStats.map(_bandStatToJson).toList(),
        ),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await txn.delete(
        'wifi_observations',
        where: 'session_key = ?',
        whereArgs: [sessionKey],
      );

      final batch = txn.batch();
      for (final observation in snapshot.networks) {
        batch.insert('wifi_observations', {
          'session_key': sessionKey,
          'ssid': observation.ssid,
          'bssid': observation.bssid,
          'samples_json': jsonEncode(observation.signalDbmSamples),
          'avg_signal_dbm': observation.avgSignalDbm,
          'signal_std_dev': observation.signalStdDev,
          'channel': observation.channel,
          'frequency': observation.frequency,
          'security': observation.security.name,
          'vendor': observation.vendor,
          'is_hidden': observation.isHidden ? 1 : 0,
          'seen_count': observation.seenCount,
          'channel_width_mhz': observation.channelWidthMhz,
          'wifi_standard': observation.wifiStandard?.name,
          'has_wps':
              observation.hasWps == null ? null : (observation.hasWps! ? 1 : 0),
          'has_pmf':
              observation.hasPmf == null ? null : (observation.hasPmf! ? 1 : 0),
          'raw_capabilities': observation.rawCapabilities,
          'ap_mld_mac': observation.apMldMac,
        });
      }
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<List<ScanSnapshot>> loadSnapshots({int limit = 20}) async {
    final db = await _database.database;
    final sessionRows = await db.query(
      'scan_sessions',
      orderBy: 'created_at DESC',
      limit: limit,
    );

    final snapshots = <ScanSnapshot>[];
    for (final session in sessionRows.reversed) {
      final sessionKey = session['session_key'] as String;
      final observationRows = await db.query(
        'wifi_observations',
        where: 'session_key = ?',
        whereArgs: [sessionKey],
      );

      final observations = observationRows
          .map(_observationFromRow)
          .toList(growable: false);
      final channelStats = _decodeChannelStats(
        session['channel_stats_json'] as String? ?? '[]',
      );
      final bandStats = _decodeBandStats(
        session['band_stats_json'] as String? ?? '[]',
      );

      snapshots.add(
        ScanSnapshot(
          timestamp:
              DateTime.tryParse(session['created_at'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
          backendUsed: session['backend_used'] as String? ?? 'unknown',
          interfaceName: session['interface_name'] as String? ?? 'wlan0',
          networks: observations,
          channelStats: channelStats,
          bandStats: bandStats,
        ),
      );
    }

    return snapshots;
  }

  @override
  Future<void> clear() async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete('wifi_observations');
      await txn.delete('scan_sessions');
    });
  }

  String _sessionKeyFor(DateTime timestamp) =>
      'wifi_${timestamp.microsecondsSinceEpoch}';

  WifiObservation _observationFromRow(Map<String, Object?> row) {
    final securityName =
        row['security'] as String? ?? SecurityType.unknown.name;
    final wifiStandardName = row['wifi_standard'] as String?;

    return WifiObservation.fromSamples(
      ssid: row['ssid'] as String? ?? '',
      bssid: row['bssid'] as String? ?? '',
      samples:
          (jsonDecode(row['samples_json'] as String? ?? '[]') as List<dynamic>)
              .map((value) => value as int)
              .toList(),
      channel: row['channel'] as int? ?? 0,
      frequency: row['frequency'] as int? ?? 0,
      security: SecurityType.values.firstWhere(
        (value) => value.name == securityName,
        orElse: () => SecurityType.unknown,
      ),
      vendor: row['vendor'] as String? ?? 'Unknown',
      isHidden: (row['is_hidden'] as int? ?? 0) == 1,
      seenCount: row['seen_count'] as int? ?? 1,
      channelWidthMhz: row['channel_width_mhz'] as int?,
      wifiStandard: WifiStandard.values.firstWhere(
        (value) => value.name == wifiStandardName,
        orElse: () => WifiStandard.unknown,
      ),
      hasWps: _intToBool(row['has_wps'] as int?),
      hasPmf: _intToBool(row['has_pmf'] as int?),
      rawCapabilities: row['raw_capabilities'] as String?,
      apMldMac: row['ap_mld_mac'] as String?,
    );
  }

  bool? _intToBool(int? value) {
    if (value == null) return null;
    return value == 1;
  }

  Map<String, dynamic> _channelStatToJson(ChannelOccupancyStat stat) {
    return {
      'channel': stat.channel,
      'frequency': stat.frequency,
      'networkCount': stat.networkCount,
      'avgSignalDbm': stat.avgSignalDbm,
      'congestionScore': stat.congestionScore,
      'recommendation': stat.recommendation,
    };
  }

  Map<String, dynamic> _bandStatToJson(BandAnalysisStat stat) {
    return {
      'band': stat.band.name,
      'networkCount': stat.networkCount,
      'avgSignalDbm': stat.avgSignalDbm,
      'recommendedChannels': stat.recommendedChannels,
      'recommendation': stat.recommendation,
    };
  }

  List<ChannelOccupancyStat> _decodeChannelStats(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(
          (entry) => ChannelOccupancyStat(
            channel: entry['channel'] as int? ?? 0,
            frequency: entry['frequency'] as int? ?? 0,
            networkCount: entry['networkCount'] as int? ?? 0,
            avgSignalDbm: entry['avgSignalDbm'] as int? ?? 0,
            congestionScore: (entry['congestionScore'] as num? ?? 0).toDouble(),
            recommendation: entry['recommendation'] as String? ?? '',
          ),
        )
        .toList();
  }

  List<BandAnalysisStat> _decodeBandStats(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(
          (entry) => BandAnalysisStat(
            band: WifiBand.values.firstWhere(
              (value) => value.name == entry['band'],
              orElse: () => WifiBand.ghz24,
            ),
            networkCount: entry['networkCount'] as int? ?? 0,
            avgSignalDbm: entry['avgSignalDbm'] as int? ?? 0,
            recommendedChannels:
                (entry['recommendedChannels'] as List<dynamic>? ?? const [])
                    .map((value) => value as int)
                    .toList(),
            recommendation: entry['recommendation'] as String? ?? '',
          ),
        )
        .toList();
  }
}
