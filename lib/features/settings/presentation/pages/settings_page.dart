import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/i18n/locale_cubit.dart';
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
        Text(
          l10n.settingsScanBehavior,
          style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 17),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: child,
    );
  }
}
