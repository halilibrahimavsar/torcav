import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../settings/domain/services/app_settings_store.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../domain/entities/band_analysis_stat.dart';
import '../../domain/entities/scan_request.dart';
import '../../domain/entities/scan_snapshot.dart';
import '../../domain/entities/wifi_network.dart';
import '../../domain/entities/wifi_observation.dart';
import '../bloc/wifi_scan_bloc.dart';
import '../widgets/wifi_scanner_radar.dart';
import '../../../../features/security/presentation/pages/wifi_details_page.dart';
import '../../../../features/monitoring/presentation/pages/channel_rating_page.dart';
import '../../domain/services/scan_session_store.dart';
import 'scan_comparison_page.dart';

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
  Timer? _autoScanTimer;
  StreamSubscription<AppSettings>? _settingsSub;

  @override
  void initState() {
    super.initState();
    final store = getIt<AppSettingsStore>();
    final defaults = store.value;
    _passes = defaults.defaultScanPasses;
    _includeHidden = defaults.includeHiddenSsids;
    _backend = defaults.defaultBackendPreference;
    _setupAutoScan(defaults);
    _settingsSub = store.changes.listen(_onSettingsChanged);
  }

  void _onSettingsChanged(AppSettings settings) {
    _setupAutoScan(settings);
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
                      WifiScannerRadar(isScanning: true),
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
                  pinnedBssids: state.pinnedBssids,
                );
              }
              return Center(
                child: NeonText(
                  l10n.readyToScan,
                  style: GoogleFonts.rajdhani(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

// ── Scan filter state ────────────────────────────────────────────────

enum _SortBy { signal, ssid, channel, security }

class _FilterState {
  final String query;
  final _SortBy sortBy;
  final WifiBand? band; // null = all bands

  const _FilterState({
    this.query = '',
    this.sortBy = _SortBy.signal,
    this.band,
  });

  _FilterState copyWith({String? query, _SortBy? sortBy, Object? band = _sentinel}) {
    return _FilterState(
      query: query ?? this.query,
      sortBy: sortBy ?? this.sortBy,
      band: band == _sentinel ? this.band : band as WifiBand?,
    );
  }
}

const _sentinel = Object();

List<WifiObservation> _applyFilter(
  List<WifiObservation> networks,
  _FilterState filter, {
  Set<String> pinned = const {},
}) {
  var result = networks.where((n) {
    final q = filter.query.trim().toLowerCase();
    if (q.isNotEmpty) {
      if (!n.ssid.toLowerCase().contains(q) &&
          !n.bssid.toLowerCase().contains(q) &&
          !n.vendor.toLowerCase().contains(q)) {
        return false;
      }
    }
    if (filter.band != null) {
      final freq = n.frequency;
      final networkBand = freq >= 5925
          ? WifiBand.ghz6
          : freq >= 5000
              ? WifiBand.ghz5
              : WifiBand.ghz24;
      if (networkBand != filter.band) return false;
    }
    return true;
  }).toList();

  switch (filter.sortBy) {
    case _SortBy.signal:
      result.sort((a, b) => b.avgSignalDbm.compareTo(a.avgSignalDbm));
    case _SortBy.ssid:
      result.sort((a, b) => a.ssid.toLowerCase().compareTo(b.ssid.toLowerCase()));
    case _SortBy.channel:
      result.sort((a, b) => a.channel.compareTo(b.channel));
    case _SortBy.security:
      result.sort((a, b) => a.security.index.compareTo(b.security.index));
  }

  // Float pinned networks to the top regardless of sort order.
  if (pinned.isNotEmpty) {
    result.sort((a, b) {
      final ap = pinned.contains(a.bssid) ? 0 : 1;
      final bp = pinned.contains(b.bssid) ? 0 : 1;
      return ap.compareTo(bp);
    });
  }

  return result;
}

// ── Snapshot View ────────────────────────────────────────────────────

class _SnapshotView extends StatefulWidget {
  final ScanSnapshot snapshot;
  final ScanRequest currentRequest;
  final Set<String> pinnedBssids;

  const _SnapshotView({
    required this.snapshot,
    required this.currentRequest,
    this.pinnedBssids = const {},
  });

  @override
  State<_SnapshotView> createState() => _SnapshotViewState();
}

class _SnapshotViewState extends State<_SnapshotView> {
  _FilterState _filter = const _FilterState();
  final _searchController = TextEditingController();
  bool _showRecommendation = true;
  bool _quickScan = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerRescan(BuildContext context) {
    final defaults = getIt<AppSettingsStore>().value;
    final request = ScanRequest(
      passes: _quickScan ? 1 : defaults.defaultScanPasses,
      includeHidden: defaults.includeHiddenSsids,
      backendPreference: defaults.defaultBackendPreference,
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

    final filtered = _applyFilter(
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
          _WifiBentoHeader(snapshot: widget.snapshot),
          const SizedBox(height: 12),

          // ── Compare Button (shown when ≥2 scans available) ──
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
            _RecommendationBanner(
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
                child: _ChannelRatingLink(
                  snapshot: widget.snapshot,
                  request: widget.currentRequest,
                ),
              );
            },
          ),

          // ── Quick / Deep Scan Toggle ──
          _ScanModeToggle(
            quickScan: _quickScan,
            onChanged: (isQuick) {
              setState(() => _quickScan = isQuick);
              _triggerRescan(context);
            },
          ),
          const SizedBox(height: 8),

          // ── Search & Filter Bar ──
          _SearchFilterBar(
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
                child: _WifiNetworkCard(
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

// ── Quick / Deep Scan Mode Toggle ────────────────────────────────────

class _ScanModeToggle extends StatelessWidget {
  final bool quickScan;
  final ValueChanged<bool> onChanged;

  const _ScanModeToggle({required this.quickScan, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        _ModeButton(
          label: AppLocalizations.of(context)!.quickScan,
          icon: Icons.flash_on_rounded,
          selected: quickScan,
          color: Theme.of(context).colorScheme.tertiary,
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: 8),
        _ModeButton(
          label: AppLocalizations.of(context)!.deepScan,
          icon: Icons.radar_rounded,
          selected: !quickScan,
          color: primary,
          onTap: () => onChanged(false),
        ),
        const SizedBox(width: 8),
        InfoIconButton(
          title: AppLocalizations.of(context)!.scanModesTitle,
          body: AppLocalizations.of(context)!.scanModesInfo,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.7) : color.withValues(alpha: 0.2),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? color : color.withValues(alpha: 0.5)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                color: selected ? color : color.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search + Filter Bar ──────────────────────────────────────────────

class _SearchFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final _FilterState filter;
  final ValueChanged<_FilterState> onFilterChanged;

  const _SearchFilterBar({
    required this.controller,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surfaceContainer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.rajdhani(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchSsidBssidVendor,
              hintStyle: GoogleFonts.rajdhani(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              prefixIcon: Icon(Icons.search_rounded, color: primary, size: 18),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, size: 16, color: primary),
                      onPressed: () {
                        controller.clear();
                        onFilterChanged(filter.copyWith(query: ''));
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (v) => onFilterChanged(filter.copyWith(query: v)),
          ),
        ),
        const SizedBox(height: 8),
        // Sort + Band filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ScanChip(
                label: AppLocalizations.of(context)!.sortPrefix(_sortLabel(context, filter.sortBy)),
                icon: Icons.sort_rounded,
                color: primary,
                onTap: () => _showSortMenu(context),
              ),
              const SizedBox(width: 8),
              for (final band in [null, WifiBand.ghz24, WifiBand.ghz5, WifiBand.ghz6])
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _ScanChip(
                    label: band == null ? AppLocalizations.of(context)!.bandAll : _bandLabel(band),
                    icon: band == null ? Icons.cell_tower_rounded : Icons.wifi_rounded,
                    color: filter.band == band ? primary : Theme.of(context).colorScheme.outline,
                    selected: filter.band == band,
                    onTap: () => onFilterChanged(filter.copyWith(band: band)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _sortLabel(BuildContext context, _SortBy sortBy) {
    final l10n = AppLocalizations.of(context)!;
    switch (sortBy) {
      case _SortBy.signal:
        return l10n.sortSignal;
      case _SortBy.ssid:
        return l10n.sortName;
      case _SortBy.channel:
        return l10n.sortChannel;
      case _SortBy.security:
        return l10n.sortSecurity;
    }
  }

  String _bandLabel(WifiBand band) {
    switch (band) {
      case WifiBand.ghz24:
        return '2.4 GHz';
      case WifiBand.ghz5:
        return '5 GHz';
      case WifiBand.ghz6:
        return '6 GHz';
    }
  }

  void _showSortMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.sortByTitle,
              style: GoogleFonts.orbitron(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            for (final sort in _SortBy.values)
              ListTile(
                title: Text(
                  _sortLabel(context, sort).toUpperCase(),
                  style: GoogleFonts.rajdhani(
                    color: filter.sortBy == sort
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: filter.sortBy == sort
                    ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  onFilterChanged(filter.copyWith(sortBy: sort));
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ScanChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ScanChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.15)
              : Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: selected ? 0.6 : 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Auto-Recommendation Banner ───────────────────────────────────────

class _RecommendationBanner extends StatelessWidget {
  final ScanSnapshot snapshot;
  final VoidCallback onDismiss;

  const _RecommendationBanner({
    required this.snapshot,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.bandStats.isEmpty) return const SizedBox.shrink();

    // Pick the band with the highest average congestion.
    final sortedBands = List.of(snapshot.bandStats)
      ..sort(
        (a, b) => snapshot.channelStats
            .where((c) {
              final f = c.frequency;
              return switch (a.band) {
                WifiBand.ghz24 => f < 5000,
                WifiBand.ghz5 => f >= 5000 && f < 5925,
                WifiBand.ghz6 => f >= 5925,
              };
            })
            .map((c) => c.congestionScore)
            .fold(0.0, (acc, s) => acc > s ? acc : s)
            .compareTo(
              snapshot.channelStats
                  .where((c) {
                    final f = c.frequency;
                    return switch (b.band) {
                      WifiBand.ghz24 => f < 5000,
                      WifiBand.ghz5 => f >= 5000 && f < 5925,
                      WifiBand.ghz6 => f >= 5925,
                    };
                  })
                  .map((c) => c.congestionScore)
                  .fold(0.0, (acc, s) => acc > s ? acc : s),
            ),
      );

    final best = sortedBands.firstOrNull;
    if (best == null || best.recommendedChannels.isEmpty) {
      return const SizedBox.shrink();
    }

    final bandName = switch (best.band) {
      WifiBand.ghz24 => '2.4 GHz',
      WifiBand.ghz5 => '5 GHz',
      WifiBand.ghz6 => '6 GHz',
    };
    final channels = best.recommendedChannels.take(3).join(', ');
    final color = Theme.of(context).colorScheme.tertiary;

    return NeonCard(
      glowColor: color,
      glowIntensity: 0.08,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!.recommendationTip(channels, bandName),
                    style: GoogleFonts.rajdhani(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                InfoIconButton(
                  title: AppLocalizations.of(context)!.channelInterferenceTitle,
                  body:
                      AppLocalizations.of(context)!.channelInterferenceDescription,
                  color: color,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
                      const WifiScannerRadar(isScanning: true),
                      // Center Icon
                      Icon(
                        Icons.settings_input_antenna_rounded,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.5),
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
                                  label: AppLocalizations.of(context)!.networksLabel,
                                  value: '${snapshot.networks.length}',
                                  icon: Icons.wifi_find_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: BentoStatTile(
                                  label: AppLocalizations.of(context)!.securityLabel,
                                  value:
                                      '${snapshot.networks.where((n) => n.security != SecurityType.open).length}',
                                  icon: Icons.security_rounded,
                                  color: AppColors.neonGreen,
                                  subValue:
                                      AppLocalizations.of(context)!.openCount(snapshot.networks.where((n) => n.security == SecurityType.open).length),
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
                                  label: AppLocalizations.of(context)!.avgSignalLabel,
                                  value:
                                      snapshot.networks.isEmpty
                                          ? AppLocalizations.of(context)!.notAvailable
                                          : '${(snapshot.networks.map((n) => n.avgSignalDbm).reduce((a, b) => a + b) / snapshot.networks.length).round()}',
                                  icon: Icons.signal_wifi_4_bar_rounded,
                                  color: AppColors.neonPurple,
                                  subValue: AppLocalizations.of(context)!.dbmCaps,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: BentoStatTile(
                                  label: AppLocalizations.of(context)!.interfaceLabel,
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
                          glowColor: _getBandColor(context, band.band),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                band.label,
                                style: GoogleFonts.orbitron(
                                  color: _getBandColor(context, band.band),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                AppLocalizations.of(context)!.networksCount(band.networkCount),
                                style: GoogleFonts.rajdhani(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
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

  Color _getBandColor(BuildContext context, WifiBand band) {
    switch (band) {
      case WifiBand.ghz24:
        return Theme.of(context).colorScheme.primary;
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
  final bool isPinned;
  final VoidCallback onTogglePin;

  const _WifiNetworkCard({
    required this.network,
    required this.interfaceName,
    required this.isPinned,
    required this.onTogglePin,
  });

  Color getSignalColor(BuildContext context) {
    if (network.avgSignalDbm > -55) return AppColors.neonGreen;
    if (network.avgSignalDbm > -70) return Theme.of(context).colorScheme.primary;
    if (network.avgSignalDbm > -85) return AppColors.neonOrange;
    return AppColors.neonRed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final signalColor = getSignalColor(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeonCard(
        glowColor: signalColor,
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
                        color: signalColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: signalColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    Icon(Icons.wifi_rounded, color: signalColor, size: 20),
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
                                      ? signalColor
                                      : signalColor.withValues(alpha: 0.1),
                              boxShadow:
                                  isActive
                                      ? [
                                        BoxShadow(
                                          color: signalColor.withValues(
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
                          color: Theme.of(context).colorScheme.onSurface,
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
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    GestureDetector(
                      onTap: onTogglePin,
                      child: Icon(
                        isPinned ? Icons.star_rounded : Icons.star_border_rounded,
                        color: isPinned
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    NeonText(
                      '${network.avgSignalDbm}',
                      style: GoogleFonts.orbitron(
                        color: signalColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                      glowColor: signalColor,
                      glowRadius: 6,
                    ),
                    Text(
                      'dBm',
                      style: GoogleFonts.rajdhani(
                        color: signalColor.withValues(alpha: 0.7),
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MiniTechTag(
                  label: l10n.channelLabel(network.channel),
                  icon: Icons.tag_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                _MiniTechTag(
                  label: l10n.frequencyLabel(network.frequency),
                  icon: Icons.waves_rounded,
                  color: AppColors.neonPurple,
                ),
                const SizedBox(width: 8),
                _MiniTechTag(
                  label: network.security.name.toUpperCase(),
                  icon: switch (network.security) {
                    SecurityType.open => Icons.lock_open_rounded,
                    SecurityType.wep => Icons.lock_open_rounded,
                    _ => Icons.lock_rounded,
                  },
                  color: switch (network.security) {
                    SecurityType.wpa2 || SecurityType.wpa3 => AppColors.neonGreen,
                    SecurityType.wpa => Colors.amber,
                    _ => AppColors.neonRed,
                  },
                ),
                const Spacer(),
                Text(
                  'σ ${network.signalStdDev.toStringAsFixed(1)}',
                  style: GoogleFonts.rajdhani(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    final l10n = AppLocalizations.of(context)!;
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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry.toUpperCase()),
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
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.spectrumOptimizationCaps,
                  style: GoogleFonts.orbitron(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  l10n.spectrumOptimizationDesc,
                  style: GoogleFonts.rajdhani(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.neonPurple),
        ],
      ),
    );
  }
}
