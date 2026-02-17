import 'dart:async';

import 'package:injectable/injectable.dart';

import '../entities/app_settings.dart';

@lazySingleton
class AppSettingsStore {
  AppSettings _settings = const AppSettings();
  final StreamController<AppSettings> _changes =
      StreamController<AppSettings>.broadcast();

  AppSettings get value => _settings;

  Stream<AppSettings> get changes => _changes.stream;

  void update(AppSettings settings) {
    _settings = settings;
    _changes.add(settings);
  }
}
