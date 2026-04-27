import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/core/di/injection.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/core/l10n/locale_cubit.dart';
import 'package:torcav/core/l10n/delegates/fallback_localization_delegate.dart';
import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/core/theme/theme_cubit.dart';
import 'package:torcav/features/app_shell/presentation/pages/app_shell_page.dart';
import 'package:torcav/features/wifi_scan/domain/services/scan_session_store.dart';
import 'package:torcav/features/security/presentation/widgets/cyber_grid_background.dart';
import 'package:torcav/core/services/data_retention_service.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('[TorcavError] ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[TorcavError] Uncaught: $error\n$stack');
    return true;
  };

  ErrorWidget.builder = (details) => _NeonErrorWidget(details: details);

  // Initialize Storage and Dependency Injection
  await HiveStorageService.init();
  await configureDependencies();
  await getIt<ScanSessionStore>().restore();

  // Enforce data retention policy at startup
  await getIt<DataRetentionService>().enforceRetention();

  runApp(const TorcavApp());
}

class _NeonErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;
  const _NeonErrorWidget({required this.details});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0A0A0F),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF4444), size: 48),
            const SizedBox(height: 16),
            Text(
              'RENDERING ERROR',
              style: GoogleFonts.orbitron(
                color: const Color(0xFFFF4444),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              details.exceptionAsString(),
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF888888),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class TorcavApp extends StatelessWidget {
  const TorcavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => getIt<LocaleCubit>())],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return BlocProvider(
            create: (_) => getIt<ThemeCubit>(),
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return MaterialApp(
                  title: 'Torcav Wi-Fi Analyzer',
                  debugShowCheckedModeBanner: false,
                  restorationScopeId: 'torcav',

                  // Theme Configuration
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,

                  // Global Layout Configuration
                  builder: (context, child) {
                    final theme = Theme.of(context);
                    return CyberGridBackground(
                      color:
                          theme
                              .colorScheme
                              .primary, // Dynamic color from current theme
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollUpdateNotification) {
                            final velocity = notification.scrollDelta ?? 0;
                            CyberGridBackground.updateScrollVelocity(velocity);
                          }
                          return false;
                        },
                        child: SafeArea(bottom: false, child: child!),
                      ),
                    );
                  },

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
        },
      ),
    );
  }
}
