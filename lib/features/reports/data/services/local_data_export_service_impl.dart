import 'dart:convert';

import 'package:injectable/injectable.dart';

import 'package:torcav/core/storage/hive_storage_service.dart';
import 'package:torcav/features/ai/data/stores/device_label_override_store.dart';
import 'package:torcav/features/dashboard/data/datasources/score_history_local_data_source.dart';
import 'package:torcav/features/heatmap/data/datasources/heatmap_local_data_source.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/network_scan/domain/repositories/lan_scan_history_repository.dart';
import 'package:torcav/features/network_scan/domain/entities/host_scan_result.dart';
import 'package:torcav/features/network_scan/domain/entities/lan_exposure_finding.dart';
import 'package:torcav/features/network_scan/domain/entities/lan_scan_session.dart';
import 'package:torcav/features/performance/domain/repositories/speed_test_history_repository.dart';
import 'package:torcav/features/security/data/datasources/security_local_data_source.dart';
import 'package:torcav/features/security/domain/entities/security_event.dart';
import 'package:torcav/features/security/domain/entities/trusted_network_profile.dart';
import 'package:torcav/features/wifi_scan/data/datasources/channel_rating_local_data_source.dart';
import 'package:torcav/features/wifi_scan/data/datasources/wifi_scan_history_local_data_source.dart';
import 'package:torcav/features/wifi_scan/data/services/favorites_store.dart';
import 'package:torcav/features/wifi_scan/domain/entities/scan_snapshot.dart';

import '../../domain/entities/user_data_category.dart';
import '../../domain/services/local_data_export_service.dart';

@LazySingleton(as: LocalDataExportService)
class LocalDataExportServiceImpl implements LocalDataExportService {
  LocalDataExportServiceImpl(
    this._wifiHistory,
    this._speedTestHistory,
    this._security,
    this._channelRatings,
    this._heatmap,
    this._lanHistory,
    this._scoreHistory,
    this._deviceLabels,
    this._favorites,
    this._hive,
  );

  final WifiScanHistoryLocalDataSource _wifiHistory;
  final SpeedTestHistoryRepository _speedTestHistory;
  final SecurityLocalDataSource _security;
  final ChannelRatingLocalDataSource _channelRatings;
  final HeatmapLocalDataSource _heatmap;
  final LanScanHistoryRepository _lanHistory;
  final ScoreHistoryLocalDataSource _scoreHistory;
  final DeviceLabelOverrideStore _deviceLabels;
  final FavoritesStore _favorites;
  final HiveStorageService _hive;

  static const _jsonEncoder = JsonEncoder.withIndent('  ');

  // Hive prefixes — must match the producing stores.
  static const _netCtxPrefix = 'net_ctx_';
  static const _routerHardenPrefix = 'router_harden_';

  @override
  Future<int> countFor(UserDataCategory category) async {
    final payload = await _payloadFor(category, anonymize: false);
    if (payload is List) return payload.length;
    if (payload is Map) return payload.length;
    return payload == null ? 0 : 1;
  }

  @override
  Future<String> exportCategory(
    UserDataCategory category, {
    required ExportFormat format,
    bool anonymize = false,
  }) async {
    final payload = await _payloadFor(category, anonymize: anonymize);
    return switch (format) {
      ExportFormat.json => _wrapJson(category, payload, anonymize: anonymize),
      ExportFormat.csv => _payloadToCsv(category, payload),
      ExportFormat.html => _wrapHtml([
        (category, payload),
      ], anonymize: anonymize,),
    };
  }

  @override
  Future<String> exportAll({
    required ExportFormat format,
    bool anonymize = false,
    CategoryNamer? nameOf,
  }) async {
    final entries = <(UserDataCategory, dynamic)>[];
    for (final cat in UserDataCategory.values) {
      entries.add((cat, await _payloadFor(cat, anonymize: anonymize)));
    }
    return switch (format) {
      ExportFormat.json => _jsonEncoder.convert({
        'anonymized': anonymize,
        'exported_at': DateTime.now().toUtc().toIso8601String(),
        'categories': {for (final e in entries) e.$1.jsonKey: e.$2},
      }),
      ExportFormat.html => _wrapHtml(entries, anonymize: anonymize, nameOf: nameOf),
      // CSV bundle would lose its structure across 12 different shapes.
      // Caller should fall back to JSON or HTML; we raise a clear error so
      // the UI can show an actionable message instead of producing junk.
      ExportFormat.csv =>
        throw const FormatException(
          '"All categories" cannot be exported as a single CSV. '
          'Use JSON or HTML instead.',
        ),
    };
  }

