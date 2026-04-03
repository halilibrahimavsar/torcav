import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists a set of pinned/favourite network BSSIDs in SharedPreferences.
@lazySingleton
class FavoritesStore {
  static const _key = 'pinned_bssids';
  final SharedPreferences _prefs;
  final StreamController<Set<String>> _changes =
      StreamController<Set<String>>.broadcast();
  Set<String> _pinned;

  FavoritesStore(this._prefs) : _pinned = _load(_prefs);

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
    unawaited(_prefs.setStringList(_key, next.toList()));
  }

  bool isPinned(String bssid) => _pinned.contains(bssid);

  static Set<String> _load(SharedPreferences prefs) {
    return (prefs.getStringList(_key) ?? []).toSet();
  }
}
