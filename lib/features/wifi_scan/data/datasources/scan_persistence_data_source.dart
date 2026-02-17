import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/storage/app_database.dart';
import '../../domain/entities/scan_snapshot.dart';

@lazySingleton
class ScanPersistenceDataSource {
  final AppDatabase _appDatabase;

  ScanPersistenceDataSource(this._appDatabase);

  Future<int> saveSnapshot(ScanSnapshot snapshot) async {
    final db = await _appDatabase.database;

    return db.transaction((txn) async {
      final sessionId = await txn.insert('scan_sessions', {
        'created_at': snapshot.timestamp.toIso8601String(),
        'backend_used': snapshot.backendUsed,
        'interface_name': snapshot.interfaceName,
      });

      for (final observation in snapshot.networks) {
        final observationId = await txn.insert('wifi_observations', {
          'session_id': sessionId,
          'ssid': observation.ssid,
          'bssid': observation.bssid,
          'avg_signal_dbm': observation.avgSignalDbm,
          'stddev': observation.signalStdDev,
          'channel': observation.channel,
          'frequency': observation.frequency,
          'security': observation.security.name,
          'vendor': observation.vendor,
          'is_hidden': observation.isHidden ? 1 : 0,
          'seen_count': observation.seenCount,
        });

        for (var i = 0; i < observation.signalDbmSamples.length; i++) {
          await txn.insert('wifi_signal_samples', {
            'observation_id': observationId,
            'sample_index': i,
            'signal_dbm': observation.signalDbmSamples[i],
          });
        }
      }

      for (final channel in snapshot.channelStats) {
        await txn.insert('channel_metrics', {
          'session_id': sessionId,
          'channel': channel.channel,
          'frequency': channel.frequency,
          'network_count': channel.networkCount,
          'avg_signal_dbm': channel.avgSignalDbm,
          'congestion_score': channel.congestionScore,
          'recommendation': channel.recommendation,
        });
      }

      for (final band in snapshot.bandStats) {
        await txn.insert('band_metrics', {
          'session_id': sessionId,
          'band': band.label,
          'network_count': band.networkCount,
          'avg_signal_dbm': band.avgSignalDbm,
          'recommendation': band.recommendation,
          'recommended_channels': jsonEncode(band.recommendedChannels),
        });
      }

      return sessionId;
    });
  }
}
