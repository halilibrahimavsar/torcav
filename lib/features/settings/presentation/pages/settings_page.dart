import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Control default scan behavior, backend strategy, and safety posture.',
          style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 17),
        ),
        const SizedBox(height: 14),
        _card(
          child: Column(
            children: [
              ListTile(
                title: const Text('Default scan passes'),
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
                title: const Text('Monitoring interval (seconds)'),
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
                decoration: const InputDecoration(
                  labelText: 'Default backend preference',
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
                title: const Text('Include hidden SSIDs by default'),
                onChanged: (value) {
                  _update(settings.copyWith(includeHiddenSsids: value));
                },
              ),
              SwitchListTile(
                value: settings.strictSafetyMode,
                title: const Text('Strict safety mode'),
                subtitle: const Text(
                  'Require consent + allowlist for active ops',
                ),
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
