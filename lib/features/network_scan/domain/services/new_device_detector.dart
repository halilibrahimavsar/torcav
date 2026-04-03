import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entities/host_scan_result.dart';

/// Compares scanned MAC addresses against a persisted known set.
/// Returns MACs that have not been seen before, and persists them.
@lazySingleton
class NewDeviceDetector {
  static const _key = 'known_mac_addresses';
  final SharedPreferences _prefs;

  NewDeviceDetector(this._prefs);

  /// Returns the list of [HostScanResult]s whose MAC was not previously seen.
  /// Also adds all new MACs to the persisted set.
  List<HostScanResult> detectNew(List<HostScanResult> hosts) {
    final known = (_prefs.getStringList(_key) ?? []).toSet();
    final newDevices = hosts.where((h) => !known.contains(h.mac)).toList();
    if (newDevices.isNotEmpty) {
      final updated = known..addAll(newDevices.map((h) => h.mac));
      _prefs.setStringList(_key, updated.toList());
    }
    return newDevices;
  }
}
