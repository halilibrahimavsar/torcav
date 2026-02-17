import 'dart:async';

import 'package:injectable/injectable.dart';

import '../entities/scan_snapshot.dart';

@lazySingleton
class ScanSessionStore {
  final List<ScanSnapshot> _snapshots = [];
  final StreamController<ScanSnapshot> _controller =
      StreamController<ScanSnapshot>.broadcast();

  Stream<ScanSnapshot> get snapshots => _controller.stream;

  List<ScanSnapshot> get all => List.unmodifiable(_snapshots);

  ScanSnapshot? get latest => _snapshots.isEmpty ? null : _snapshots.last;

  void add(ScanSnapshot snapshot) {
    _snapshots.add(snapshot);
    _controller.add(snapshot);
  }

  void clear() {
    _snapshots.clear();
  }
}
