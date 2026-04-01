import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../settings/domain/services/app_settings_store.dart';
import '../../domain/entities/band_analysis_stat.dart';
import '../../domain/entities/scan_request.dart';
import '../../domain/entities/scan_snapshot.dart';
import '../../domain/entities/wifi_network.dart';
import '../../domain/entities/wifi_observation.dart';
import '../bloc/wifi_scan_bloc.dart';
import '../widgets/wifi_scanner_radar.dart';
import '../../../../features/security/presentation/pages/wifi_details_page.dart';
import '../../../../features/monitoring/presentation/pages/channel_rating_page.dart';

/// Wrapper that provides the [WifiScanBloc] to the subtree.
class WifiScanPage extends StatelessWidget {
  const WifiScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final defaults = getIt<AppSettingsStore>().value;
    final initialRequest = ScanRequest(
      passes: defaults.defaultScanPasses,
      includeHidden: defaults.includeHiddenSsids,
      backendPreference: defaults.defaultBackendPreference,
    );

    return BlocProvider(
      create:
          (_) =>
              getIt<WifiScanBloc>()
                ..add(WifiScanStarted(request: initialRequest)),
      child: const _WifiScanView(),
    );
  }
}

class _WifiScanView extends StatefulWidget {
  const _WifiScanView();

  @override
  State<_WifiScanView> createState() => _WifiScanViewState();
}

class _WifiScanViewState extends State<_WifiScanView> {
  late int _passes;
  late bool _includeHidden;
  late WifiBackendPreference _backend;

  @override
  void initState() {
    super.initState();
    final defaults = getIt<AppSettingsStore>().value;
    _passes = defaults.defaultScanPasses;
    _includeHidden = defaults.includeHiddenSsids;
    _backend = defaults.defaultBackendPreference;
  }

