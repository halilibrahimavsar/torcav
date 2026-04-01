import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// A wrapper delegate that provides MaterialLocalizations for languages that
/// Flutter's default `GlobalMaterialLocalizations` does not support (like Kurdish 'ku').
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    // 1. Try to load the official delegate for the locale first.
    try {
      // The official delegate might return null or throw if unsupported.
      final localizations = await GlobalMaterialLocalizations.delegate.load(
        locale,
      );
      return localizations;
    } catch (_) {
      // 2. If it fails (e.g. 'ku' is unsupported), fallback to English
      // but wrap it so it's accepted for the requested locale.
      final english = await GlobalMaterialLocalizations.delegate.load(
        const Locale('en'),
      );
      return english;
    }
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

/// A wrapper delegate for CupertinoLocalizations fallback.
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    try {
      final localizations = await GlobalCupertinoLocalizations.delegate.load(
        locale,
      );
      return localizations;
    } catch (_) {
      final english = await GlobalCupertinoLocalizations.delegate.load(
        const Locale('en'),
      );
      return english;
    }
  }

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}
