import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/locale_cubit.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../performance/domain/repositories/speed_test_history_repository.dart';
import '../../../security/data/datasources/security_local_data_source.dart';
import '../../../wifi_scan/data/datasources/channel_rating_local_data_source.dart';
import '../../../wifi_scan/data/datasources/wifi_scan_history_local_data_source.dart';
import '../../../wifi_scan/domain/entities/scan_request.dart';
import '../../../wifi_scan/domain/services/scan_session_store.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/services/app_settings_store.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
                              _getLanguageName(locale.languageCode),
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
                    displayValue: '${settings.scanIntervalSeconds}s',
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
                    value: settings.defaultBackendPreference,
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
                    activeColor: Theme.of(context).colorScheme.tertiary,
                    title: Text(
                      l10n.settingsIncludeHidden,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Actively probes for hidden SSIDs. '
                      'Off by default — only enable on networks you own.',
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
                    activeColor: Theme.of(context).colorScheme.primary,
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
                    activeColor: Theme.of(context).colorScheme.primary,
                    title: Text(
                      'Auto-Scan',
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Repeat scan every ${settings.scanIntervalSeconds}s automatically',
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
                    activeColor: Theme.of(context).colorScheme.error,
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
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                    height: 24,
                  ),
                  // Port scan timeout
                  _NeonSliderTile(
                    label: 'Port Scan Timeout',
                    value: settings.portScanTimeoutMs.toDouble(),
                    min: 200,
                    max: 2000,
                    divisions: 18,
                    displayValue: '${settings.portScanTimeoutMs} ms',
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
              label: 'PRIVACY & DATA',
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
                  ListTile(
                    leading: _NeonIconCircle(
                      icon: Icons.delete_forever_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      'Wipe All Local Data',
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Deletes all scan history, speed tests, security events '
                      'and channel ratings from this device.',
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
        ],
      ),
    );
  }

  Future<void> _confirmWipeAll(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Theme.of(ctx).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'WIPE ALL DATA',
              style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(ctx).colorScheme.error,
              ),
            ),
            content: Text(
              'This will permanently delete all local scan history, speed test '
              'records, security events, channel ratings and in-memory snapshots. '
              'This action cannot be undone.',
              style: GoogleFonts.rajdhani(fontSize: 14, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'CANCEL',
                  style: GoogleFonts.orbitron(fontSize: 10),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'WIPE ALL',
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

    // Clear in-memory session store and all persisted data.
    getIt<ScanSessionStore>().clear();
    await Future.wait([
      getIt<SpeedTestHistoryRepository>().deleteAll(),
      getIt<SecurityLocalDataSource>().clearAllSecurityEvents(),
      getIt<ChannelRatingLocalDataSource>().clearHistory(),
      getIt<WifiScanHistoryLocalDataSource>().clear(),
    ]);

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'All local data wiped.',
          style: GoogleFonts.rajdhani(fontWeight: FontWeight.w600),
        ),
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  String _getLanguageName(String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'ku':
        return 'Kurdî';
      case 'de':
        return 'Deutsch';
      case 'en':
      default:
        return 'English';
    }
  }

  void _showLanguageDialog(BuildContext context) {
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
                label: 'English 🇺🇸',
                locale: const Locale('en'),
              ),
              _LanguageOption(label: 'Türkçe 🇹🇷', locale: const Locale('tr')),
              _LanguageOption(label: 'Kurdî ☀️', locale: const Locale('ku')),
              _LanguageOption(
                label: 'Deutsch 🇩🇪',
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
                  'System Default',
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
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w600,
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
