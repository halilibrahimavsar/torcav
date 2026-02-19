import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/i18n/locale_cubit.dart';
import '../../../../core/theme/app_theme.dart';
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
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return _card(
              child: ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.settingsLanguage),
                subtitle: Text(_getLanguageName(locale.languageCode)),
                onTap: () => _showLanguageDialog(context),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        _card(
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: themeCubit,
            builder: (context, mode, _) {
              return ListTile(
                leading: Icon(
                  mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                ),
                title: const Text('Theme'),
                subtitle: Text(_getThemeName(mode)),
                trailing: _buildThemeToggle(themeCubit),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Text(
          l10n.settingsScanBehavior,
          style: GoogleFonts.rajdhani(
            color: onSurface.withValues(alpha: 0.82),
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 14),
        _card(
          child: Column(
            children: [
              ListTile(
                title: Text(l10n.settingsDefaultScanPasses),
                subtitle: Slider(
                  value: settings.defaultScanPasses.toDouble(),
                  min: 1,
                  max: 6,
                  divisions: 5,
                  label: '${settings.defaultScanPasses}',
                  onChanged: (value) {
                    _update(
                      settings.copyWith(defaultScanPasses: value.round()),
                    );
                  },
                ),
              ),
              ListTile(
                title: Text(l10n.settingsMonitoringInterval),
                subtitle: Slider(
                  value: settings.scanIntervalSeconds.toDouble(),
                  min: 2,
                  max: 30,
                  divisions: 14,
                  label: '${settings.scanIntervalSeconds}s',
                  onChanged: (value) {
                    _update(
                      settings.copyWith(scanIntervalSeconds: value.round()),
                    );
                  },
                ),
              ),
              DropdownButtonFormField<WifiBackendPreference>(
                value: settings.defaultBackendPreference,
                decoration: InputDecoration(
                  labelText: l10n.settingsBackendPreference,
                ),
                items:
                    WifiBackendPreference.values
                        .map(
                          (backend) => DropdownMenuItem(
                            value: backend,
                            child: Text(backend.name.toUpperCase()),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  _update(settings.copyWith(defaultBackendPreference: value));
                },
              ),
              SwitchListTile(
                value: settings.includeHiddenSsids,
                title: Text(l10n.settingsIncludeHidden),
                onChanged: (value) {
                  _update(settings.copyWith(includeHiddenSsids: value));
                },
              ),
              SwitchListTile(
                value: settings.strictSafetyMode,
                title: Text(l10n.settingsStrictSafety),
                subtitle: Text(l10n.settingsStrictSafetyDesc),
                onChanged: (value) {
                  _update(settings.copyWith(strictSafetyMode: value));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeToggle(ThemeCubit themeCubit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      decoration: BoxDecoration(
        color:
            isDark
                ? AppTheme.darkSurface
                : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _themeButton(
            icon: Icons.dark_mode,
            isSelected: themeCubit.value == ThemeMode.dark,
            onTap: () => themeCubit.setTheme(ThemeMode.dark),
            unselectedColor: onSurface.withValues(alpha: 0.7),
          ),
          _themeButton(
            icon: Icons.light_mode,
            isSelected: themeCubit.value == ThemeMode.light,
            onTap: () => themeCubit.setTheme(ThemeMode.light),
            unselectedColor: onSurface.withValues(alpha: 0.7),
          ),
          _themeButton(
            icon: Icons.brightness_auto,
            isSelected: themeCubit.value == ThemeMode.system,
            onTap: () => themeCubit.setTheme(ThemeMode.system),
            unselectedColor: onSurface.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _themeButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color unselectedColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.black : unselectedColor,
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
        return SimpleDialog(
          title: Text(AppLocalizations.of(context)!.settingsLanguage),
          children: [
            SimpleDialogOption(
              onPressed: () {
                context.read<LocaleCubit>().setLocale(const Locale('en'));
                Navigator.pop(context);
              },
              child: const Text('English 🇺🇸'),
            ),
            SimpleDialogOption(
              onPressed: () {
                context.read<LocaleCubit>().setLocale(const Locale('tr'));
                Navigator.pop(context);
              },
              child: const Text('Türkçe 🇹🇷'),
            ),
            SimpleDialogOption(
              onPressed: () {
                context.read<LocaleCubit>().setLocale(const Locale('ku'));
                Navigator.pop(context);
              },
              child: const Text('Kurdî ☀️'),
            ),
            SimpleDialogOption(
              onPressed: () {
                context.read<LocaleCubit>().setLocale(const Locale('de'));
                Navigator.pop(context);
              },
              child: const Text('Deutsch 🇩🇪'),
            ),
          ],
        );
      },
    );
  }

  void _update(AppSettings settings) {
    setState(() => _store.update(settings));
  }

  Widget _card({required Widget child}) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: onSurface.withValues(alpha: 0.2)),
      ),
      child: child,
    );
  }
}
