import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/prominent_disclosure_dialog.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import 'package:torcav/core/settings/app_settings_store.dart';
import 'package:torcav/core/settings/app_settings.dart';
import '../../domain/entities/scan_request.dart';
import '../../domain/entities/scan_snapshot.dart';
import '../bloc/wifi_scan_bloc.dart';
import '../../domain/services/scan_session_store.dart';
import '../widgets/recommendation_banner.dart';
import '../widgets/scan_filter_state.dart';
import '../widgets/scan_mode_toggle.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/wifi_bento_header.dart';
import '../widgets/wifi_network_card.dart';
import '../widgets/wifi_scan_error_view.dart';
import '../widgets/wifi_scanner_radar.dart';
import 'scan_comparison_page.dart';
import '../../../../core/errors/failure_labels.dart';

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

    // Check permission on mount
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _checkPermissionAndStart(),
    );
  }

  Future<void> _checkPermissionAndStart() async {
    if (!Platform.isAndroid) return;

    final status = await Permission.location.status;
    if (status.isGranted) return;

    if (mounted) {
      final shouldProceed =
          await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder:
                (ctx) => ProminentDisclosureDialog(
                  title: context.l10n.wifiScanPermissionTitle,
                  description: context.l10n.wifiScanPermissionDesc,
                  icon: Icons.location_on_rounded,
                  privacyPoints: [
                    context.l10n.consentScanSsids,
                    context.l10n.consentAnalyzeSignal,
                    context.l10n.consentNoTracking,
                  ],
                  actionLabel: context.l10n.continueLabel,
                  onAccept: () => Navigator.of(ctx).pop(true),
                  onCancel: () => Navigator.of(ctx).pop(false),
                ),
          ) ??
          false;

      if (shouldProceed && mounted) {
        final result = await Permission.location.request();
        if (result.isGranted && mounted) {
          context.read<WifiScanBloc>().add(
            WifiScanStarted(request: _currentRequest),
          );
        }
      }
    }
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
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          if (Platform.isIOS)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _IosPlatformBanner(),
            ),
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
                            child: WifiScannerRadar(),
                          ),
                          const SizedBox(height: 48),
                          StaggeredEntry(
                            child: Column(
                              children: [
                                Text(
                                  context.l10n.initiatingSpectrumScan,
                                  style: GoogleFonts.orbitron(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.l10n.broadcastingProbeRequests,
                                  style: GoogleFonts.rajdhani(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
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
                        // Localized sentence, not the English detail.
                        message: FailureLabels.forKey(
                          context.l10n,
                          state.messageKey,
                        ),
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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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

  Future<void> _clearScanHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              context.l10n.clearScanHistoryTitle,
              style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              context.l10n.clearWifiHistoryBody,
              style: GoogleFonts.rajdhani(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  context.l10n.cancelLabel,
                  style: GoogleFonts.orbitron(fontSize: 10),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  context.l10n.deleteAllLabel,
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    color: Theme.of(ctx).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      getIt<ScanSessionStore>().clear();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.snapshot.networks.isEmpty) {
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
              context.l10n.noSignalsDetected.toUpperCase(),
              style: GoogleFonts.orbitron(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.noRadiosInRange,
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
          // ── Signal Analysis Disclosure Banner ──
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 16,
                  color: AppColors.neonCyan,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.transparentSignalAnalysisTitle,
                        style: GoogleFonts.orbitron(
                          color: AppColors.neonCyan,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        context.l10n.transparentSignalAnalysisDesc,
                        style: GoogleFonts.rajdhani(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Android throttle / cached results banner ──
          if (widget.snapshot.isFromCache)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cached_rounded,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.l10n.cachedResultsWarning,
                      style: GoogleFonts.rajdhani(
                        color: Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Bento Header ──
          WifiBentoHeader(
            snapshot: widget.snapshot,
            isRefreshing: widget.isRefreshing,
          ),
          const SizedBox(height: 12),

          // ── Compare + Clear History Row ──
          if (getIt<ScanSessionStore>().all.length >= 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.compare_arrows_rounded, size: 16),
                      label: Text(
                        context.l10n.compareWithPreviousScan,
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      onPressed:
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ScanComparisonPage(),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.delete_sweep_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    tooltip: context.l10n.clearScanHistoryTitle,
                    onPressed: () => _clearScanHistory(context),
                  ),
                ],
              ),
            ),

          // ── Auto-Recommendation Banner ──
          if (_showRecommendation)
            RecommendationBanner(
              snapshot: widget.snapshot,
              onDismiss: () => setState(() => _showRecommendation = false),
            ),
          const SizedBox(height: 12),

          // ── Quick / Deep Scan Toggle ──
          ScanModeToggle(
            quickScan: !getIt<AppSettingsStore>().value.isDeepScanEnabled,
            onChanged: (isQuick) async {
              // Capture bloc before any async operation.
              final bloc = context.read<WifiScanBloc>();
              if (!isQuick) {
                // Enabling deep scan — require explicit confirmation.
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        backgroundColor:
                            Theme.of(ctx).colorScheme.surfaceContainerHigh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Text(
                          context.l10n.enableDeepScanTitle,
                          style: GoogleFonts.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(ctx).colorScheme.error,
                          ),
                        ),
                        content: Text(
                          context.l10n.enableDeepScanBodyWifi,
                          style: GoogleFonts.rajdhani(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(
                              context.l10n.cancelLabel,
                              style: GoogleFonts.orbitron(fontSize: 10),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(
                              context.l10n.iAmAuthorized,
                              style: GoogleFonts.orbitron(
                                fontSize: 10,
                                color: Theme.of(ctx).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                );
                if (confirmed != true) return;
              }

              // Google Play Compliance: Prominent Disclosure for Location
              if (Platform.isAndroid) {
                final status = await Permission.location.status;
                if (!status.isGranted && context.mounted) {
                  final shouldProceed =
                      await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => ProminentDisclosureDialog(
                              title: context.l10n.wifiScanPermissionTitle,
                              description: context.l10n.wifiScanPermissionDesc,
                              icon: Icons.location_on_rounded,
                              privacyPoints: [
                                context.l10n.consentScanSsids,
                                context.l10n.consentAnalyzeSignal,
                                context.l10n.consentNoTracking,
                              ],
                              actionLabel: context.l10n.continueLabel,
                              onAccept: () => Navigator.of(ctx).pop(true),
                              onCancel: () => Navigator.of(ctx).pop(false),
                            ),
                      ) ??
                      false;

                  if (shouldProceed && mounted) {
                    await Permission.location.request();
                  }
                }
              }

              if (!mounted) return;
              final store = getIt<AppSettingsStore>();
              store.update(store.value.copyWith(isDeepScanEnabled: !isQuick));
              final settings = store.value;
              final request = ScanRequest(
                passes:
                    settings.isDeepScanEnabled ? settings.defaultScanPasses : 1,
                includeHidden: settings.includeHiddenSsids,
                backendPreference: settings.defaultBackendPreference,
              );
              bloc.add(WifiScanStarted(request: request));
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
            label:
                filtered.length == widget.snapshot.networks.length
                    ? context.l10n.networksCount(filtered.length)
                    : context.l10n.filteredNetworksCount(
                      filtered.length,
                      widget.snapshot.networks.length,
                    ),
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
                  context.l10n.noNetworksMatchFilter,
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
                  onTogglePin:
                      () => context.read<WifiScanBloc>().add(
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

// ── iOS Platform Notice ────────────────────────────────────────────────────

class _IosPlatformBanner extends StatelessWidget {
  const _IosPlatformBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.withValues(alpha: 0.15),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.iosWifiScanLimited,
              style: GoogleFonts.rajdhani(
                color: Colors.orange,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