  String _wrapJson(
    UserDataCategory category,
    dynamic payload, {
    required bool anonymize,
  }) => _jsonEncoder.convert({
    'category': category.jsonKey,
    'anonymized': anonymize,
    'exported_at': DateTime.now().toUtc().toIso8601String(),
    'data': payload,
  });

  // ── CSV builder ────────────────────────────────────────────────────────

  String _payloadToCsv(UserDataCategory category, dynamic payload) {
    if (payload == null) return '';
    final rows = <List<dynamic>>[];
    if (payload is List) {
      if (payload.isEmpty) return '';
      // List of maps -> use first row's keys as header.
      if (payload.first is Map) {
        final keys = <String>{};
        for (final row in payload) {
          if (row is Map) keys.addAll(row.keys.cast<String>());
        }
        final header = keys.toList();
        rows.add(header);
        for (final row in payload) {
          rows.add(header.map((k) => (row as Map)[k]).toList());
        }
      } else {
        // Scalar list -> single column.
        rows.add([category.jsonKey]);
        for (final v in payload) {
          rows.add([v]);
        }
      }
    } else if (payload is Map) {
      // Treat top-level map as a list of {section, payload_json} rows.
      rows.add(['key', 'value']);
      payload.forEach((key, value) {
        rows.add([key, _csvCellOfNested(value)]);
      });
    } else {
      rows
        ..add([category.jsonKey])
        ..add([payload]);
    }
    return rows.map(_csvLine).join('\r\n');
  }

  String _csvLine(List<dynamic> row) => row.map(_csvCell).join(',');

  String _csvCell(dynamic raw) {
    final value = raw is Map || raw is List ? _csvCellOfNested(raw) : raw;
    final stringValue = value?.toString() ?? '';
    final needsQuotes =
        stringValue.contains(',') ||
        stringValue.contains('"') ||
        stringValue.contains('\n') ||
        stringValue.contains('\r');
    if (!needsQuotes) return stringValue;
    final escaped = stringValue.replaceAll('"', '""');
    return '"$escaped"';
  }

  /// Nested maps/lists are kept faithful by serialising them as a JSON
  /// string in a single CSV column.
  String _csvCellOfNested(dynamic raw) => jsonEncode(raw);

  // ── HTML builder ───────────────────────────────────────────────────────

  String _wrapHtml(
    List<(UserDataCategory, dynamic)> entries, {
    required bool anonymize,
    CategoryNamer? nameOf,
  }) {
    final buffer =
        StringBuffer()
          ..writeln('<!doctype html>')
          ..writeln('<html lang="en"><head><meta charset="utf-8">')
          ..writeln('<title>Torcav local data export</title>')
          ..writeln(
            '<style>'
            'body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial;'
            'background:#0d1117;color:#e6edf3;padding:24px;}'
            'h1{color:#58a6ff;letter-spacing:2px;font-weight:700;}'
            'h2{color:#58a6ff;margin-top:32px;border-bottom:1px solid #2b3d56;'
            'padding-bottom:6px;}'
            '.meta{color:#8b949e;font-size:12px;margin-bottom:24px;}'
            'table{width:100%;border-collapse:collapse;margin-top:8px;}'
            'th,td{border-bottom:1px solid #2b3d56;padding:8px 10px;'
            'text-align:left;font-size:13px;vertical-align:top;}'
            'th{color:#79c0ff;font-weight:600;}'
            'pre{background:#161b22;border-radius:6px;padding:12px;'
            'font-size:12px;overflow:auto;}'
            '.empty{color:#8b949e;font-style:italic;}'
            '</style>',
          )
          ..writeln('</head><body>')
          ..writeln('<h1>TORCAV — LOCAL DATA EXPORT</h1>')
          ..writeln(
            '<div class="meta">'
            'Exported: ${DateTime.now().toUtc().toIso8601String()} · '
            'Anonymised: ${anonymize ? "yes" : "no"}'
            '</div>',
          );

    for (final entry in entries) {
      final (category, payload) = entry;
      buffer.writeln('<h2>${_htmlEscape(nameOf?.call(category) ?? category.labelKey)}</h2>');
      _appendHtmlSection(buffer, payload);
    }

    buffer.writeln('</body></html>');
    return buffer.toString();
  }

