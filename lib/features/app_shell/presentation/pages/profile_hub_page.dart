import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:torcav/core/l10n/app_localizations.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../wifi_scan/domain/entities/scan_snapshot.dart';
import '../../../wifi_scan/domain/services/scan_session_store.dart';

class ProfileHubPage extends StatefulWidget {
  const ProfileHubPage({super.key});

  @override
  State<ProfileHubPage> createState() => _ProfileHubPageState();
}

class _ProfileHubPageState extends State<ProfileHubPage> {
  _NetworkStatus _networkStatus = const _NetworkStatus();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNetworkStatus();
  }

  Future<void> _loadNetworkStatus() async {
    try {
      final info = getIt<NetworkInfo>();
      final results = await Future.wait([
        info.getWifiName(),
        info.getWifiIP(),
        info.getWifiGatewayIP(),
      ]);

      if (!mounted) return;
      setState(() {
        _networkStatus = _NetworkStatus(
          ssid: _cleanSsid(results[0]),
          ip: _cleanValue(results[1]),
          gateway: _cleanValue(results[2]),
        );
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final latestSnapshot = getIt<ScanSessionStore>().latest;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: getIt<ThemeCubit>(),
      builder: (context, themeMode, _) {
        final statusLabel =
            _loading
                ? l10n.loading
                : _networkStatus.isConnected
                ? l10n.connectedStatusCaps
                : l10n.disconnectedStatusCaps;

        return Scaffold(
          appBar: AppBar(
            title: NeonText(
              l10n.profileTitle.toUpperCase(),
              style: GoogleFonts.orbitron(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              glowRadius: 8,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.account_circle_outlined,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      NeonText(
                        'TORCAV',
                        style: GoogleFonts.orbitron(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        statusLabel,
                        style: GoogleFonts.outfit(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildSectionHeader(context, l10n.sectionStatus),
                const SizedBox(height: 16),
                HolographicCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          l10n.activeSessionLabel,
                          statusLabel,
                          Icons.monitor_heart_outlined,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          context,
                          l10n.settingsLanguage,
                          _languageName(locale.languageCode),
                          Icons.language_outlined,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          context,
                          l10n.theme,
                          _themeName(themeMode, l10n),
                          Icons.palette_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(context, l10n.networkStatusLabel),
                const SizedBox(height: 16),
                HolographicCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          l10n.ssid,
                          _networkStatus.ssid ?? '—',
                          Icons.wifi_outlined,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          context,
                          l10n.ipLabel,
                          _networkStatus.ip ?? '—',
                          Icons.lan_outlined,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          context,
                          l10n.gatewayLabel,
                          _networkStatus.gateway ?? '—',
                          Icons.router_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(context, l10n.lastScanTitle),
                const SizedBox(height: 16),
                HolographicCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildSnapshotSummary(context, latestSnapshot),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSnapshotSummary(
    BuildContext context,
    ScanSnapshot? latestSnapshot,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (latestSnapshot == null) {
      return Text(
        'No scan snapshot is available yet. Run a Wi-Fi scan first.',
        style: GoogleFonts.outfit(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
      );
    }

    final locale = Localizations.localeOf(context);
    return Column(
      children: [
        _buildInfoRow(
          context,
          l10n.lastSnapshot,
          DateFormat.yMMMd(
            locale.languageCode,
          ).add_Hm().format(latestSnapshot.timestamp),
          Icons.history_rounded,
        ),
        const Divider(height: 24),
        _buildInfoRow(
          context,
          'Networks (${latestSnapshot.networks.length})',
          latestSnapshot.backendUsed.toUpperCase(),
          Icons.radar_outlined,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.orbitron(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 18, color: mutedColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.outfit(color: mutedColor, fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.outfit(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _languageName(String code) {
    return switch (code) {
      'tr' => 'Turkce',
      'ku' => 'Kurdi',
      'de' => 'Deutsch',
      _ => 'English',
    };
  }

  String _themeName(ThemeMode mode, AppLocalizations l10n) {
    return switch (mode) {
      ThemeMode.dark => l10n.darkTheme,
      ThemeMode.light => l10n.lightTheme,
      ThemeMode.system => l10n.systemTheme,
    };
  }

  String? _cleanSsid(String? raw) {
    final cleaned = _cleanValue(raw)?.replaceAll('"', '');
    if (cleaned == null) return null;
    if (cleaned.toLowerCase() == '<unknown ssid>') {
      return null;
    }
    return cleaned;
  }

  String? _cleanValue(String? raw) {
    if (raw == null) return null;
    final cleaned = raw.trim();
    return cleaned.isEmpty ? null : cleaned;
  }
}

class _NetworkStatus {
  final String? ssid;
  final String? ip;
  final String? gateway;

  const _NetworkStatus({this.ssid, this.ip, this.gateway});

  bool get isConnected => ssid != null || ip != null || gateway != null;
}
