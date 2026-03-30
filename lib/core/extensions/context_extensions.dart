// lib/core/extensions/context_extensions.dart
import 'package:flutter/material.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';

extension LocalizationX on BuildContext {
  /// Access [AppLocalizations] from [BuildContext].
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension ThemeX on BuildContext {
  /// Access [ThemeData] from [BuildContext].
  ThemeData get theme => Theme.of(this);

  /// Access [ColorScheme] from [BuildContext].
  ColorScheme get colorScheme => theme.colorScheme;

  /// Access [TextTheme] from [BuildContext].
  TextTheme get textTheme => theme.textTheme;
}
