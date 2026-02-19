import 'package:equatable/equatable.dart';
import '../../../wifi_scan/domain/entities/wifi_network.dart';

enum DiffChangeType { added, removed, modified, unchanged }

class NetworkDiff extends Equatable {
  final String ssid;
  final String bssid;
  final DiffChangeType changeType;
  final WifiNetwork? before;
  final WifiNetwork? after;
  final List<String> changedFields;

  const NetworkDiff({
    required this.ssid,
    required this.bssid,
    required this.changeType,
    this.before,
    this.after,
    this.changedFields = const [],
  });

  bool get isAdded => changeType == DiffChangeType.added;
  bool get isRemoved => changeType == DiffChangeType.removed;
  bool get isModified => changeType == DiffChangeType.modified;

  @override
  List<Object?> get props => [
    ssid,
    bssid,
    changeType,
    before,
    after,
    changedFields,
  ];
}

class ScanDiffResult extends Equatable {
  final DateTime snapshot1Time;
  final DateTime snapshot2Time;
  final List<NetworkDiff> diffs;
  final int addedCount;
  final int removedCount;
  final int modifiedCount;
  final int unchangedCount;

  const ScanDiffResult({
    required this.snapshot1Time,
    required this.snapshot2Time,
    required this.diffs,
    required this.addedCount,
    required this.removedCount,
    required this.modifiedCount,
    required this.unchangedCount,
  });

  int get totalChanges => addedCount + removedCount + modifiedCount;
  bool get hasChanges => totalChanges > 0;

  @override
  List<Object?> get props => [
    snapshot1Time,
    snapshot2Time,
    diffs,
    addedCount,
    removedCount,
    modifiedCount,
    unchangedCount,
  ];
}
