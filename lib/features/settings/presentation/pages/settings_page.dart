import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/i18n/locale_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../wifi_scan/domain/entities/scan_request.dart';
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
          'SETTINGS',
          style: GoogleFonts.orbitron(
            color: AppColors.neonCyan,
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
              label: 'APPEARANCE',
              icon: Icons.palette_rounded,
              color: AppColors.neonPurple,
            ),
          ),
          const SizedBox(height: 12),

          // Language
          StaggeredEntry(
            delay: const Duration(milliseconds: 150),
            child: BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) {
                return NeonCard(
                  glowColor: AppColors.neonPurple,
                  glowIntensity: 0.04,
                  onTap: () => _showLanguageDialog(context),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      _NeonIconCircle(
                        icon: Icons.language_rounded,
                        color: AppColors.neonPurple,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.settingsLanguage,
                              style: GoogleFonts.rajdhani(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _getLanguageName(locale.languageCode),
                              style: GoogleFonts.rajdhani(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.neonPurple.withValues(alpha: 0.4),
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
              glowColor: AppColors.neonCyan,
              glowIntensity: 0.04,
              padding: const EdgeInsets.all(14),
              child: ValueListenableBuilder<ThemeMode>(
                valueListenable: themeCubit,
                builder: (context, mode, _) {
                  return Row(
                    children: [
                      _NeonIconCircle(
                        icon: mode == ThemeMode.dark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: AppColors.neonCyan,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Theme',
                              style: GoogleFonts.rajdhani(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _getThemeName(mode),
                              style: GoogleFonts.rajdhani(
                                color: AppColors.textMuted,
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
          const SizedBox(height: 24),

          // ── Scan Behavior ──
          StaggeredEntry(
            delay: const Duration(milliseconds: 300),
            child: NeonSectionHeader(
              label: l10n.settingsScanBehavior.toUpperCase(),
              icon: Icons.tune_rounded,
              color: AppColors.neonGreen,
            ),
          ),
          const SizedBox(height: 12),
          StaggeredEntry(
            delay: const Duration(milliseconds: 350),
            child: NeonCard(
              glowColor: AppColors.neonGreen,
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
                    color: AppColors.neonCyan,
                    onChanged: (value) {
                      _update(
                        settings.copyWith(defaultScanPasses: value.round()),
                      );
                    },
                  ),
                  const Divider(
                    color: AppColors.glassWhite,
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
                    color: AppColors.neonPurple,
                    onChanged: (value) {
                      _update(
                        settings.copyWith(
                          scanIntervalSeconds: value.round(),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    color: AppColors.glassWhite,
                    height: 24,
                  ),
                  // Backend
                  DropdownButtonFormField<WifiBackendPreference>(
                    value: settings.defaultBackendPreference,
                    dropdownColor: AppColors.darkSurface,
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
                                    color: AppColors.textPrimary,
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
                    activeColor: AppColors.neonGreen,
                    title: Text(
                      l10n.settingsIncludeHidden,
                      style: GoogleFonts.rajdhani(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onChanged: (value) {
                      _update(settings.copyWith(includeHiddenSsids: value));
                    },
                  ),
                  // Safety Mode
                  SwitchListTile(
                    value: settings.strictSafetyMode,
                    activeColor: AppColors.neonOrange,
                    title: Text(
                      l10n.settingsStrictSafety,
                      style: GoogleFonts.rajdhani(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.settingsStrictSafetyDesc,
                      style: GoogleFonts.rajdhani(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    onChanged: (value) {
                      _update(settings.copyWith(strictSafetyMode: value));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(ThemeCubit themeCubit) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _themeButton(
            icon: Icons.dark_mode_rounded,
            isSelected: themeCubit.value == ThemeMode.dark,
            onTap: () => themeCubit.setTheme(ThemeMode.dark),
          ),
          _themeButton(
            icon: Icons.light_mode_rounded,
            isSelected: themeCubit.value == ThemeMode.light,
            onTap: () => themeCubit.setTheme(ThemeMode.light),
          ),
          _themeButton(
            icon: Icons.brightness_auto_rounded,
            isSelected: themeCubit.value == ThemeMode.system,
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
          color: isSelected
              ? AppColors.neonCyan
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? AppColors.darkBg : AppColors.textMuted,
        ),
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.dark => 'Dark',
      ThemeMode.light => 'Light',
      ThemeMode.system => 'System',
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
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: AppColors.neonPurple.withValues(alpha: 0.15),
            ),
          ),
          title: NeonText(
            AppLocalizations.of(context)!.settingsLanguage,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              color: AppColors.neonPurple,
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
              _LanguageOption(
                label: 'Türkçe 🇹🇷',
                locale: const Locale('tr'),
              ),
              _LanguageOption(
                label: 'Kurdî ☀️',
                locale: const Locale('ku'),
              ),
              _LanguageOption(
                label: 'Deutsch 🇩🇪',
                locale: const Locale('de'),
              ),
            ],
          ),
        );
      },
    );
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
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 10,
          ),
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
                  color: AppColors.textPrimary,
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

// ── Language Option ─────────────────────────────────────────────────

class _LanguageOption extends StatelessWidget {
  final String label;
  final Locale locale;

  const _LanguageOption({required this.label, required this.locale});

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    final isSelected = currentLocale.languageCode == locale.languageCode;

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
              color: isSelected
                  ? AppColors.neonPurple.withValues(alpha: 0.1)
                  : Colors.transparent,
              border: isSelected
                  ? Border.all(
                      color: AppColors.neonPurple.withValues(alpha: 0.3),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Text(
                  label,
                  style: GoogleFonts.rajdhani(
                    color: isSelected
                        ? AppColors.neonPurple
                        : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.neonPurple,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
