import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../storage/hive_storage_service.dart';

@singleton
class LocaleCubit extends Cubit<Locale> {
  static const String _localeKey = 'app_locale';
  static const Set<String> _supportedCodes = {'en', 'tr', 'de', 'ku'};

  final HiveStorageService _storage;

  LocaleCubit(this._storage) : super(const Locale('en')) {
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    final savedCode = _storage.get<String>(_localeKey);
    if (savedCode != null) {
      emit(Locale(savedCode));
    } else {
      final detected = _detectSystemLocale();
      if (detected != null) {
        _storage.save(_localeKey, detected.languageCode);
        emit(detected);
      }
    }
  }

  /// Reads the device's preferred locale list and returns the first one
  /// whose language code is among the app's supported languages.
  Locale? _detectSystemLocale() {
    final deviceLocales = WidgetsBinding.instance.platformDispatcher.locales;
    for (final locale in deviceLocales) {
      if (_supportedCodes.contains(locale.languageCode)) {
        return Locale(locale.languageCode);
      }
    }
    return null;
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != state.languageCode) {
      await _storage.save(_localeKey, locale.languageCode);
      emit(locale);
    }
  }

  /// Resets to system locale detection and re-applies it.
  Future<void> detectAndApplySystemLocale() async {
    final detected = _detectSystemLocale();
    if (detected != null) {
      await setLocale(detected);
    }
  }
}

