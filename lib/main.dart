import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:torcav/core/di/injection.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/core/l10n/locale_cubit.dart';
import 'package:torcav/core/l10n/delegates/fallback_localization_delegate.dart';
import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/features/app_shell/presentation/pages/app_shell_page.dart';
import 'package:torcav/features/wifi_scan/domain/services/scan_session_store.dart';
import 'package:torcav/features/security/presentation/widgets/cyber_grid_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Dependency Injection
  await configureDependencies();
  await getIt<ScanSessionStore>().restore();
  
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
            
            // Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark, // Default to Dark Mode for the neon aesthetic
            
            // Global Layout Configuration
            builder: (context, child) => CyberGridBackground(
              color: AppTheme.darkTheme.colorScheme.primary, // Dynamic color from theme
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    final velocity = notification.scrollDelta ?? 0;
                    CyberGridBackground.updateScrollVelocity(velocity);
                  }
                  return false;
                },
                child: SafeArea(child: child!),
              ),
            ),

            // Localization Configuration
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              FallbackMaterialLocalizationsDelegate(),
              FallbackCupertinoLocalizationsDelegate(),
            ],
            
            // Main Entry Point
            home: const AppShellPage(),
          );
        },
      ),
    );
  }
}
