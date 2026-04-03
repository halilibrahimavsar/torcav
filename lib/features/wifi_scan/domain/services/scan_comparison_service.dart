import '../entities/scan_snapshot.dart';
import '../entities/wifi_observation.dart';

class ScanDiff {
  final List<WifiObservation> added;
  final List<WifiObservation> removed;
  final List<({WifiObservation before, WifiObservation after})> changed;

  const ScanDiff({
    required this.added,
    required this.removed,
    required this.changed,
  });

  bool get isEmpty => added.isEmpty && removed.isEmpty && changed.isEmpty;
}

class ScanComparisonService {
  ScanDiff compare(ScanSnapshot before, ScanSnapshot after) {
    final beforeMap = {for (final n in before.networks) n.bssid: n};
    final afterMap = {for (final n in after.networks) n.bssid: n};

    final added = after.networks
        .where((n) => !beforeMap.containsKey(n.bssid))
        .toList();
    final removed = before.networks
        .where((n) => !afterMap.containsKey(n.bssid))
        .toList();
    final changed = <({WifiObservation before, WifiObservation after})>[];

    for (final entry in afterMap.entries) {
      final prev = beforeMap[entry.key];
      if (prev != null && prev.avgSignalDbm != entry.value.avgSignalDbm) {
        changed.add((before: prev, after: entry.value));
      }
    }

    return ScanDiff(added: added, removed: removed, changed: changed);
  }
}
