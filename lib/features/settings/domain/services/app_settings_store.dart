import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import '../../../../core/storage/hive_storage_service.dart';

import '../entities/app_settings.dart';

@lazySingleton
class AppSettingsStore {
  static const _settingsKey = 'scan_behavior_settings';
  final HiveStorageService _storage;
  AppSettings _settings;
  final StreamController<AppSettings> _changes =
      StreamController<AppSettings>.broadcast();

  AppSettingsStore(this._storage) : _settings = _loadInitialValue(_storage);

  AppSettings get value => _settings;

  Stream<AppSettings> get changes => _changes.stream;

  void update(AppSettings settings) {
    _settings = settings;
    _changes.add(settings);
    unawaited(_storage.save(_settingsKey, jsonEncode(settings.toJson())));
  }

  static AppSettings _loadInitialValue(HiveStorageService storage) {
    final raw = storage.get<String>(_settingsKey);
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

