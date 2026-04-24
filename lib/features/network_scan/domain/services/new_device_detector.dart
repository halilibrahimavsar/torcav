import 'package:injectable/injectable.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';

import '../entities/host_scan_result.dart';

/// Compares scanned MAC addresses against a persisted known set.
/// Returns MACs that have not been seen before, and persists them.
@lazySingleton
class NewDeviceDetector {
  static const _key = 'known_mac_addresses';
  final HiveStorageService _storage;

  NewDeviceDetector(this._storage);

  /// Returns the list of [HostScanResult]s whose MAC was not previously seen.
  /// Also adds all new MACs to the persisted set.
  List<HostScanResult> detectNew(List<HostScanResult> hosts) {
    final known = (_storage.get<List<dynamic>>(_key) ?? []).cast<String>().toSet();
    final newDevices = hosts.where((h) => !known.contains(h.mac)).toList();
    if (newDevices.isNotEmpty) {
      final updated = known..addAll(newDevices.map((h) => h.mac));
      _storage.save(_key, updated.toList());
    }
    return newDevices;
  }
}

