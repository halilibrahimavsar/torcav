import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../data/datasources/wifi_scan_history_local_data_source.dart';
import '../entities/scan_snapshot.dart';

@lazySingleton
class ScanSessionStore {
  ScanSessionStore(this._history);

  final WifiScanHistoryLocalDataSource _history;
  final List<ScanSnapshot> _snapshots = [];
  final StreamController<ScanSnapshot> _controller =
      StreamController<ScanSnapshot>.broadcast();
  bool _restored = false;

  Stream<ScanSnapshot> get snapshots => _controller.stream;

  List<ScanSnapshot> get all => List.unmodifiable(_snapshots);

  ScanSnapshot? get latest => _snapshots.isEmpty ? null : _snapshots.last;

  Future<void> restore({int limit = 20}) async {
    if (_restored) {
      return;
    }

    final restored = await _history.loadSnapshots(limit: limit);
    _snapshots
      ..clear()
      ..addAll(restored);
    _restored = true;
  }

  void add(ScanSnapshot snapshot) {
    final existingIndex = _snapshots.indexWhere(
      (entry) => entry.timestamp == snapshot.timestamp,
    );
    if (existingIndex >= 0) {
      _snapshots[existingIndex] = snapshot;
    } else {
      _snapshots.add(snapshot);
    }
    _controller.add(snapshot);
    unawaited(_history.saveSnapshot(snapshot));
  }

  void clear() {
    _snapshots.clear();
    unawaited(_history.clear());
  }
}