  void _appendHtmlSection(StringBuffer buffer, dynamic payload) {
    if (payload == null) {
      buffer.writeln('<div class="empty">No data.</div>');
      return;
    }
    if (payload is List) {
      if (payload.isEmpty) {
        buffer.writeln('<div class="empty">No entries.</div>');
        return;
      }
      if (payload.first is Map) {
        final keys = <String>{};
        for (final row in payload) {
          if (row is Map) keys.addAll(row.keys.cast<String>());
        }
        buffer.writeln('<table>');
        buffer.write('<tr>');
        for (final k in keys) {
          buffer.write('<th>${_htmlEscape(k)}</th>');
        }
        buffer.writeln('</tr>');
        for (final row in payload) {
          buffer.write('<tr>');
          for (final k in keys) {
            final value = (row as Map)[k];
            buffer.write('<td>${_htmlCell(value)}</td>');
          }
          buffer.writeln('</tr>');
        }
        buffer.writeln('</table>');
      } else {
        buffer
          ..writeln('<ul>')
          ..writeAll(
            payload.map((e) => '<li>${_htmlEscape(e.toString())}</li>'),
            '\n',
          )
          ..writeln('\n</ul>');
      }
    } else if (payload is Map) {
      buffer.writeln('<table>');
      buffer.writeln('<tr><th>key</th><th>value</th></tr>');
      payload.forEach((k, v) {
        buffer.writeln(
          '<tr><td>${_htmlEscape(k.toString())}</td>'
          '<td>${_htmlCell(v)}</td></tr>',
        );
      });
      buffer.writeln('</table>');
    } else {
      buffer.writeln('<pre>${_htmlEscape(payload.toString())}</pre>');
    }
  }

  String _htmlCell(dynamic value) {
    if (value == null) return '';
    if (value is Map || value is List) {
      return '<pre>${_htmlEscape(_jsonEncoder.convert(value))}</pre>';
    }
    return _htmlEscape(value.toString());
  }

  String _htmlEscape(String input) => input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');

