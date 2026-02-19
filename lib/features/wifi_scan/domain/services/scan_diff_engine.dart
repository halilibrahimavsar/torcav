import 'package:injectable/injectable.dart';

import '../entities/scan_diff.dart';
import '../entities/wifi_network.dart';

@lazySingleton
class ScanDiffEngine {
  ScanDiffResult compare({
    required List<WifiNetwork> before,
    required List<WifiNetwork> after,
    required DateTime beforeTime,
    required DateTime afterTime,
  }) {
    final diffs = <NetworkDiff>[];
    var added = 0, removed = 0, modified = 0, unchanged = 0;

    final beforeMap = {for (final n in before) n.bssid: n};
    final afterMap = {for (final n in after) n.bssid: n};

    for (final entry in afterMap.entries) {
      final bssid = entry.key;
      final afterNetwork = entry.value;
      final beforeNetwork = beforeMap[bssid];

      if (beforeNetwork == null) {
        diffs.add(
          NetworkDiff(
            ssid: afterNetwork.ssid,
            bssid: bssid,
            changeType: DiffChangeType.added,
            after: afterNetwork,
          ),
        );
        added++;
      } else {
        final changedFields = _findChangedFields(beforeNetwork, afterNetwork);
        if (changedFields.isEmpty) {
          diffs.add(
            NetworkDiff(
              ssid: afterNetwork.ssid,
              bssid: bssid,
              changeType: DiffChangeType.unchanged,
              before: beforeNetwork,
              after: afterNetwork,
            ),
          );
          unchanged++;
        } else {
          diffs.add(
            NetworkDiff(
              ssid: afterNetwork.ssid,
              bssid: bssid,
              changeType: DiffChangeType.modified,
              before: beforeNetwork,
              after: afterNetwork,
              changedFields: changedFields,
            ),
          );
          modified++;
        }
      }
    }

    for (final entry in beforeMap.entries) {
      final bssid = entry.key;
      final beforeNetwork = entry.value;

      if (!afterMap.containsKey(bssid)) {
        diffs.add(
          NetworkDiff(
            ssid: beforeNetwork.ssid,
            bssid: bssid,
            changeType: DiffChangeType.removed,
            before: beforeNetwork,
          ),
        );
        removed++;
      }
    }

    diffs.sort((a, b) {
      final priorityOrder = [
        DiffChangeType.added,
        DiffChangeType.removed,
        DiffChangeType.modified,
        DiffChangeType.unchanged,
      ];
      return priorityOrder
          .indexOf(a.changeType)
          .compareTo(priorityOrder.indexOf(b.changeType));
    });

    return ScanDiffResult(
      snapshot1Time: beforeTime,
      snapshot2Time: afterTime,
      diffs: diffs,
      addedCount: added,
      removedCount: removed,
      modifiedCount: modified,
      unchangedCount: unchanged,
    );
  }

  List<String> _findChangedFields(WifiNetwork before, WifiNetwork after) {
    final changes = <String>[];

    if (before.signalStrength != after.signalStrength) {
      final delta = after.signalStrength - before.signalStrength;
      changes.add(
        'Signal: ${before.signalStrength} → ${after.signalStrength} ($delta dBm)',
      );
    }
    if (before.channel != after.channel) {
      changes.add('Channel: ${before.channel} → ${after.channel}');
    }
    if (before.security != after.security) {
      changes.add('Security: ${before.security.name} → ${after.security.name}');
    }
    if (before.vendor != after.vendor) {
      changes.add('Vendor: ${before.vendor} → ${after.vendor}');
    }
    if (before.isHidden != after.isHidden) {
      changes.add('Hidden: ${before.isHidden} → ${after.isHidden}');
    }

    return changes;
  }
}