  ScanRequest get _currentRequest => ScanRequest(
    passes: _passes,
    includeHidden: _includeHidden,
    backendPreference: _backend,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          // ── Loading state: radar always in tree, shown via Visibility ──
          // Keeping WifiScannerRadar permanently mounted prevents Flutter from
          // disposing its AnimationController when BLoC emits mid-scan, which
          // was the cause of the radar animation freezing.
          BlocBuilder<WifiScanBloc, WifiScanState>(
            buildWhen: (prev, next) =>
                (prev is WifiScanLoading) != (next is WifiScanLoading),
            builder: (context, state) {
              final isLoading = state is WifiScanLoading;
              return Visibility(
                visible: isLoading,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: false,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const WifiScannerRadar(isScanning: true),
                      const SizedBox(height: 48),
                      StaggeredEntry(
                        child: Column(
                          children: [
                            Text(
                              'INITIATING SPECTRUM SCAN',
                              style: GoogleFonts.orbitron(
                                color: AppColors.neonCyan,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'BROADCASTING PROBE REQUESTS...',
                              style: GoogleFonts.rajdhani(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Non-loading states ──
          BlocBuilder<WifiScanBloc, WifiScanState>(
            buildWhen: (prev, next) => next is! WifiScanLoading,
            builder: (context, state) {
              if (state is WifiScanLoading) return const SizedBox.shrink();
              if (state is WifiScanError) {
                return _ErrorView(
                  message: state.message,
                  onRetry: () {
                    context.read<WifiScanBloc>().add(
                      WifiScanStarted(request: _currentRequest),
                    );
                  },
                );
              }
              if (state is WifiScanLoaded) {
                return _SnapshotView(
                  snapshot: state.snapshot,
                  currentRequest: _currentRequest,
                );
              }
              return Center(
                child: NeonText(
                  l10n.readyToScan,
                  style: GoogleFonts.rajdhani(
                    color: AppColors.textMuted,
                    fontSize: 18,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Snapshot View ───────────────────────────────────────────────────

class _SnapshotView extends StatelessWidget {
  final ScanSnapshot snapshot;
  final ScanRequest currentRequest;

  const _SnapshotView({required this.snapshot, required this.currentRequest});

  @override
  Widget build(BuildContext context) {
    if (snapshot.networks.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeonGlowBox(
              glowColor: AppColors.neonCyan,
              child: Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: AppColors.neonCyan,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noSignalsDetected.toUpperCase(),
              style: GoogleFonts.orbitron(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "NO RADIOS EMITTING IN RANGE",
              style: GoogleFonts.rajdhani(
                color: AppColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.neonCyan,
      backgroundColor: AppColors.darkSurface,
      onRefresh: () async {
        context.read<WifiScanBloc>().add(const WifiScanRefreshed());
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // ── Bento Header ──
          _WifiBentoHeader(snapshot: snapshot),
          const SizedBox(height: 24),

          // ── Channel Rating Quick Link ──
          BlocBuilder<WifiScanBloc, WifiScanState>(
            builder: (context, state) {
              if (state is! WifiScanLoaded) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ChannelRatingLink(
                  snapshot: snapshot,
                  request: currentRequest,
                ),
              );
            },
          ),

          // ── Network Count Header ──
          NeonSectionHeader(
            label: AppLocalizations.of(
              context,
            )!.networksCount(snapshot.networks.length),
            icon: Icons.wifi_rounded,
            color: AppColors.neonCyan,
          ),
          const SizedBox(height: 12),

          // ── Network Grid ──
          ...snapshot.networks.asMap().entries.map(
            (entry) => StaggeredEntry(
              delay: Duration(milliseconds: 100 + entry.key * 40),
              child: _WifiNetworkCard(
                network: entry.value,
                interfaceName: snapshot.interfaceName,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wifi Bento Header ───────────────────────────────────────────────

class _WifiBentoHeader extends StatelessWidget {
  final ScanSnapshot snapshot;

  const _WifiBentoHeader({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    // Calculate band-specific blips for the radar
    final blips =
        snapshot.networks
            .map(
              (n) => (n.avgSignalDbm + 100) / 70.0,
            ) // Normalize signal to 0..1
            .toList();

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final double radarSize = constraints.maxWidth * 0.45;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Radar Column ──
                SizedBox(
                  width: radarSize,
                  height: radarSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      WifiScannerRadar(
                        isScanning: false,
                        blips: blips,
                        color: AppColors.neonCyan,
                      ),
                      // Center Icon
                      Icon(
                        Icons.settings_input_antenna_rounded,
                        color: AppColors.neonCyan.withValues(alpha: 0.5),
                        size: 24,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // ── Stats Grid ──
                Expanded(
                  child: SizedBox(
                    height: radarSize,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: BentoStatTile(
                                  label: 'Networks',
                                  value: '${snapshot.networks.length}',
                                  icon: Icons.wifi_find_rounded,
                                  color: AppColors.neonCyan,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: BentoStatTile(
                                  label: 'Security',
                                  value:
                                      '${snapshot.networks.where((n) => n.security != SecurityType.open).length}',
                                  icon: Icons.security_rounded,
                                  color: AppColors.neonGreen,
                                  subValue:
                                      '${snapshot.networks.where((n) => n.security == SecurityType.open).length} OPEN',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: BentoStatTile(
                                  label: 'Avg Signal',
                                  value:
                                      snapshot.networks.isEmpty
                                          ? 'N/A'
                                          : '${(snapshot.networks.map((n) => n.avgSignalDbm).reduce((a, b) => a + b) / snapshot.networks.length).round()}',
                                  icon: Icons.signal_wifi_4_bar_rounded,
                                  color: AppColors.neonPurple,
                                  subValue: 'DBM',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: BentoStatTile(
                                  label: 'Interface',
                                  value: snapshot.interfaceName.toUpperCase(),
                                  icon: Icons.lan_rounded,
                                  color: AppColors.neonOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        // ── Band Analysis Row ──
        if (snapshot.bandStats.isNotEmpty)
          SizedBox(
            height: 80,
            child: Row(
              children:
                  snapshot.bandStats.map((band) {
                    final isLast = snapshot.bandStats.last == band;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: isLast ? 0 : 8),
                        child: NeonCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          glowColor: _getBandColor(band.band),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                band.label,
                                style: GoogleFonts.orbitron(
                                  color: _getBandColor(band.band),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${band.networkCount} NETWORKS',
                                style: GoogleFonts.rajdhani(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
      ],
    );
  }

  Color _getBandColor(WifiBand band) {
    switch (band) {
      case WifiBand.ghz24:
        return AppColors.neonCyan;
      case WifiBand.ghz5:
        return AppColors.neonPurple;
      case WifiBand.ghz6:
        return AppColors.neonGreen;
    }
  }
}

// ── Wi-Fi Network Card ──────────────────────────────────────────────

class _WifiNetworkCard extends StatelessWidget {
  final WifiObservation network;
  final String interfaceName;

  const _WifiNetworkCard({required this.network, required this.interfaceName});

  Color get _signalColor {
    if (network.avgSignalDbm > -55) return AppColors.neonGreen;
    if (network.avgSignalDbm > -70) return AppColors.neonCyan;
    if (network.avgSignalDbm > -85) return AppColors.neonOrange;
    return AppColors.neonRed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeonCard(
        glowColor: _signalColor,
        glowIntensity: 0.08,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WifiDetailsPage(network: network.toWifiNetwork()),
            ),
          );
        },
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // ── Signal Pulse Indicator ──
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _signalColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: _signalColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    Icon(Icons.wifi_rounded, color: _signalColor, size: 20),
                    // High-tech signal bars
                    Positioned(
                      bottom: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(4, (index) {
                          final isActive =
                              (network.avgSignalDbm + 100) / 40 > (index / 4);
                          return Container(
                            width: 3,
                            height: 4 + (index * 2),
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              color:
                                  isActive
                                      ? _signalColor
                                      : _signalColor.withValues(alpha: 0.1),
                              boxShadow:
                                  isActive
                                      ? [
                                        BoxShadow(
                                          color: _signalColor.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 4,
                                        ),
                                      ]
                                      : null,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (network.ssid.isEmpty
                                ? l10n.hiddenNetwork
                                : network.ssid)
                            .toUpperCase(),
                        style: GoogleFonts.orbitron(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${network.vendor.toUpperCase()} • ${network.bssid}',
                        style: GoogleFonts.rajdhani(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    NeonText(
                      '${network.avgSignalDbm}',
                      style: GoogleFonts.orbitron(
                        color: _signalColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                      glowColor: _signalColor,
                      glowRadius: 6,
                    ),
                    Text(
                      'dBm',
                      style: GoogleFonts.rajdhani(
                        color: _signalColor.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              width: double.infinity,
              color: AppColors.glassWhite.withValues(alpha: 0.05),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MiniTechTag(
                  label: 'CH ${network.channel}',
                  icon: Icons.tag_rounded,
                  color: AppColors.neonCyan,
                ),
                const SizedBox(width: 8),
                _MiniTechTag(
                  label: '${network.frequency} MHz',
                  icon: Icons.waves_rounded,
                  color: AppColors.neonPurple,
                ),
                const SizedBox(width: 8),
                _MiniTechTag(
                  label: network.security.name.toUpperCase(),
                  icon:
                      network.security == SecurityType.open
                          ? Icons.lock_open_rounded
                          : Icons.lock_rounded,
                  color:
                      network.security == SecurityType.open
                          ? AppColors.neonRed
                          : AppColors.neonGreen,
                ),
                const Spacer(),
                Text(
                  'σ ${network.signalStdDev.toStringAsFixed(1)}',
                  style: GoogleFonts.rajdhani(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTechTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _MiniTechTag({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color.withValues(alpha: 0.8)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error View ──────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonRed.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonRed.withValues(alpha: 0.15),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.neonRed,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Channel Rating Quick Link ──────────────────────────────────────

class _ChannelRatingLink extends StatelessWidget {
  final ScanSnapshot snapshot;
  final ScanRequest request;

  const _ChannelRatingLink({required this.snapshot, required this.request});

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      glowColor: AppColors.neonPurple,
      glowIntensity: 0.1,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => ChannelRatingPage(
                  networks:
                      snapshot.networks.map((n) => n.toWifiNetwork()).toList(),
                  request: request,
                ),
          ),
        );
      },
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.neonPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_graph_rounded,
              color: AppColors.neonPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPECTRUM OPTIMIZATION',
                  style: GoogleFonts.orbitron(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Analyze channel congestion & interference',
                  style: GoogleFonts.rajdhani(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