  Future<dynamic> _payloadFor(
    UserDataCategory category, {
    required bool anonymize,
  }) async {
    switch (category) {
      case UserDataCategory.wifiScanHistory:
        final snapshots = await _wifiHistory.loadSnapshots(limit: 10000);
        return snapshots
            .map((s) => _snapshotToJson(s, anonymize: anonymize))
            .toList();

      case UserDataCategory.speedTestResults:
        final results = await _speedTestHistory.getRecent(limit: 10000);
        return results
            .map(
              (r) => {
                'recorded_at': r.recordedAt.toIso8601String(),
                'latency_ms': r.latencyMs,
                'jitter_ms': r.jitterMs,
                'download_mbps': r.downloadMbps,
                'upload_mbps': r.uploadMbps,
                'packet_loss': r.packetLoss,
                'loaded_latency_ms': r.loadedLatencyMs,
              },
            )
            .toList();

      case UserDataCategory.securityEvents:
        final events = await _security.getSecurityEvents();
        return events
            .map((e) => _eventToJson(e, anonymize: anonymize))
            .toList();

      case UserDataCategory.knownAndTrustedNetworks:
        final known = await _security.getKnownNetworks();
        final trusted = await _security.getTrustedNetworkProfiles();
        return {
          'known':
              known
                  .map(
                    (k) => {
                      'ssid': anonymize ? '[redacted]' : k.ssid,
                      'bssid': _maskBssid(k.bssid, anonymize),
                    },
                  )
                  .toList(),
          'trusted':
              trusted
                  .map((p) => _trustedToJson(p, anonymize: anonymize))
                  .toList(),
        };

      case UserDataCategory.channelRatingsHistory:
        final samples = await _channelRatings.getHistory();
        return samples
            .map(
              (s) => {
                'channel': s.channel,
                'frequency': s.frequency,
                'rating': s.rating,
                'timestamp': s.timestamp.toIso8601String(),
              },
            )
            .toList();

      case UserDataCategory.heatmapSessions:
        final sessions = await _heatmap.getSessions();
        return sessions
            .map((s) => _heatmapSessionToJson(s, anonymize: anonymize))
            .toList();

      case UserDataCategory.lanScanLatest:
        final session = await _lanHistory.getLatestSession();
        if (session == null) return null;
        return _lanSessionToJson(session, anonymize: anonymize);

      case UserDataCategory.deviceLabelOverrides:
        final all = await _deviceLabels.getAll();
        return {
          for (final entry in all.entries)
            (anonymize ? _maskMac(entry.key) : entry.key): entry.value,
        };

      case UserDataCategory.pinnedNetworks:
        return _favorites.pinned.map((b) => _maskBssid(b, anonymize)).toList();

      case UserDataCategory.scoreHistory:
        final scores = await _scoreHistory.getRecentScores(limit: 10000);
        return scores
            .map(
              (s) => {'score': s.score, 'recorded_at': s.at.toIso8601String()},
            )
            .toList();

      case UserDataCategory.networkContextOverrides:
        return _readPrefixed(_netCtxPrefix, anonymize: anonymize);

      case UserDataCategory.routerHardeningProgress:
        return _readPrefixed(_routerHardenPrefix, anonymize: anonymize);
    }
  }

  // ── Hive prefix iteration ──────────────────────────────────────────────

  Map<String, dynamic> _readPrefixed(String prefix, {required bool anonymize}) {
    final result = <String, dynamic>{};
    final box = _hive.box;
    for (final raw in box.keys) {
      if (raw is! String || !raw.startsWith(prefix)) continue;
      final bssid = raw.substring(prefix.length);
      final key = anonymize ? _maskBssid(bssid, true) : bssid;
      result[key] = box.get(raw);
    }
    return result;
  }

  // ── Anonymisation helpers ──────────────────────────────────────────────

  String _maskBssid(String bssid, bool anonymize) {
    if (!anonymize) return bssid;
    final parts = bssid.split(':');
    if (parts.length != 6) return '[redacted]';
    return '${parts[0]}:${parts[1]}:${parts[2]}:XX:XX:XX';
  }

  String _maskMac(String mac) => _maskBssid(mac, true);

  String _maskSsid(String ssid, bool anonymize) =>
      anonymize ? '[redacted]' : ssid;

  // ── Per-entity JSON adapters ───────────────────────────────────────────

  Map<String, dynamic> _snapshotToJson(
    ScanSnapshot snapshot, {
    required bool anonymize,
  }) => {
    'timestamp': snapshot.timestamp.toIso8601String(),
    'backend_used': snapshot.backendUsed,
    'interface_name': snapshot.interfaceName,
    'networks':
        snapshot.networks
            .map(
              (n) => {
                'ssid': _maskSsid(n.ssid, anonymize),
                'bssid': _maskBssid(n.bssid, anonymize),
                'avg_signal_dbm': n.avgSignalDbm,
                'signal_std_dev': n.signalStdDev,
                'samples': n.signalDbmSamples,
                'channel': n.channel,
                'frequency': n.frequency,
                'security': n.security.name,
                'vendor': n.vendor,
                'is_hidden': n.isHidden,
              },
            )
            .toList(),
    'channel_stats':
        snapshot.channelStats
            .map(
              (c) => {
                'channel': c.channel,
                'frequency': c.frequency,
                'network_count': c.networkCount,
                'avg_signal_dbm': c.avgSignalDbm,
                'congestion_score': c.congestionScore,
                'recommendation': c.recommendation,
              },
            )
            .toList(),
    'band_stats':
        snapshot.bandStats
            .map(
              (b) => {
                'band': b.label,
                'network_count': b.networkCount,
                'avg_signal_dbm': b.avgSignalDbm,
                'recommended_channels': b.recommendedChannels,
                'recommendation': b.recommendation,
              },
            )
            .toList(),
  };

