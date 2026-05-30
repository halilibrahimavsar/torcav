import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/core/theme/app_theme.dart';

/// Pump [child] inside a [MaterialApp] wired with the app's localization
/// delegates and theme. Defaults to `dark` mode (matches production).
///
/// Use this in every widget test instead of hand-rolling a MaterialApp wrapper.
Future<void> pumpAppWidget(
  WidgetTester tester,
  Widget child, {
  ThemeMode themeMode = ThemeMode.dark,
  Locale locale = const Locale('en'),
  Size? surfaceSize,
}) async {
  if (surfaceSize != null) {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    ),
  );
}
