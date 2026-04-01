import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class LocaleCubit extends Cubit<Locale> {
  static const String _localeKey = 'app_locale';
  final SharedPreferences _prefs;

  LocaleCubit(this._prefs) : super(const Locale('en')) {
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    final savedCode = _prefs.getString(_localeKey);
    if (savedCode != null) {
      emit(Locale(savedCode));
    } else {
      // Default to system locale logic if needed, or stick to 'en' as safe default
      // For now, we default to 'en' in super, but we could check platform locale here.
      // But typically MaterialApp handles system locale if we provide null/supportedLocales.
      // However, managing state explicitly is better for manual override.
      // Let's stick to explicit default 'en' if nothing saved.
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != state.languageCode) {
      await _prefs.setString(_localeKey, locale.languageCode);
      emit(locale);
    }
  }
}
