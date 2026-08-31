import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/notifications/app_notifier.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/locale_cubit.dart';
import '../../../../core/platform/battery_optimization.dart';
import '../../../../core/services/data_retention_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../performance/domain/services/scheduled_speed_probe.dart';
import '../../../monitoring/domain/services/background_monitor.dart';
import '../../../wifi_scan/domain/entities/scan_request.dart';
import 'package:torcav/core/storage/hive_storage_service.dart';
import '../../../app_shell/presentation/pages/onboarding_page.dart';
import 'privacy_policy_page.dart';
import 'package:torcav/core/settings/app_settings.dart';
import 'package:torcav/core/settings/app_settings_store.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AppSettingsStore _store = getIt<AppSettingsStore>();

  @override
  Widget build(BuildContext context) {
    final settings = _store.value;
    final l10n = context.l10n;
    final themeCubit = getIt<ThemeCubit>();

    return Scaffold(
      appBar: AppBar(
        title: NeonText(
          l10n.settingsTitle,
          style: GoogleFonts.orbitron(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          glowRadius: 8,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Appearance ──
          StaggeredEntry(
            delay: const Duration(milliseconds: 100),
            child: NeonSectionHeader(
              label: l10n.appearance,
              icon: Icons.palette_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 12),

          // Language
          StaggeredEntry(
            delay: const Duration(milliseconds: 150),
            child: BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) {
                return NeonCard(
                  glowColor: Theme.of(context).colorScheme.secondary,
                  glowIntensity: 0.04,
                  onTap: () => _showLanguageDialog(context),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      _NeonIconCircle(
                        icon: Icons.language_rounded,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.settingsLanguage,
                              style: GoogleFonts.rajdhani(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _getLanguageName(locale.languageCode, l10n),
                              style: GoogleFonts.rajdhani(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.4),
                        size: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Theme
          StaggeredEntry(
            delay: const Duration(milliseconds: 200),
            child: NeonCard(
              glowColor: Theme.of(context).colorScheme.primary,
              glowIntensity: 0.04,
              padding: const EdgeInsets.all(14),
              child: BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, mode) {
                  return Row(
                    children: [
                      _NeonIconCircle(
                        icon:
                            mode == ThemeMode.dark
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.theme,
                              style: GoogleFonts.rajdhani(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _getThemeName(mode, l10n),
                              style: GoogleFonts.rajdhani(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildThemeToggle(themeCubit),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Background Style
          StaggeredEntry(
            delay: const Duration(milliseconds: 250),
            child: NeonCard(
              glowColor: Theme.of(context).colorScheme.tertiary,
              glowIntensity: 0.04,
              onTap: () => _showBackgroundStyleDialog(context),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _NeonIconCircle(
                    icon: Icons.wallpaper_rounded,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settingsBackgroundStyle,
                          style: GoogleFonts.rajdhani(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _getBackgroundTypeName(settings.backgroundType, l10n),
                          style: GoogleFonts.rajdhani(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(
                      context,
                    ).colorScheme.tertiary.withValues(alpha: 0.4),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Scan Behavior ──
          StaggeredEntry(
            delay: const Duration(milliseconds: 300),
            child: NeonSectionHeader(
              label: l10n.settingsScanBehavior.toUpperCase(),
              icon: Icons.tune_rounded,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 12),
          StaggeredEntry(
            delay: const Duration(milliseconds: 350),
            child: NeonCard(
              glowColor: Theme.of(context).colorScheme.tertiary,
              glowIntensity: 0.04,
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // Passes Slider
                  _NeonSliderTile(
                    label: l10n.settingsDefaultScanPasses,
                    value: settings.defaultScanPasses.toDouble(),
                    min: 1,
                    max: 6,
                    divisions: 5,
                    displayValue: '${settings.defaultScanPasses}',
                    color: Theme.of(context).colorScheme.primary,
                    onChanged: (value) {
                      _update(
                        settings.copyWith(defaultScanPasses: value.round()),
                      );
                    },
                  ),
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                    height: 24,
                  ),
                  // Interval Slider
                  _NeonSliderTile(
                    label: l10n.settingsMonitoringInterval,
                    value: settings.scanIntervalSeconds.toDouble(),
                    min: 2,
                    max: 30,
                    divisions: 14,
                    displayValue: l10n.secondsCount(
                      settings.scanIntervalSeconds,
                    ),
                    color: Theme.of(context).colorScheme.secondary,
                    onChanged: (value) {
                      _update(
                        settings.copyWith(scanIntervalSeconds: value.round()),
                      );
                    },
                  ),
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                    height: 24,
                  ),
                  // Backend
                  DropdownButtonFormField<WifiBackendPreference>(
                    initialValue: settings.defaultBackendPreference,
                    dropdownColor:
                        Theme.of(context).colorScheme.surfaceContainerHigh,
                    decoration: InputDecoration(
                      labelText: l10n.settingsBackendPreference,
                    ),
                    items:
                        WifiBackendPreference.values
                            .map(
                              (backend) => DropdownMenuItem(
                                value: backend,
                                child: Text(
                                  backend.name.toUpperCase(),
                                  style: GoogleFonts.rajdhani(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      _update(
                        settings.copyWith(defaultBackendPreference: value),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  // Hidden SSIDs
                  SwitchListTile(
                    value: settings.includeHiddenSsids,
                    activeThumbColor: Theme.of(context).colorScheme.tertiary,
                    title: Text(
                      l10n.settingsIncludeHidden,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.settingsIncludeHiddenDesc,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    onChanged: (value) {
                      _update(settings.copyWith(includeHiddenSsids: value));
                    },
                  ),
                  // AI Classification
                  SwitchListTile(
                    value: settings.isAiEnabled,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    title: Text(
                      l10n.settingsAiClassification,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.settingsAiClassificationDesc,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    onChanged: (value) {
                      _update(settings.copyWith(isAiEnabled: value));
                    },
                  ),
                  // Auto-Scan
                  SwitchListTile(
                    value: settings.autoScanEnabled,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    title: Text(
                      l10n.autoScanLabel,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.autoScanDesc(settings.scanIntervalSeconds),
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    onChanged: (value) {
                      _update(settings.copyWith(autoScanEnabled: value));
                    },
                  ),
                  // Safety Mode
                  SwitchListTile(
                    value: settings.strictSafetyMode,
                    activeThumbColor: Theme.of(context).colorScheme.error,
                    title: Text(
                      l10n.settingsStrictSafety,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.settingsStrictSafetyDesc,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    onChanged: (value) {
                      _update(settings.copyWith(strictSafetyMode: value));
                    },
                  ),
                  // Deep Scan
                  SwitchListTile(
                    value: settings.isDeepScanEnabled,
                    activeThumbColor: Theme.of(context).colorScheme.error,
                    title: Text(
                      l10n.deepScanLabel,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.deepScanDesc,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    onChanged: (value) async {
                      if (value) {
                        final confirmed = await _confirmDeepScan(context);
                        if (!confirmed) return;
                      }
                      _update(settings.copyWith(isDeepScanEnabled: value));
                    },
                  ),
                  // Restrict deep scan on public networks
                  SwitchListTile(
                    value: settings.restrictDeepScanOnPublic,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    title: Text(
                      l10n.restrictDeepScanPublicLabel,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.restrictDeepScanPublicDesc,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    onChanged: (value) {
                      _update(
                        settings.copyWith(restrictDeepScanOnPublic: value),
                      );
                    },
                  ),
                  // Background monitoring (opt-in)
                  SwitchListTile(
                    value: settings.backgroundMonitoringEnabled,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    title: Text(
                      l10n.backgroundMonitoringLabel,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.backgroundMonitoringDesc,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    onChanged: (value) async {
                      _update(
                        settings.copyWith(backgroundMonitoringEnabled: value),
                      );
                      final monitor = getIt<BackgroundMonitor>();
                      if (!value) {
                        await monitor.stop();
                        return;
                      }
                      // Alerts ARE the feature: secure the Android 13+
                      // notification permission before scheduling work, and
                      // warn (not block) when the user declines.
                      final notifWarning =
                          l10n.backgroundMonitoringNotifWarning;
                      final granted =
                          await getIt<NotificationService>()
                              .requestAndroidNotificationPermission();
                      if (!granted) AppNotifier.warning(notifWarning);
                      // OEM battery managers kill scheduled work; ask for
                      // the exemption while the user's intent is explicit.
                      if (context.mounted) {
                        await BatteryOptimization.ensureExemption(context);
                      }
                      await monitor.start();
                    },
                  ),
                  // Scheduled background speed probe (opt-in)
                  SwitchListTile(
                    value: settings.scheduledSpeedTestEnabled,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    title: Text(
                      l10n.scheduledSpeedTestLabel,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.scheduledSpeedTestDesc,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    onChanged: (value) async {
                      _update(
                        settings.copyWith(scheduledSpeedTestEnabled: value),
                      );
                      final probe = getIt<ScheduledSpeedProbe>();
                      if (value) {
                        await probe.start();
                      } else {
                        await probe.stop();
                      }
                    },
                  ),
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                    height: 24,
                  ),
                  // Port scan timeout
                  _NeonSliderTile(
                    label: l10n.portScanTimeoutLabel,
                    value: settings.portScanTimeoutMs.toDouble(),
                    min: 200,
                    max: 2000,
                    divisions: 18,
                    displayValue: l10n.millisecondsCount(
                      settings.portScanTimeoutMs,
                    ),
                    color: Theme.of(context).colorScheme.tertiary,
                    onChanged: (value) {
                      _update(
                        settings.copyWith(portScanTimeoutMs: value.round()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Privacy & Data ──
          StaggeredEntry(
            delay: const Duration(milliseconds: 500),
            child: NeonSectionHeader(
              label: l10n.privacyAndDataLabel,
              icon: Icons.privacy_tip_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 12),
          StaggeredEntry(
            delay: const Duration(milliseconds: 550),
            child: NeonCard(
              glowColor: Theme.of(context).colorScheme.error,
              glowIntensity: 0.04,
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // Data Retention
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      l10n.dataRetentionLabel,
                      style: GoogleFonts.orbitron(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _NeonSliderTile(
                    label: l10n.scanHistoryRetentionLabel,
                    value: settings.scanHistoryRetentionDays.toDouble(),
                    min: 7,
                    max: 365,
                    divisions: 20,
                    displayValue:
                        settings.scanHistoryRetentionDays == 0
                            ? '∞'
                            : l10n.daysCount(settings.scanHistoryRetentionDays),
                    color: Theme.of(context).colorScheme.primary,
                    onChanged:
                        (v) => _update(
                          settings.copyWith(
                            scanHistoryRetentionDays: v.round(),
                          ),
                        ),
                  ),
                  _NeonSliderTile(
                    label: l10n.speedTestsRetentionLabel,
                    value: settings.speedTestRetentionDays.toDouble(),
                    min: 7,
                    max: 365,
                    divisions: 20,
                    displayValue: l10n.daysCount(
                      settings.speedTestRetentionDays,
                    ),
                    color: Theme.of(context).colorScheme.secondary,
                    onChanged:
                        (v) => _update(
                          settings.copyWith(speedTestRetentionDays: v.round()),
                        ),
                  ),
                  _NeonSliderTile(
                    label: l10n.securityEventsRetentionLabel,
                    value: settings.securityEventRetentionDays.toDouble(),
                    min: 7,
                    max: 365,
                    divisions: 20,
                    displayValue: l10n.daysCount(
                      settings.securityEventRetentionDays,
                    ),
                    color: Theme.of(context).colorScheme.error,
                    onChanged:
                        (v) => _update(
                          settings.copyWith(
                            securityEventRetentionDays: v.round(),
                          ),
                        ),
                  ),
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                    height: 16,
                  ),
                  ListTile(
                    leading: _NeonIconCircle(
                      icon: Icons.replay_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      l10n.replayOnboardingLabel,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.replayOnboardingDesc,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.6),
                      ),
                      onPressed: () => _replayOnboarding(context),
                    ),
                    onTap: () => _replayOnboarding(context),
                    contentPadding: EdgeInsets.zero,
                  ),
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                    height: 8,
                  ),
                  ListTile(
                    leading: _NeonIconCircle(
                      icon: Icons.delete_forever_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      l10n.wipeAllDataLabel,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.wipeAllDataDesc,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.6),
                      ),
                      onPressed: () => _confirmWipeAll(context),
                    ),
                    onTap: () => _confirmWipeAll(context),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── About ──
          StaggeredEntry(
            delay: const Duration(milliseconds: 600),
            child: NeonSectionHeader(
              label: l10n.aboutLabel,
              icon: Icons.info_outline_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 12),
          StaggeredEntry(
            delay: const Duration(milliseconds: 650),
            child: NeonCard(
              glowColor: Theme.of(context).colorScheme.secondary,
              glowIntensity: 0.04,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.legalDisclaimerTitle,
                    style: GoogleFonts.orbitron(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.legalDisclaimerBody,
                    style: GoogleFonts.outfit(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.65),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const Divider(height: 32, thickness: 0.5),
                  ListTile(
                    leading: Icon(
                      Icons.privacy_tip_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: Text(
                      l10n.privacyPolicyTitle.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyPage(),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _replayOnboarding(BuildContext context) async {
    final navigator = Navigator.of(context);
    await getIt<HiveStorageService>().save(
      OnboardingPage.completionKey,
      false,
    );
    unawaited(
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => const OnboardingPage(),
        ),
      ),
    );
  }

  Future<bool> _confirmDeepScan(BuildContext context) async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Theme.of(ctx).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              l10n.enableDeepScanTitle,
              style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(ctx).colorScheme.error,
              ),
            ),
            content: Text(
              l10n.enableDeepScanBody,
              style: GoogleFonts.rajdhani(
                color: Theme.of(ctx).colorScheme.onSurface,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  l10n.cancel,
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  l10n.understandEnable,
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    color: Theme.of(ctx).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  Future<void> _confirmWipeAll(BuildContext context) async {
    // Capture l10n before async gap to satisfy use_build_context_synchronously.
    final allDataWipedMsg = context.l10n.allDataWiped;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Theme.of(ctx).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              context.l10n.wipeAllDialogTitle,
              style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(ctx).colorScheme.error,
              ),
            ),
            content: Text(
              context.l10n.wipeAllDialogBody,
              style: GoogleFonts.rajdhani(fontSize: 14, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  context.l10n.cancel,
                  style: GoogleFonts.orbitron(fontSize: 10),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  context.l10n.wipeAllAction,
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    color: Theme.of(ctx).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) return;

    // One call: DataRetentionService owns the full list of stores, so a new
    // one cannot be added without this screen deleting it too.
    await getIt<DataRetentionService>().wipeAllUserData();

    if (!mounted) return;
    // Destructive completion — warning severity (turuncu) for emphasis.
    AppNotifier.warning(allDataWipedMsg);
  }

  Widget _buildThemeToggle(ThemeCubit themeCubit) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _themeButton(
            icon: Icons.dark_mode_rounded,
            isSelected: themeCubit.state == ThemeMode.dark,
            onTap: () => themeCubit.setTheme(ThemeMode.dark),
          ),
          _themeButton(
            icon: Icons.light_mode_rounded,
            isSelected: themeCubit.state == ThemeMode.light,
            onTap: () => themeCubit.setTheme(ThemeMode.light),
          ),
          _themeButton(
            icon: Icons.brightness_auto_rounded,
            isSelected: themeCubit.state == ThemeMode.system,
            onTap: () => themeCubit.setTheme(ThemeMode.system),
          ),
        ],
      ),
    );
  }

  Widget _themeButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ]
                  : [],
        ),
        child: Icon(
          icon,
          size: 18,
          color:
              isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _getThemeName(ThemeMode mode, AppLocalizations l10n) {
    return switch (mode) {
      ThemeMode.dark => l10n.darkTheme,
      ThemeMode.light => l10n.lightTheme,
      ThemeMode.system => l10n.systemTheme,
    };
  }

  String _getLanguageName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'tr':
        return l10n.languageTurkish;
      case 'ku':
        return l10n.languageKurdish;
      case 'de':
        return l10n.languageGerman;
      case 'en':
      default:
        return l10n.languageEnglish;
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.15),
            ),
          ),
          title: NeonText(
            AppLocalizations.of(context)!.settingsLanguage,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              color: Theme.of(context).colorScheme.secondary,
            ),
            glowRadius: 4,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageOption(
                label: l10n.languageEnglish,
                locale: const Locale('en'),
              ),
              _LanguageOption(
                label: l10n.languageTurkish,
                locale: const Locale('tr'),
              ),
              _LanguageOption(
                label: l10n.languageKurdish,
                locale: const Locale('ku'),
              ),
              _LanguageOption(
                label: l10n.languageGerman,
                locale: const Locale('de'),
              ),
              _SystemLanguageOption(),
            ],
          ),
        );
      },
    );
  }

  void _showBackgroundStyleDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.tertiary.withValues(alpha: 0.15),
            ),
          ),
          title: NeonText(
            l10n.settingsBackgroundStyle,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            glowRadius: 4,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BackgroundOption(
                label: l10n.backgroundAegisShield,
                type: AppBackgroundType.aegisShield,
                onSelected: (type) {
                  _update(_store.value.copyWith(backgroundType: type));
                  Navigator.pop(context);
                },
              ),
              _BackgroundOption(
                label: l10n.backgroundSignalTopography,
                type: AppBackgroundType.signalTopography,
                onSelected: (type) {
                  _update(_store.value.copyWith(backgroundType: type));
                  Navigator.pop(context);
                },
              ),
              _BackgroundOption(
                label: l10n.backgroundQuantumMesh,
                type: AppBackgroundType.quantumMesh,
                onSelected: (type) {
                  _update(_store.value.copyWith(backgroundType: type));
                  Navigator.pop(context);
                },
              ),
              _BackgroundOption(
                label: l10n.backgroundNeomorphic,
                type: AppBackgroundType.neomorphic,
                onSelected: (type) {
                  _update(_store.value.copyWith(backgroundType: type));
                  Navigator.pop(context);
                },
              ),
              _BackgroundOption(
                label: l10n.backgroundClassic,
                type: AppBackgroundType.classic,
                onSelected: (type) {
                  _update(_store.value.copyWith(backgroundType: type));
                  Navigator.pop(context);
                },
              ),
              _BackgroundOption(
                label: l10n.backgroundAuroraMesh,
                type: AppBackgroundType.auroraMesh,
                onSelected: (type) {
                  _update(_store.value.copyWith(backgroundType: type));
                  Navigator.pop(context);
                },
              ),
              _BackgroundOption(
                label: l10n.backgroundHoloSphere,
                type: AppBackgroundType.holoSphere,
                onSelected: (type) {
                  _update(_store.value.copyWith(backgroundType: type));
                  Navigator.pop(context);
                },
              ),
              _BackgroundOption(
                label: l10n.backgroundNeuralPulse,
                type: AppBackgroundType.neuralPulse,
                onSelected: (type) {
                  _update(_store.value.copyWith(backgroundType: type));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getBackgroundTypeName(AppBackgroundType type, AppLocalizations l10n) {
    return switch (type) {
      AppBackgroundType.neomorphic => l10n.backgroundNeomorphic,
      AppBackgroundType.classic => l10n.backgroundClassic,
      AppBackgroundType.auroraMesh => l10n.backgroundAuroraMesh,
      AppBackgroundType.holoSphere => l10n.backgroundHoloSphere,
      AppBackgroundType.neuralPulse => l10n.backgroundNeuralPulse,
      AppBackgroundType.aegisShield => l10n.backgroundAegisShield,
      AppBackgroundType.signalTopography => l10n.backgroundSignalTopography,
      AppBackgroundType.quantumMesh => l10n.backgroundQuantumMesh,
    };
  }

  void _update(AppSettings settings) {
    setState(() => _store.update(settings));
  }
}

// ── Neon Icon Circle ────────────────────────────────────────────────

class _NeonIconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _NeonIconCircle({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 10),
        ],
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

// ── Neon Slider Tile ────────────────────────────────────────────────

class _NeonSliderTile extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final Color color;
  final ValueChanged<double> onChanged;

  const _NeonSliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.rajdhani(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            NeonChip(label: displayValue, color: color),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.15),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// ── System Language Option ───────────────────────────────────────────

class _SystemLanguageOption extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.read<LocaleCubit>().detectAndApplySystemLocale();
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.systemDefault,
                  style: GoogleFonts.rajdhani(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.phone_android_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Language Option ─────────────────────────────────────────────────

class _LanguageOption extends StatelessWidget {
  final String label;
  final Locale locale;

  const _LanguageOption({required this.label, required this.locale});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    final isSelected = currentLocale.languageCode == locale.languageCode;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.read<LocaleCubit>().setLocale(locale);
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color:
                  isSelected
                      ? secondary.withValues(alpha: 0.1)
                      : Colors.transparent,
              border:
                  isSelected
                      ? Border.all(color: secondary.withValues(alpha: 0.3))
                      : null,
            ),
            child: Row(
              children: [
                Text(
                  label,
                  style: GoogleFonts.rajdhani(
                    color:
                        isSelected
                            ? secondary
                            : Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: secondary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Background Option ────────────────────────────────────────────────

class _BackgroundOption extends StatelessWidget {
  final String label;
  final AppBackgroundType type;
  final ValueChanged<AppBackgroundType> onSelected;

  const _BackgroundOption({
    required this.label,
    required this.type,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final settingsStore = getIt<AppSettingsStore>();
    final isSelected = settingsStore.value.backgroundType == type;
    final tertiary = Theme.of(context).colorScheme.tertiary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSelected(type),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color:
                  isSelected
                      ? tertiary.withValues(alpha: 0.1)
                      : Colors.transparent,
              border:
                  isSelected
                      ? Border.all(color: tertiary.withValues(alpha: 0.3))
                      : null,
            ),
            child: Row(
              children: [
                Text(
                  label,
                  style: GoogleFonts.rajdhani(
                    color:
                        isSelected
                            ? tertiary
                            : Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: tertiary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
