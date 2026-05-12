import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/extensions/context_extensions.dart';

import 'package:torcav/core/logging/app_logger.dart';
import 'package:torcav/core/di/injection.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/core/l10n/locale_cubit.dart';
import 'package:torcav/core/l10n/delegates/fallback_localization_delegate.dart';
import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/core/theme/theme_cubit.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';
import 'package:torcav/features/security/presentation/widgets/cyber_grid_background.dart';
import 'package:torcav/features/splash/presentation/pages/splash_page.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      AppLogger.e(
        'FlutterError',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.e('Uncaught Error', error: error, stackTrace: stack);
      return true;
    };

    ErrorWidget.builder = (details) => _NeonErrorWidget(details: details);

    // Core initialization that must happen before runApp
    await HiveStorageService.init();
    await configureDependencies();

    runApp(const TorcavApp());
  }, (error, stack) {
    AppLogger.e('Zone error', error: error, stackTrace: stack);
  });
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
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFFF4444),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.renderingErrorTitle,
              style: GoogleFonts.orbitron(
                color: const Color(0xFFFF4444),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              kReleaseMode
                  ? context.l10n.renderingErrorBody
                  : details.exceptionAsString(),
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
                  onGenerateTitle: (context) => context.l10n.appTitleLong,
                  debugShowCheckedModeBanner: false,
                  restorationScopeId: 'torcav',

                  // Theme Configuration
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,

                  // Global Layout Configuration
                  builder: (context, child) {
                    final theme = Theme.of(context);
                    final topPadding = MediaQuery.of(context).viewPadding.top;

                    return AnnotatedRegion<SystemUiOverlayStyle>(
                      value: const SystemUiOverlayStyle(
                        statusBarColor: Colors.transparent,
                        statusBarIconBrightness: Brightness.light,
                        systemNavigationBarColor: Color(
                          0xFF040506,
                        ), // AppColors.deepBlack
                        systemNavigationBarIconBrightness: Brightness.light,
                      ),
                      child: CyberGridBackground(
                        color:
                            theme
                                .colorScheme
                                .primary, // Dynamic color from current theme
                        child: Stack(
                          children: [
                            // 1. Main App Content (Respects SafeArea)
                            NotificationListener<ScrollNotification>(
                              onNotification: (notification) {
                                if (notification is ScrollUpdateNotification) {
                                  final velocity =
                                      notification.scrollDelta ?? 0;
                                  CyberGridBackground.updateScrollVelocity(
                                    velocity,
                                  );
                                }
                                return false;
                              },
                              child: SafeArea(bottom: false, child: child!),
                            ),

                            // 2. Premium Status Bar Overlay (Frosted Glass + Fade)
                            if (topPadding > 0)
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: topPadding,
                                child: ClipRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 12.0,
                                      sigmaY: 12.0,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            const Color(
                                              0xFF040506,
                                            ).withValues(alpha: 0.85),
                                            const Color(
                                              0xFF040506,
                                            ).withValues(alpha: 0.2),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
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
                  home: const SplashPage(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
