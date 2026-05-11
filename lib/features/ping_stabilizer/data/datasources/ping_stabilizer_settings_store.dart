import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/storage/hive_storage_service.dart';
import '../../domain/entities/qos_rule.dart';
import '../../domain/entities/stabilization_profile.dart';

/// Persists user-tweakable Ping Stabilizer settings (auto-DNS, jitter
/// threshold, selected profile, custom profiles) so toggles survive
/// process death and app restarts.
///
/// Backed by [HiveStorageService] (the project's standard non-sensitive
/// preference layer) — no schema migration is needed because Hive boxes
/// gracefully ignore unknown keys.
@lazySingleton
class PingStabilizerSettingsStore {
  static const _kAutoDns = 'ps.autoDns';
  static const _kJitterThreshold = 'ps.jitterThresholdMs';
  static const _kSelectedProfileId = 'ps.selectedProfileId';
  static const _kCustomProfiles = 'ps.customProfilesJson';

  final HiveStorageService _hive;

  PingStabilizerSettingsStore(this._hive);

  bool get autoSwitchDns =>
      _hive.get<bool>(_kAutoDns, defaultValue: false) ?? false;
  Future<void> setAutoSwitchDns(bool v) => _hive.save(_kAutoDns, v);

  double get jitterThresholdMs =>
      _hive.get<double>(_kJitterThreshold, defaultValue: 30.0) ?? 30.0;
  Future<void> setJitterThresholdMs(double v) =>
      _hive.save(_kJitterThreshold, v);

  String? get selectedProfileId => _hive.get<String>(_kSelectedProfileId);
  Future<void> setSelectedProfileId(String id) =>
      _hive.save(_kSelectedProfileId, id);

  List<StabilizationProfile> loadCustomProfiles() {
    final raw = _hive.get<String>(_kCustomProfiles);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(_decodeProfile)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveCustomProfiles(List<StabilizationProfile> profiles) async {
    final encoded = jsonEncode(profiles.map(_encodeProfile).toList());
    await _hive.save(_kCustomProfiles, encoded);
  }

  // ── (de)serialisation ─────────────────────────────────────────────────

  Map<String, dynamic> _encodeProfile(StabilizationProfile p) => {
    'id': p.id,
    'displayName': p.displayName,
    'gameKey': p.gameKey,
    'dualInterface': p.dualInterface,
    'qosRules':
        p.qosRules
            .map(
              (r) => {
                'protocol': r.protocol.name,
                'portStart': r.portStart,
                'portEnd': r.portEnd,
                'queue': r.queue.name,
                'dscp': r.dscp,
              },
            )
            .toList(),
  };

  StabilizationProfile _decodeProfile(Map<String, dynamic> m) {
    final rulesRaw = (m['qosRules'] as List<dynamic>?) ?? const [];
    final rules =
        rulesRaw
            .whereType<Map<String, dynamic>>()
            .map(
              (r) => QosRule(
                protocol: QosProtocol.values.firstWhere(
                  (p) => p.name == r['protocol'],
                  orElse: () => QosProtocol.udp,
                ),
                portStart: (r['portStart'] as num?)?.toInt() ?? 1024,
                portEnd: (r['portEnd'] as num?)?.toInt() ?? 65535,
                queue: QosQueue.values.firstWhere(
                  (q) => q.name == r['queue'],
                  orElse: () => QosQueue.lowLatency,
                ),
                dscp: (r['dscp'] as num?)?.toInt() ?? 0,
              ),
            )
            .toList();
    return StabilizationProfile(
      id: m['id'] as String,
      displayName: m['displayName'] as String,
      gameKey: m['gameKey'] as String?,
      qosRules: rules,
      dualInterface: m['dualInterface'] as bool? ?? false,
    );
  }
}
