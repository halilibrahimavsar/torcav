import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'core/l10n/delegates/fallback_localization_delegate.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/app_shell/presentation/pages/app_shell_page.dart';
import 'features/app_shell/presentation/pages/onboarding_page.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/l10n/locale_cubit.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await configureDependencies();
  await getIt<NotificationService>().initialize();

  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(TorcavApp(showOnboarding: !onboardingComplete));
}

class TorcavApp extends StatelessWidget {
  final bool showOnboarding;

  const TorcavApp({super.key, this.showOnboarding = false});

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
                home:
                    showOnboarding
                        ? const OnboardingPage()
                        : const AppShellPage(),
              );
            },
          );
        },
      ),
    );
  }
}
