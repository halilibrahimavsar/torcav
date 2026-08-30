import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';

import 'package:torcav/core/settings/app_settings.dart';

@lazySingleton
class AppSettingsStore {
  static const _settingsKey = 'scan_behavior_settings';
  final HiveStorageService _storage;
  AppSettings _settings;
  final StreamController<AppSettings> _changes =
      StreamController<AppSettings>.broadcast();

  AppSettingsStore(this._storage) : _settings = const AppSettings();

  // `preResolve: true` injectable'a init future'ını DI kayıt sırasında
  // await ettirir; consumer'lar `getIt<AppSettingsStore>()` çağırdığında
  // instance hazır gelir. Olmazsa `_CyberGridBackgroundState.initState`
  // gibi sync erişimler "not ready yet" StateError'ı fırlatır.
  @PostConstruct(preResolve: true)
  Future<void> init() async {
    _settings = await _loadInitialValue(_storage);
    _changes.add(_settings);
  }

  AppSettings get value => _settings;

  Stream<AppSettings> get changes => _changes.stream;

  void update(AppSettings settings) {
    _settings = settings;
    _changes.add(settings);
    unawaited(_storage.save(_settingsKey, jsonEncode(settings.toJson())));
  }

  @disposeMethod
  void dispose() {
    _changes.close();
  }

  static Future<AppSettings> _loadInitialValue(HiveStorageService storage) async {
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
    } catch (e) {
      // In case of corruption, return default settings
      return const AppSettings();
    }
  }
}
