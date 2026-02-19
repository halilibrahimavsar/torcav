import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class ThemeCubit extends ValueNotifier<ThemeMode> {
  static const _key = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(ThemeMode.dark) {
    _load();
  }

  void _load() {
    final saved = _prefs.getString(_key);
    value = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  void setTheme(ThemeMode mode) {
    value = mode;
    _prefs.setString(_key, mode.name);
  }

  void toggle() {
    setTheme(value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  bool get isDark => value == ThemeMode.dark;
  bool get isLight => value == ThemeMode.light;
}
