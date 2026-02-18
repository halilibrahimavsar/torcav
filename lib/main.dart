import 'package:flutter/material.dart';

import 'package:torcav/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/i18n/delegates/fallback_localization_delegate.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/app_shell/presentation/pages/app_shell_page.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/i18n/locale_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const TorcavApp());
}

class TorcavApp extends StatelessWidget {
  const TorcavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LocaleCubit>(),
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            title: 'Torcav Wi-Fi Analyzer',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
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
      ),
    );
  }
}
