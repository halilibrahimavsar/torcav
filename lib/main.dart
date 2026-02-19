import 'package:flutter/material.dart';

import 'package:torcav/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/i18n/delegates/fallback_localization_delegate.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/app_shell/presentation/pages/app_shell_page.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/i18n/locale_cubit.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await configureDependencies();
  runApp(const TorcavApp());
}

class TorcavApp extends StatelessWidget {
  const TorcavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => getIt<LocaleCubit>())],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return ValueListenableBuilder<ThemeMode>(
            valueListenable: getIt<ThemeCubit>(),
            builder: (context, themeMode, _) {
              return MaterialApp(
                title: 'Torcav Wi-Fi Analyzer',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                locale: locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  FallbackMaterialLocalizationsDelegate(),
                  FallbackCupertinoLocalizationsDelegate(),
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                home: const AppShellPage(),
              );
            },
          );
        },
      ),
    );
  }
}
