import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entities/app_settings.dart';

@lazySingleton
class AppSettingsStore {
  static const _settingsKey = 'scan_behavior_settings';
  final SharedPreferences _prefs;
  AppSettings _settings;
  final StreamController<AppSettings> _changes =
      StreamController<AppSettings>.broadcast();

  AppSettingsStore(this._prefs) : _settings = _loadInitialValue(_prefs);

  AppSettings get value => _settings;

  Stream<AppSettings> get changes => _changes.stream;

  void update(AppSettings settings) {
    _settings = settings;
    _changes.add(settings);
    unawaited(_prefs.setString(_settingsKey, jsonEncode(settings.toJson())));
  }

  static AppSettings _loadInitialValue(SharedPreferences prefs) {
    final raw = prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return const AppSettings();
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const AppSettings();
      }
      return AppSettings.fromJson(decoded);
    } catch (_) {
      return const AppSettings();
    }
  }
}
