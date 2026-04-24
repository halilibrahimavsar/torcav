import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../storage/hive_storage_service.dart';

@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  static const _key = 'theme_mode';
  final HiveStorageService _storage;

  ThemeCubit(this._storage) : super(ThemeMode.dark) {
    _load();
  }

  void _load() {
    final saved = _storage.get<String>(_key);
    final mode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    emit(mode);
  }

  void setTheme(ThemeMode mode) {
    _storage.save(_key, mode.name);
    emit(mode);
  }

  void toggle() {
    setTheme(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  bool get isDark => state == ThemeMode.dark;
  bool get isLight => state == ThemeMode.light;
}