  Map<String, dynamic> _eventToJson(
    SecurityEvent event, {
    required bool anonymize,
  }) => {
    'type': event.type.name,
    'severity': event.severity.name,
    'ssid': _maskSsid(event.ssid, anonymize),
    'bssid': _maskBssid(event.bssid, anonymize),
    'timestamp': event.timestamp.toIso8601String(),
    'evidence': event.evidence,
    'is_read': event.isRead,
  };

  Map<String, dynamic> _trustedToJson(
    TrustedNetworkProfile profile, {
    required bool anonymize,
  }) => {
    'ssid': _maskSsid(profile.ssid, anonymize),
    'bssid': _maskBssid(profile.bssid, anonymize),
    'gateway': profile.gateway,
    'fingerprint': profile.fingerprint.toJson(),
    'trusted_at': profile.trustedAt.toIso8601String(),
    'last_confirmed_at': profile.lastConfirmedAt.toIso8601String(),
    'notes': profile.notes,
  };

  Map<String, dynamic> _heatmapSessionToJson(
    HeatmapSession session, {
    required bool anonymize,
  }) => {
    'id': session.id,
    'name': session.name,
    'created_at': session.createdAt.toIso8601String(),
    'points':
        session.points
            .map((p) => _heatmapPointToJson(p, anonymize: anonymize))
            .toList(),
  };

  Map<String, dynamic> _heatmapPointToJson(
    HeatmapPoint point, {
    required bool anonymize,
  }) => {
    'floor_x': point.floorX,
    'floor_y': point.floorY,
    'floor_z': point.floorZ,
    'heading': point.heading,
    'rssi': point.rssi,
    'timestamp': point.timestamp.toIso8601String(),
    'ssid': _maskSsid(point.ssid, anonymize),
    'bssid': _maskBssid(point.bssid, anonymize),
    'floor': point.floor,
    'sample_count': point.sampleCount,
    'rssi_std_dev': point.rssiStdDev,
    'is_flagged': point.isFlagged,
  };

  Map<String, dynamic> _lanSessionToJson(
    LanScanSession session, {
    required bool anonymize,
  }) => {
    'session_key': session.sessionKey,
    'created_at': session.createdAt.toIso8601String(),
    'target': session.target,
    'profile': session.profile,
    'hosts':
        session.hosts.map((h) => _hostToJson(h, anonymize: anonymize)).toList(),
  };

  Map<String, dynamic> _hostToJson(
    HostScanResult host, {
    required bool anonymize,
  }) => {
    'ip': host.ip,
    'mac': anonymize ? _maskMac(host.mac) : host.mac,
    'host_name': anonymize ? '[redacted]' : host.hostName,
    'vendor': host.vendor,
    'os_guess': host.osGuess,
    'latency': host.latency,
    'device_type': host.deviceType,
    'is_gateway': host.isGateway,
    'is_suspicious': host.isSuspicious,
    'is_ai_classified': host.isAiClassified,
    'netbios_name': anonymize ? null : host.netbiosName,
    'services':
        host.services
            .map(
              (s) => {
                'port': s.port,
                'protocol': s.protocol,
                'service_name': s.serviceName,
                'product': s.product,
                'version': s.version,
              },
            )
            .toList(),
    'exposure_score': host.exposureScore,
    'exposure_findings':
        host.exposureFindings
            .map((f) => _exposureFindingToJson(f, anonymize: anonymize))
            .toList(),
  };

  Map<String, dynamic> _exposureFindingToJson(
    LanExposureFinding finding, {
    required bool anonymize,
  }) => {
    'rule_id': finding.ruleId,
    'host_ip': finding.hostIp,
    'host_mac': anonymize ? _maskMac(finding.hostMac) : finding.hostMac,
    'host_vendor': finding.hostVendor,
    'summary': finding.summary,
    'risk': finding.risk.name,
    'evidence': finding.evidence,
    'remediation': finding.remediation,
    'service_name': finding.serviceName,
    'port': finding.port,
  };
}
