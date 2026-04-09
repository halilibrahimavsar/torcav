import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../settings/domain/services/app_settings_store.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../domain/entities/scan_request.dart';
import '../../domain/entities/scan_snapshot.dart';
import '../bloc/wifi_scan_bloc.dart';
import '../../domain/services/scan_session_store.dart';
import '../widgets/channel_rating_link.dart';
import '../widgets/recommendation_banner.dart';
import '../widgets/scan_filter_state.dart';
import '../widgets/scan_mode_toggle.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/wifi_bento_header.dart';
import '../widgets/wifi_network_card.dart';
import '../widgets/wifi_scan_error_view.dart';
import '../widgets/wifi_scanner_radar.dart';
import 'scan_comparison_page.dart';

/// Wrapper that provides the [WifiScanBloc] to the subtree.
class WifiScanPage extends StatelessWidget {
  const WifiScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = getIt<AppSettingsStore>().value;
    final initialRequest = ScanRequest(
      passes: settings.isDeepScanEnabled ? settings.defaultScanPasses : 1,
      includeHidden: settings.includeHiddenSsids,
      backendPreference: settings.defaultBackendPreference,
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
  Timer? _autoScanTimer;
  StreamSubscription<AppSettings>? _settingsSub;

  @override
  void initState() {
    super.initState();
    final store = getIt<AppSettingsStore>();
    _setupAutoScan(store.value);
    _settingsSub = store.changes.listen(_onSettingsChanged);
  }

  void _onSettingsChanged(AppSettings settings) {
    _setupAutoScan(settings);
    if (mounted) setState(() {});
  }

  void _setupAutoScan(AppSettings settings) {
    _autoScanTimer?.cancel();
    if (settings.autoScanEnabled && settings.scanIntervalSeconds > 0) {
      _autoScanTimer = Timer.periodic(
        Duration(seconds: settings.scanIntervalSeconds),
        (_) {
          if (mounted) {
            context.read<WifiScanBloc>().add(
              WifiScanRefreshed(request: _currentRequest),
            );
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _autoScanTimer?.cancel();
    _settingsSub?.cancel();
    super.dispose();
  }

  ScanRequest get _currentRequest {
    final settings = getIt<AppSettingsStore>().value;
    return ScanRequest(
      passes: settings.isDeepScanEnabled ? settings.defaultScanPasses : 1,
      includeHidden: settings.includeHiddenSsids,
      backendPreference: settings.defaultBackendPreference,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BlocBuilder<WifiScanBloc, WifiScanState>(
            builder: (context, state) {
              final isLoading = state is WifiScanLoading;

              return Stack(
                children: [
                  // ── Initial Loading state (no data yet) ──
                  if (isLoading)
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 120,
                            height: 120,
                            child: WifiScannerRadar(isScanning: true),
                          ),
                          const SizedBox(height: 48),
                          StaggeredEntry(
                            child: Column(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.initiatingSpectrumScan,
                                  style: GoogleFonts.orbitron(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context)!.broadcastingProbeRequests,
                                  style: GoogleFonts.rajdhani(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

                  // ── Non-loading states ──
                  if (!isLoading)
                    if (state is WifiScanError)
                      WifiScanErrorView(
                        message: state.message,
                        onRetry: () {
                          context.read<WifiScanBloc>().add(
                            WifiScanStarted(request: _currentRequest),
                          );
                        },
                      )
                    else if (state is WifiScanLoaded)
                      _SnapshotView(
                        snapshot: state.snapshot,
                        currentRequest: _currentRequest,
                        pinnedBssids: state.pinnedBssids,
                        isRefreshing: state.isRefreshing,
                      )
                    else
                      Center(
                        child: NeonText(
                          l10n.readyToScan,
                          style: GoogleFonts.rajdhani(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 18,
                          ),
                        ),
                      ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Snapshot View ────────────────────────────────────────────────────

class _SnapshotView extends StatefulWidget {
  final ScanSnapshot snapshot;
  final ScanRequest currentRequest;
  final Set<String> pinnedBssids;
  final bool isRefreshing;

  const _SnapshotView({
    required this.snapshot,
    required this.currentRequest,
    this.pinnedBssids = const {},
    this.isRefreshing = false,
  });

  @override
  State<_SnapshotView> createState() => _SnapshotViewState();
}

class _SnapshotViewState extends State<_SnapshotView> {
  ScanFilterState _filter = const ScanFilterState();
  final _searchController = TextEditingController();
  bool _showRecommendation = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerRescan(BuildContext context) {
    final settings = getIt<AppSettingsStore>().value;
    final request = ScanRequest(
      passes: settings.isDeepScanEnabled ? settings.defaultScanPasses : 1,
      includeHidden: settings.includeHiddenSsids,
      backendPreference: settings.defaultBackendPreference,
    );
    context.read<WifiScanBloc>().add(WifiScanStarted(request: request));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.snapshot.networks.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeonGlowBox(
              glowColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noSignalsDetected.toUpperCase(),
              style: GoogleFonts.orbitron(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noRadiosInRange,
              style: GoogleFonts.rajdhani(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final filtered = ScanFilterState.apply(
      widget.snapshot.networks,
      _filter,
      pinned: widget.pinnedBssids,
    );

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      onRefresh: () async {
        context.read<WifiScanBloc>().add(const WifiScanRefreshed());
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // ── Bento Header ──
          WifiBentoHeader(
            snapshot: widget.snapshot,
            isRefreshing: widget.isRefreshing,
          ),
          const SizedBox(height: 12),

          // ── Compare Button ──
          if (getIt<ScanSessionStore>().all.length >= 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.compare_arrows_rounded, size: 16),
                label: Text(
                  AppLocalizations.of(context)!.compareWithPreviousScan,
                  style: GoogleFonts.orbitron(fontSize: 11, letterSpacing: 1),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                  ),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ScanComparisonPage(),
                  ),
                ),
              ),
            ),

          // ── Auto-Recommendation Banner ──
          if (_showRecommendation)
            RecommendationBanner(
              snapshot: widget.snapshot,
              onDismiss: () => setState(() => _showRecommendation = false),
            ),
          const SizedBox(height: 12),

          // ── Channel Rating Quick Link ──
          BlocBuilder<WifiScanBloc, WifiScanState>(
            builder: (context, state) {
              if (state is! WifiScanLoaded) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ChannelRatingLink(
                  snapshot: widget.snapshot,
                  request: widget.currentRequest,
                ),
              );
            },
          ),

          // ── Quick / Deep Scan Toggle ──
          ScanModeToggle(
            quickScan: !getIt<AppSettingsStore>().value.isDeepScanEnabled,
            onChanged: (isQuick) {
              final store = getIt<AppSettingsStore>();
              store.update(store.value.copyWith(isDeepScanEnabled: !isQuick));
              _triggerRescan(context);
            },
          ),
          const SizedBox(height: 8),

          // ── Search & Filter Bar ──
          SearchFilterBar(
            controller: _searchController,
            filter: _filter,
            onFilterChanged: (f) => setState(() => _filter = f),
          ),
          const SizedBox(height: 12),

          // ── Network Count Header ──
          NeonSectionHeader(
            label: filtered.length == widget.snapshot.networks.length
                ? AppLocalizations.of(context)!.networksCount(filtered.length)
                : AppLocalizations.of(context)!.filteredNetworksCount(filtered.length, widget.snapshot.networks.length),
            icon: Icons.wifi_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),

          // ── Network Grid ──
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.noNetworksMatchFilter,
                  style: GoogleFonts.rajdhani(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 15,
                  ),
                ),
              ),
            )
          else
            ...filtered.asMap().entries.map(
              (entry) => StaggeredEntry(
                delay: Duration(milliseconds: 40 * entry.key.clamp(0, 20)),
                child: WifiNetworkCard(
                  network: entry.value,
                  interfaceName: widget.snapshot.interfaceName,
                  isPinned: widget.pinnedBssids.contains(entry.value.bssid),
                  onTogglePin: () => context.read<WifiScanBloc>().add(
                    WifiScanToggleFavorite(entry.value.bssid),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
