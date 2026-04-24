import 'dart:async';

import 'package:injectable/injectable.dart';
import '../../../../core/storage/hive_storage_service.dart';

/// Persists a set of pinned/favourite network BSSIDs in Hive.
@lazySingleton
class FavoritesStore {
  static const _key = 'pinned_bssids';
  final HiveStorageService _storage;
  final StreamController<Set<String>> _changes =
      StreamController<Set<String>>.broadcast();
  Set<String> _pinned;

  FavoritesStore(this._storage) : _pinned = _load(_storage);

  Set<String> get pinned => _pinned;

  Stream<Set<String>> get changes => _changes.stream;

  void toggle(String bssid) {
    final next = Set<String>.of(_pinned);
    if (next.contains(bssid)) {
      next.remove(bssid);
    } else {
      next.add(bssid);
    }
    _pinned = next;
    _changes.add(next);
    unawaited(_storage.save(_key, next.toList()));
  }

  bool isPinned(String bssid) => _pinned.contains(bssid);

  Future<void> clearAll() async {
    _pinned = {};
    _changes.add({});
    await _storage.delete(_key);
  }

  static Set<String> _load(HiveStorageService storage) {
    return (storage.get<List<dynamic>>(_key) ?? []).cast<String>().toSet();
  }
}

