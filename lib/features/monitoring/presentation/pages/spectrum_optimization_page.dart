import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../wifi_scan/domain/entities/channel_rating.dart';
import '../../../wifi_scan/domain/entities/channel_rating_sample.dart';
import '../../../wifi_scan/domain/entities/wifi_network.dart';
import '../../../wifi_scan/domain/repositories/channel_rating_repository.dart';
import '../../../wifi_scan/presentation/bloc/wifi_scan_bloc.dart';
import '../../domain/router_grouping.dart';
import '../../domain/wifi_region.dart';
import '../bloc/monitoring_bloc.dart';
import '../widgets/about_spectrum_panel.dart';
import '../widgets/channel_history_chart.dart';
import '../widgets/channel_spectral_chart.dart';
import '../widgets/hour_of_day_heatmap.dart';
import '../widgets/router_admin_guide_card.dart';
import '../widgets/router_groups_card.dart';
import '../widgets/spectrum_colors.dart';
import '../widgets/spectrum_overlap_chart.dart';
import '../../../wifi_scan/domain/entities/wifi_band.dart';
import '../../../../core/errors/failure_labels.dart';

/// Operations Hub entry-point for the Spectrum / Channel Optimization tool.
///
/// Triggers a fresh Wi-Fi scan on open and pipes the result into
/// [MonitoringBloc] for channel rating analysis. Hosts a 4-tab view:
/// 2.4 GHz · 5 GHz · 6 GHz · History.
class SpectrumOptimizationPage extends StatelessWidget {
  const SpectrumOptimizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // `create:` (not `.value`) because both blocs are registered as DI
    // factories: BlocProvider owns them and closes them on dispose. With
    // `.value` nothing ever called close(), so every rebuild leaked a
    // MonitoringBloc still subscribed to the scan stream.
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<MonitoringBloc>()),
        BlocProvider(create: (_) => getIt<WifiScanBloc>()),
      ],
      child: const _SpectrumView(),
    );
  }
}

class _SpectrumView extends StatefulWidget {
  const _SpectrumView();

  @override
  State<_SpectrumView> createState() => _SpectrumViewState();
}

class _SpectrumViewState extends State<_SpectrumView> {
  static const double _alertThreshold = 6.0;
  String? _connectedBssid;
  WifiRegion? _region;
  // Channel for which we already fired an alert in this page session — we
  // only re-alert if the user moves to a different channel and that one
  // drops too. This prevents alert spam while staying on the page.
  int? _alertedChannel;

  @override
  void initState() {
    super.initState();
    _detectConnectedBssid();
    // Trigger a scan as soon as the page mounts. If the bloc already has a
    // recent loaded snapshot, the BlocListener below will analyse it
    // immediately; otherwise the listener fires when the new scan finishes.
    final scanBloc = context.read<WifiScanBloc>();
    final state = scanBloc.state;
    if (state is WifiScanLoaded) {
      _analyse(state);
    }
    scanBloc.add(const WifiScanRefreshed());
  }

  void _maybeAlertOnLowQuality(ChannelAnalysisReady state) {
    final bssid = _connectedBssid?.toUpperCase();
    if (bssid == null) return;
    final scanState = context.read<WifiScanBloc>().state;
    if (scanState is! WifiScanLoaded) return;
    final networks = scanState.snapshot.networks;
    final connectedIdx = networks.indexWhere(
      (n) => n.bssid.toUpperCase() == bssid,
    );
    if (connectedIdx < 0) return;
    final connected = networks[connectedIdx];
    ChannelRating? ratingForConnected;
    for (final r in state.ratings) {
      if (r.channel == connected.channel &&
          (r.frequency - connected.frequency).abs() <= 5) {
        ratingForConnected = r;
        break;
      }
    }
    if (ratingForConnected == null) return;
    if (ratingForConnected.rating >= _alertThreshold) {
      _alertedChannel = null;
      return;
    }
    if (_alertedChannel == ratingForConnected.channel) return;
    _alertedChannel = ratingForConnected.channel;

    // Find the best alternative for the same band.
    final connectedBand = bandFromFrequency(ratingForConnected.frequency);
    final sameBand =
        state.ratings
            .where((r) => bandFromFrequency(r.frequency) == connectedBand)
            .toList()
          ..sort((a, b) => b.rating.compareTo(a.rating));
    if (sameBand.isEmpty) return;
    final best = sameBand.first;
    if (best.channel == ratingForConnected.channel) return;
    if (best.rating - ratingForConnected.rating < 1.0) return;

    // OS notifications are reserved for the native background workers that
    // survive process death (MonitoringWorker, StabilizerAlertEngine); on
    // this live page the recommendation surfaces as an in-app SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.wifiChannelQualityDroppedBody(
            ratingForConnected.channel,
            ratingForConnected.rating.toStringAsFixed(1),
            best.channel,
            best.rating.toStringAsFixed(1),
          ),
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  Future<void> _detectConnectedBssid() async {
    try {
      final bssid = await getIt<NetworkInfo>().getWifiBSSID();
      if (mounted) setState(() => _connectedBssid = bssid);
    } catch (_) {
      // Permission denied or platform error — silently ignore; the page
      // still works, just without the "ON NOW" current-channel indicator.
    }
  }

  void _analyse(WifiScanLoaded state) {
    final networks =
        state.snapshot.networks.map((n) => n.toWifiNetwork()).toList();
    context.read<MonitoringBloc>().add(AnalyzeChannels(networks));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final region =
        _region ??
        RegionAllowlist.fromCountryCode(
          Localizations.localeOf(context).countryCode,
        );
    return MultiBlocListener(
      listeners: [
        BlocListener<WifiScanBloc, WifiScanState>(
          // Re-analyse whenever a fresh non-refreshing scan snapshot lands.
          listenWhen: (prev, curr) {
            if (curr is! WifiScanLoaded) return false;
            if (curr.isRefreshing) return false;
            if (prev is WifiScanLoaded) {
              return prev.snapshot != curr.snapshot ||
                  prev.isRefreshing != curr.isRefreshing;
            }
            return true;
          },
          listener: (context, state) {
            if (state is WifiScanLoaded) _analyse(state);
          },
        ),
        BlocListener<MonitoringBloc, MonitoringState>(
          listenWhen:
              (_, curr) =>
                  curr is ChannelAnalysisReady && _connectedBssid != null,
          listener: (context, state) {
            if (state is! ChannelAnalysisReady) return;
            _maybeAlertOnLowQuality(state);
          },
        ),
      ],
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.spectrumOptimizationCaps,
              style: GoogleFonts.orbitron(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              BlocBuilder<WifiScanBloc, WifiScanState>(
                builder: (context, state) {
                  final loading =
                      state is WifiScanLoading ||
                      (state is WifiScanLoaded && state.isRefreshing);
                  if (loading) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  }
                  return IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: l10n.refreshScanTooltip,
                    onPressed: () {
                      context.read<WifiScanBloc>().add(
                        const WifiScanRefreshed(),
                      );
                    },
                  );
                },
              ),
              PopupMenuButton<WifiRegion>(
                icon: const Icon(Icons.public_rounded),
                tooltip: l10n.countryAllowlistHeader,
                onSelected: (r) => setState(() => _region = r),
                itemBuilder:
                    (ctx) => [
                      for (final r in WifiRegion.values)
                        PopupMenuItem(
                          value: r,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (region == r)
                                const Icon(Icons.check_rounded, size: 16)
                              else
                                const SizedBox(width: 16),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _regionLabel(l10n, r),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
              ),
            ],
            bottom: TabBar(
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: onSurface.withValues(alpha: 0.5),
              labelStyle: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              tabs: [
                Tab(text: l10n.band24Ghz),
                Tab(text: l10n.band5Ghz),
                Tab(text: l10n.band6Ghz),
                Tab(text: l10n.historyCaps),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              for (final band in [0, 1, 2])
                _BandTab(
                  band: band,
                  bandLabel:
                      [l10n.band24Ghz, l10n.band5Ghz, l10n.band6Ghz][band],
                  accentColor: bandAccentColor(WifiBand.values[band]),
                  emptyHint:
                      [
                        l10n.no24GhzChannels,
                        l10n.no5GhzChannels,
                        l10n.no6GhzChannels,
                      ][band],
                  connectedBssid: _connectedBssid,
                  region: region,
                ),
              _HistoryTab(
                connectedBssid: _connectedBssid,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Per-band tab ────────────────────────────────────────────────────────

class _BandTab extends StatelessWidget {
  final int band; // 0 = 2.4, 1 = 5, 2 = 6
  final String bandLabel;
  final Color accentColor;
  final String emptyHint;
  final String? connectedBssid;
  final WifiRegion region;

  const _BandTab({
    required this.band,
    required this.bandLabel,
    required this.accentColor,
    required this.emptyHint,
    required this.connectedBssid,
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<MonitoringBloc, MonitoringState>(
      builder: (context, state) {
        if (state is MonitoringLoading || state is MonitoringInitial) {
          return _ScanningPlaceholder(label: l10n.initiatingSpectrumScan);
        }
        if (state is MonitoringFailure) {
          return NeonErrorCard(
            // The technical detail is English; show the localized
            // sentence and leave the detail for the logs.
            message: FailureLabels.forKey(l10n, state.messageKey),
            onRetry: () {
              final s = context.read<WifiScanBloc>().state;
              if (s is WifiScanLoaded) {
                final networks =
                    s.snapshot.networks.map((n) => n.toWifiNetwork()).toList();
                context.read<MonitoringBloc>().add(AnalyzeChannels(networks));
              }
            },
          );
        }
        if (state is ChannelAnalysisReady) {
          final tabBand = WifiBand.values[band];
          final ratings =
              state.ratings
                  .where((r) => bandFromFrequency(r.frequency) == tabBand)
                  .toList()
                ..sort((a, b) => b.rating.compareTo(a.rating));

          final scanState = context.watch<WifiScanBloc>().state;
          final networks =
              scanState is WifiScanLoaded
                  ? scanState.snapshot.networks
                      .map((n) => n.toWifiNetwork())
                      .toList()
                  : <WifiNetwork>[];

          return _BandView(
            ratings: ratings,
            allRatings: state.ratings,
            historicalAverages: state.historicalAverages,
            previousRatings: state.previousRatings,
            bandLabel: bandLabel,
            accentColor: accentColor,
            emptyHint: emptyHint,
            networks: networks,
            connectedBssid: connectedBssid,
            region: region,
          );
        }
        return _ScanningPlaceholder(label: l10n.analyzing);
      },
    );
  }
}

class _ScanningPlaceholder extends StatelessWidget {
  final String label;
  const _ScanningPlaceholder({required this.label});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const AboutSpectrumPanel(),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                label,
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── History tab (loads samples from repository) ────────────────────────

class _HistoryTab extends StatefulWidget {
  final String? connectedBssid;

  const _HistoryTab({
    this.connectedBssid,
  });

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  List<ChannelRatingSample>? _samples;
  bool _loading = true;

  int? _resolveConnectedChannel(BuildContext context) {
    final bssid = widget.connectedBssid?.toUpperCase();
    if (bssid == null) return null;
    final scanState = context.read<WifiScanBloc>().state;
    if (scanState is! WifiScanLoaded) return null;
    for (final n in scanState.snapshot.networks) {
      if (n.bssid.toUpperCase() == bssid) return n.channel;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final result = await getIt<ChannelRatingRepository>().getHistory(
      limit: const Duration(days: 7),
    );
    if (mounted) {
      setState(() {
        _samples = result.getOrElse(() => []);
        _loading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Theme.of(ctx).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              l10n.clearChannelHistoryTitle,
              style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              l10n.clearChannelHistoryConfirmBody,
              style: GoogleFonts.rajdhani(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  l10n.cancel.toUpperCase(),
                  style: GoogleFonts.orbitron(fontSize: 10),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  l10n.deleteAllLabel,
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    color: Theme.of(ctx).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await getIt<ChannelRatingRepository>().clearHistory();
      unawaited(_reload());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _reload,
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AboutSpectrumPanel(),
            if (_samples != null && _samples!.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _clearHistory,
                  icon: Icon(
                    Icons.delete_sweep_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  label: Text(
                    context.l10n.clearHistoryAction,
                    style: GoogleFonts.orbitron(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            StaggeredEntry(
              child: ChannelHistoryChart(
                samples: _samples ?? [],
                connectedChannel: _resolveConnectedChannel(context),
              ),
            ),
            if (_samples != null && _samples!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.hourlyHeatmapTitle,
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              HourOfDayHeatmap(samples: _samples!),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Band view (per-band content rendered inside each tab) ─────────────

class _BandView extends StatefulWidget {
  final List<ChannelRating> ratings;
  final List<ChannelRating> allRatings;
  final Map<int, double> historicalAverages;
  final Map<int, double> previousRatings;
  final String bandLabel;
  final Color accentColor;
  final String emptyHint;
  final List<WifiNetwork> networks;
  final String? connectedBssid;
  final WifiRegion region;

  const _BandView({
    required this.ratings,
    required this.allRatings,
    required this.historicalAverages,
    required this.previousRatings,
    required this.bandLabel,
    required this.accentColor,
    required this.emptyHint,
    required this.networks,
    required this.connectedBssid,
    required this.region,
  });

  @override
  State<_BandView> createState() => _BandViewState();
}

class _BandViewState extends State<_BandView> {
  final GlobalKey _connectedTileKey = GlobalKey();
  bool _didAutoScroll = false;

  /// Returns the channel the user's own router is broadcasting on within this
  /// band. Two cases produce a hit:
  ///
  /// 1. **Direct** — the connected BSSID itself sits on this band.
  /// 2. **Dual-band sibling** — the connected BSSID is on another band but
  ///    the same physical router exposes a sibling radio on this band
  ///    (matched via SSID + BSSID prefix). The hit is flagged so the UI can
  ///    label it differently — the user is not actually using this radio
  ///    right now.
  ({ChannelRating rating, bool isSibling})? _findConnectedHit() {
    final connectedBssid = widget.connectedBssid;
    if (connectedBssid == null) return null;
    final target = connectedBssid.toUpperCase();
    final idx = widget.networks.indexWhere(
      (n) => n.bssid.toUpperCase() == target,
    );
    if (idx < 0) return null;
    final connectedNet = widget.networks[idx];

    ChannelRating? matchInBand(int channel, int frequency) {
      for (final r in widget.ratings) {
        if (r.channel == channel && (r.frequency - frequency).abs() <= 5) {
          return r;
        }
      }
      return null;
    }

    final direct = matchInBand(connectedNet.channel, connectedNet.frequency);
    if (direct != null) return (rating: direct, isSibling: false);

    for (final s in crossBandSiblingsOf(connectedNet, widget.networks)) {
      final hit = matchInBand(s.channel, s.frequency);
      if (hit != null) return (rating: hit, isSibling: true);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    // Local aliases for the widget's fields keep the rest of this large
    // build method readable without `widget.` noise on every reference.
    final ratings = widget.ratings;
    final allRatings = widget.allRatings;
    final historicalAverages = widget.historicalAverages;
    final previousRatings = widget.previousRatings;
    final bandLabel = widget.bandLabel;
    final accentColor = widget.accentColor;
    final emptyHint = widget.emptyHint;
    final networks = widget.networks;
    final connectedBssid = widget.connectedBssid;
    final region = widget.region;

    if (ratings.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AboutSpectrumPanel(),
          const SizedBox(height: 24),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_off,
                  color: onSurface.withValues(alpha: 0.35),
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  emptyHint,
                  style: GoogleFonts.rajdhani(
                    color: onSurface.withValues(alpha: 0.58),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Region allowlist controls (a) which channels we recommend and (b)
    // how individual channel tiles are styled.
    final allow = RegionAllowlist.forRegion(region);
    final allowedRatings =
        ratings.where((r) => allow.isAllowed(r.channel, r.frequency)).toList();
    // Recommend from allowed-only; if region disallows everything we have,
    // fall back to the global best to avoid an empty card.
    final best = (allowedRatings.isNotEmpty ? allowedRatings : ratings).first;
    final bandChannels = ratings.map((r) => r.channel).toSet();
    final historicalBest =
        historicalAverages.entries
            .where((e) => bandChannels.contains(e.key))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final consistentlyBest =
        historicalBest.isNotEmpty ? historicalBest.first : null;
    final connectedHit = _findConnectedHit();
    final connectedRating = connectedHit?.rating;
    final isSiblingHit = connectedHit?.isSibling ?? false;
    final is6Ghz = bandFromFrequency(ratings.first.frequency) == WifiBand.ghz6;

    // First-paint auto-scroll: bring the user's connected channel tile into
    // view so they don't have to hunt for it in a long list.
    if (!_didAutoScroll && connectedRating != null) {
      _didAutoScroll = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _connectedTileKey.currentContext;
        if (ctx != null && mounted) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            alignment: 0.3,
          );
        }
      });
    }

    // Networks belonging to *this* band (filtered by frequency, mirroring
    // the band-split rule used for the rating list).
    final bandNetworks =
        ratings.isEmpty
            ? <WifiNetwork>[]
            : () {
              final tabBand = bandFromFrequency(ratings.first.frequency);
              return networks
                  .where(
                    (n) =>
                        n.frequency > 0 &&
                        bandFromFrequency(n.frequency) == tabBand,
                  )
                  .toList();
            }();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const AboutSpectrumPanel(),
        if (connectedRating != null) ...[
          _CurrentChannelBanner(
            current: connectedRating,
            recommended: best,
            accentColor: accentColor,
            isSibling: isSiblingHit,
            bandLabel: bandLabel,
          ),
          const SizedBox(height: 16),
        ],
        if (is6Ghz) ...[
          _InfoChip(
            icon: Icons.bolt_rounded,
            label: l10n.afcInfoTitle,
            color: accentColor,
            sheetTitle: l10n.afcInfoTitle,
            sheetBody: l10n.afcInfoBody,
          ),
          const SizedBox(height: 16),
        ],
        // ── Network Overlap (classic spectrum analyzer) ──
        Row(
          children: [
            Icon(Icons.show_chart_rounded, color: accentColor, size: 18),
            const SizedBox(width: 8),
            Text(
              l10n.spectrumOverlapTitle,
              style: GoogleFonts.orbitron(
                color: accentColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            InfoIconButton(
              title: l10n.spectrumOverlapInfoTitle,
              body: l10n.spectrumOverlapInfoBody,
              color: accentColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SpectrumOverlapChart(
          networks: bandNetworks,
          accentColor: accentColor,
          connectedBssid: connectedBssid,
        ),
        const SizedBox(height: 20),
        // ── Channel Spectrum bar chart with header + info ──
        Row(
          children: [
            Icon(Icons.equalizer_rounded, color: accentColor, size: 18),
            const SizedBox(width: 8),
            Text(
              l10n.bandSpectrumTitle,
              style: GoogleFonts.orbitron(
                color: accentColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            InfoIconButton(
              title: l10n.bandSpectrumInfoTitle,
              body: l10n.bandSpectrumInfoBody,
              color: accentColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ChannelSpectralChart(ratings: ratings, accentColor: accentColor),
        const SizedBox(height: 24),
        if (consistentlyBest != null &&
            consistentlyBest.key != best.channel) ...[
          _HistoricalBestCard(
            channel: consistentlyBest.key,
            avgRating: consistentlyBest.value,
            accentColor: accentColor,
          ),
          const SizedBox(height: 16),
        ],
        _RecommendationCard(
          rating: best,
          accentColor: accentColor,
          previousRating: previousRatings[best.channel],
        ),
        if (best.isDfs) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.orangeAccent.withValues(alpha: 0.08),
              border: Border.all(
                color: Colors.orangeAccent.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              l10n.dfsCacWarning,
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                height: 1.4,
                color: onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        RouterAdminGuideCard(networkInfo: getIt<NetworkInfo>()),
        // ── Cross-band router groups (dual-band detection) ──
        Builder(
          builder: (ctx) {
            final groups = groupDualBandRouters(networks);
            if (groups.isEmpty) return const SizedBox.shrink();
            return RouterGroupsCard(
              groups: groups,
              ratingFor: (radio) {
                final r = allRatings.firstWhere(
                  (cr) =>
                      cr.channel == radio.channel &&
                      (cr.frequency - radio.frequency).abs() <= 5,
                  orElse:
                      () => const ChannelRating(
                        channel: -1,
                        frequency: 0,
                        rating: 0,
                        networkCount: 0,
                        quality: ChannelQuality.fair,
                      ),
                );
                final key = switch (bandFromFrequency(radio.frequency)) {
                  WifiBand.ghz24 => '2.4',
                  WifiBand.ghz5 => '5',
                  WifiBand.ghz6 => '6',
                };
                return {key: r.channel < 0 ? null : r};
              },
              onJumpToBand: (idx) {
                DefaultTabController.of(ctx).animateTo(idx);
              },
            );
          },
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.bandChannels(bandLabel),
                style: GoogleFonts.orbitron(
                  color: onSurface.withValues(alpha: 0.82),
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
            ),
            _DensityTrendChip(
              ratings: ratings,
              previousRatings: previousRatings,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...ratings.map((r) {
          final isConnected =
              connectedRating != null &&
              r.channel == connectedRating.channel &&
              r.frequency == connectedRating.frequency;
          return _ChannelTile(
            key: isConnected ? _connectedTileKey : null,
            rating: r,
            accentColor: accentColor,
            isConnected: isConnected,
            isSibling: isConnected && isSiblingHit,
            isAllowedInRegion: allow.isAllowed(r.channel, r.frequency),
            networksOnChannel:
                bandNetworks
                    .where(
                      (n) =>
                          n.channel == r.channel &&
                          (n.frequency - r.frequency).abs() <= 5,
                    )
                    .toList()
                  ..sort(
                    (a, b) => b.signalStrength.compareTo(a.signalStrength),
                  ),
            allNetworks: networks,
            allRatings: allRatings,
          );
        }),
        _ChannelBondingSection(
          ratings: ratings,
          networks: networks,
          accentColor: accentColor,
        ),
      ],
    );
  }
}

class _HistoricalBestCard extends StatelessWidget {
  final int channel;
  final double avgRating;
  final Color accentColor;

  const _HistoricalBestCard({
    required this.channel,
    required this.avgRating,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.history, color: accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        l10n.consistentlyBestChannel,
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          color: accentColor.withValues(alpha: 0.7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InfoIconButton(
                      title: l10n.consistentChannelInfoTitle,
                      body: l10n.consistentChannelInfoBody,
                      color: accentColor,
                    ),
                  ],
                ),
                Text(
                  l10n.channelLabel(channel),
                  style: GoogleFonts.orbitron(
                    fontSize: 18,
                    color: onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.avgScore,
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                avgRating.toStringAsFixed(1),
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final ChannelRating rating;
  final Color accentColor;
  final double? previousRating;

  const _RecommendationCard({
    required this.rating,
    required this.accentColor,
    this.previousRating,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.15),
            accentColor.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text(
                '${rating.channel}',
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        l10n.recommendedChannel,
                        style: GoogleFonts.rajdhani(
                          color: accentColor,
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InfoIconButton(
                      title: l10n.recommendationInfoTitle,
                      body: l10n.recommendationInfoBody,
                      color: accentColor,
                    ),
                  ],
                ),
                Text(
                  l10n.channelInfo(rating.channel, rating.frequency),
                  style: GoogleFonts.orbitron(
                    color: onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${rating.rating.toStringAsFixed(1)}/10 · ${_qualityString(l10n, rating.quality)}',
                  style: GoogleFonts.rajdhani(
                    color: onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                if (previousRating != null) ...[
                  const SizedBox(height: 4),
                  _DeltaLine(
                    delta: rating.rating - previousRating!,
                    color: accentColor,
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.star_rounded, color: accentColor, size: 28),
        ],
      ),
    );
  }
}

class _DeltaLine extends StatelessWidget {
  final double delta;
  final Color color;
  const _DeltaLine({required this.delta, required this.color});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final abs = delta.abs();
    if (abs < 0.3) {
      return Text(
        l10n.scanComparisonStable,
        style: GoogleFonts.rajdhani(
          fontSize: 12,
          color: onSurface.withValues(alpha: 0.55),
          fontStyle: FontStyle.italic,
        ),
      );
    }
    final improved = delta > 0;
    final fmt = '${improved ? '+' : '−'}${abs.toStringAsFixed(1)}';
    final text =
        improved
            ? l10n.scanComparisonImproved(fmt)
            : l10n.scanComparisonWorsened(fmt);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          improved ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          size: 14,
          color: improved ? AppColors.neonGreen : Colors.redAccent,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: improved ? AppColors.neonGreen : Colors.redAccent,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChannelTile extends StatefulWidget {
  final ChannelRating rating;
  final Color accentColor;
  final bool isConnected;
  final bool isSibling;
  final bool isAllowedInRegion;
  final List<WifiNetwork> networksOnChannel;
  final List<WifiNetwork> allNetworks;
  final List<ChannelRating> allRatings;

  const _ChannelTile({
    super.key,
    required this.rating,
    required this.accentColor,
    this.isConnected = false,
    this.isSibling = false,
    this.isAllowedInRegion = true,
    this.networksOnChannel = const [],
    this.allNetworks = const [],
    this.allRatings = const [],
  });

  @override
  State<_ChannelTile> createState() => _ChannelTileState();
}

class _ChannelTileState extends State<_ChannelTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;
    final rating = widget.rating;
    final color = ratingScoreColor(rating.rating, primary);
    final fraction = (rating.rating / 10).clamp(0.0, 1.0);
    final hasNetworks = widget.networksOnChannel.isNotEmpty;

    final disallowed = !widget.isAllowedInRegion;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow.withValues(
          alpha: disallowed ? 0.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              widget.isConnected
                  ? AppColors.neonCyan.withValues(alpha: 0.7)
                  : color.withValues(alpha: disallowed ? 0.18 : 0.35),
          width: widget.isConnected ? 1.5 : 1,
        ),
      ),
      child: Opacity(
        opacity: disallowed ? 0.55 : 1.0,
        child: Column(
          children: [
            InkWell(
              onTap:
                  hasNetworks
                      ? () => setState(() => _expanded = !_expanded)
                      : null,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 38,
                      child: Text(
                        '${rating.channel}',
                        style: GoogleFonts.orbitron(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${rating.frequency} MHz',
                                style: GoogleFonts.rajdhani(
                                  color: onSurface.withValues(alpha: 0.68),
                                  fontSize: 13,
                                ),
                              ),
                              if (widget.isConnected) ...[
                                const SizedBox(width: 8),
                                _PulsingNowBadge(
                                  label:
                                      widget.isSibling
                                          ? l10n.dualBandSiblingLabel
                                          : l10n.currentChannelLabel,
                                ),
                              ],
                              if (rating.isDfs) ...[
                                const SizedBox(width: 8),
                                _DfsBadge(),
                              ],
                              if (disallowed) ...[
                                const SizedBox(width: 8),
                                Tooltip(
                                  message: l10n.channelIllegalTooltip,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: Colors.redAccent.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      l10n.channelIllegalBadge,
                                      style: GoogleFonts.orbitron(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              if (hasNetworks)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Text(
                                    '${widget.networksOnChannel.length}×',
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 11,
                                      color: onSurface.withValues(alpha: 0.55),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              Text(
                                _qualityString(l10n, rating.quality),
                                style: GoogleFonts.rajdhani(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: fraction,
                              backgroundColor: color.withValues(alpha: 0.12),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 46,
                      child: Text(
                        rating.rating.toStringAsFixed(1),
                        textAlign: TextAlign.right,
                        style: GoogleFonts.orbitron(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (hasNetworks)
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: onSurface.withValues(alpha: 0.45),
                      ),
                  ],
                ),
              ),
            ),
            if (_expanded && hasNetworks)
              _ChannelDrilldown(
                networks: widget.networksOnChannel,
                accentColor: color,
                allNetworks: widget.allNetworks,
                allRatings: widget.allRatings,
              ),
          ],
        ),
      ),
    );
  }
}

class _ChannelDrilldown extends StatelessWidget {
  final List<WifiNetwork> networks;
  final Color accentColor;
  final List<WifiNetwork> allNetworks;
  final List<ChannelRating> allRatings;
  const _ChannelDrilldown({
    required this.networks,
    required this.accentColor,
    this.allNetworks = const [],
    this.allRatings = const [],
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.04),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6, top: 2),
            child: Text(
              l10n.channelDrilldownHeader.toUpperCase(),
              style: GoogleFonts.orbitron(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: accentColor.withValues(alpha: 0.9),
              ),
            ),
          ),
          ...networks.map(
            (n) => _NetworkRow(
              network: n,
              crossBandSiblings:
                  allNetworks.isEmpty
                      ? const []
                      : crossBandSiblingsOf(n, allNetworks),
              allRatings: allRatings,
            ),
          ),
          if (networks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                l10n.channelDrilldownEmpty,
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NetworkRow extends StatelessWidget {
  final WifiNetwork network;
  final List<WifiNetwork> crossBandSiblings;
  final List<ChannelRating> allRatings;

  const _NetworkRow({
    required this.network,
    this.crossBandSiblings = const [],
    this.allRatings = const [],
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final width = network.channelWidthMhz ?? 20;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wifi_rounded,
                size: 13,
                color: _signalColor(network.signalStrength),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  network.ssid.isEmpty
                      ? l10n.hiddenSsidPlaceholder
                      : network.ssid,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        network.isHidden || network.ssid.isEmpty
                            ? onSurface.withValues(alpha: 0.55)
                            : onSurface.withValues(alpha: 0.9),
                    fontStyle:
                        network.ssid.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _miniBadge('$width MHz', AppColors.neonCyan),
              const SizedBox(width: 4),
              _miniBadge(
                _securityLabel(context, network.security),
                AppColors.neonPurple,
              ),
              const SizedBox(width: 6),
              Text(
                '${network.signalStrength} dBm',
                style: GoogleFonts.firaCode(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _signalColor(network.signalStrength),
                ),
              ),
            ],
          ),
          for (final sibling in crossBandSiblings)
            _CrossBandSiblingHint(sibling: sibling, allRatings: allRatings),
        ],
      ),
    );
  }

  Widget _miniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: GoogleFonts.orbitron(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _signalColor(int dbm) {
    if (dbm >= -55) return AppColors.neonGreen;
    if (dbm >= -75) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _securityLabel(BuildContext context, SecurityType s) {
    switch (s) {
      case SecurityType.open:
        return context.l10n.wifiSecurityOpen;
      case SecurityType.wep:
        return 'WEP';
      case SecurityType.wpa:
        return 'WPA';
      case SecurityType.wpa2:
        return 'WPA2';
      case SecurityType.wpa3:
        return 'WPA3';
      case SecurityType.unknown:
        return '?';
    }
  }
}

// ── Channel Bonding Section ──────────────────────────────────────────

class _ChannelBondingSection extends StatefulWidget {
  final List<ChannelRating> ratings;
  final List<WifiNetwork> networks;
  final Color accentColor;

  const _ChannelBondingSection({
    required this.ratings,
    required this.networks,
    required this.accentColor,
  });

  @override
  State<_ChannelBondingSection> createState() => _ChannelBondingSectionState();
}

class _ChannelBondingSectionState extends State<_ChannelBondingSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final bandChannels = widget.ratings.map((r) => r.channel).toSet();
    final bonded =
        widget.networks
            .where(
              (n) =>
                  bandChannels.contains(n.channel) &&
                  n.channelWidthMhz != null &&
                  n.channelWidthMhz! > 20,
            )
            .toList();

    if (bonded.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: widget.accentColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.channelBondingHeader(bonded.length),
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.accentColor,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 4),
                InfoIconButton(
                  title: l10n.channelBondingTitle,
                  body: l10n.channelBondingDesc,
                  color: widget.accentColor,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          ...bonded.map((n) {
            final width = n.channelWidthMhz!;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    l10n.channelLabel(n.channel),
                    style: GoogleFonts.orbitron(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: widget.accentColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    n.ssid.isEmpty ? l10n.hiddenSsidLabel : n.ssid,
                    style: GoogleFonts.rajdhani(
                      fontSize: 13,
                      color: onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      l10n.bandwidthLabel(width),
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: widget.accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

/// Compact chip indicating whether the channel-rating distribution moved
/// significantly since the previous scan — a proxy for AP density volatility.
class _DensityTrendChip extends StatelessWidget {
  final List<ChannelRating> ratings;
  final Map<int, double> previousRatings;
  const _DensityTrendChip({
    required this.ratings,
    required this.previousRatings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (previousRatings.isEmpty) return const SizedBox.shrink();

    double maxAbsDelta = 0;
    for (final r in ratings) {
      final prev = previousRatings[r.channel];
      if (prev == null) continue;
      final d = (r.rating - prev).abs();
      if (d > maxAbsDelta) maxAbsDelta = d;
    }
    final volatile = maxAbsDelta >= 1.5;
    final label =
        volatile
            ? l10n.densityTrendVolatile(maxAbsDelta.toStringAsFixed(1))
            : l10n.densityTrendStable;
    final color = volatile ? Colors.orangeAccent : AppColors.neonGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            volatile ? Icons.show_chart_rounded : Icons.horizontal_rule_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.rajdhani(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact pill that opens a full info bottom sheet when tapped — used for
/// contextual education chips (AFC, mesh, band-steering, …).
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String sheetTitle;
  final String sheetBody;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.sheetTitle,
    required this.sheetBody,
  });

  void _openSheet(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => GlassmorphicContainer(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            borderColor: color,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Icon(icon, color: color, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          sheetTitle,
                          style: GoogleFonts.orbitron(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: color,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    sheetBody,
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      height: 1.55,
                      color: onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openSheet(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.32)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: color.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner showing the user's currently-broadcast channel and the gain they
/// would get by switching to the recommended one.
class _CurrentChannelBanner extends StatelessWidget {
  final ChannelRating current;
  final ChannelRating recommended;
  final Color accentColor;
  final bool isSibling;
  final String bandLabel;

  const _CurrentChannelBanner({
    required this.current,
    required this.recommended,
    required this.accentColor,
    this.isSibling = false,
    this.bandLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final delta = recommended.rating - current.rating;
    final isOptimal = current.channel == recommended.channel || delta < 0.5;
    final color =
        isSibling
            ? accentColor
            : (isOptimal ? AppColors.neonGreen : AppColors.neonCyan);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSibling
                    ? Icons.swap_calls_rounded
                    : isOptimal
                    ? Icons.check_circle_rounded
                    : Icons.swap_horiz_rounded,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSibling
                      ? l10n.dualBandSiblingBanner(
                          bandLabel,
                          l10n.channelWithRating(
                            current.channel,
                            current.rating.toStringAsFixed(1),
                          ),
                        )
                      : l10n.currentChannelBannerYouAreOn(
                          l10n.channelWithRating(
                            current.channel,
                            current.rating.toStringAsFixed(1),
                          ),
                        ),
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isOptimal
                ? l10n.currentChannelBannerOptimal
                : l10n.currentChannelBannerSwitchTo(
                  l10n.channelLabel(recommended.channel),
                  delta.toStringAsFixed(1),
                ),
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              color: onSurface.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

/// "ŞİMDİ" badge with a soft breathing glow so users see at a glance which
/// channel their router is currently broadcasting on.
class _PulsingNowBadge extends StatefulWidget {
  final String label;
  const _PulsingNowBadge({required this.label});

  @override
  State<_PulsingNowBadge> createState() => _PulsingNowBadgeState();
}

class _PulsingNowBadgeState extends State<_PulsingNowBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          // 0..1 ease-in-out via Curves.easeInOut.
          final t = Curves.easeInOut.transform(_ctrl.value);
          final glow = 4.0 + 10.0 * t;
          final glowAlpha = 0.25 + 0.45 * t;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha: 0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: glowAlpha),
                  blurRadius: glow,
                ),
              ],
            ),
            child: Text(
              widget.label,
              style: GoogleFonts.orbitron(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.neonCyan,
                letterSpacing: 0.5,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Inline hint shown under a network row when the same router is also
/// broadcasting on a different band — tap to jump to that band's tab.
class _CrossBandSiblingHint extends StatelessWidget {
  final WifiNetwork sibling;
  final List<ChannelRating> allRatings;

  const _CrossBandSiblingHint({
    required this.sibling,
    required this.allRatings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final ratingIdx = allRatings.indexWhere(
      (r) =>
          r.channel == sibling.channel &&
          (r.frequency - sibling.frequency).abs() <= 5,
    );
    final ratingText =
        ratingIdx < 0 ? '—' : allRatings[ratingIdx].rating.toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(21, 2, 0, 0),
      child: InkWell(
        onTap: () {
          final controller = DefaultTabController.maybeOf(context);
          controller?.animateTo(
            bandIndex(bandFromFrequency(sibling.frequency)),
          );
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: Row(
            children: [
              Icon(
                Icons.swap_horiz_rounded,
                size: 12,
                color: onSurface.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l10n.crossBandSiblingHint(
                    bandShortLabel(bandFromFrequency(sibling.frequency)),
                    '${sibling.channel}',
                    ratingText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rajdhani(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 14,
                color: onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// DFS rozeti — dokunulduğunda detaylı açıklama bottomsheet'i açar.
class _DfsBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Tooltip(
      message: l10n.dfsBadgeTooltip,
      child: InkWell(
        onTap: () => _showDfsInfo(context),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orangeAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.orangeAccent.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.dfsBadgeLabel,
                style: GoogleFonts.orbitron(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 3),
              Icon(
                Icons.info_outline_rounded,
                size: 10,
                color: Colors.orangeAccent.withValues(alpha: 0.85),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDfsInfo(BuildContext context) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => GlassmorphicContainer(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            borderColor: Colors.orangeAccent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.radar_rounded,
                      color: Colors.orangeAccent,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.dfsInfoTitle,
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.dfsInfoBody,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    height: 1.5,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

String _regionLabel(dynamic l10n, WifiRegion r) {
  switch (r) {
    case WifiRegion.us:
      return l10n.regionUS;
    case WifiRegion.eu:
      return l10n.regionEU;
    case WifiRegion.jp:
      return l10n.regionJP;
    case WifiRegion.world:
      return l10n.regionWorld;
  }
}

String _qualityString(dynamic l10n, ChannelQuality quality) {
  switch (quality) {
    case ChannelQuality.excellent:
      return l10n.qualityExcellent;
    case ChannelQuality.veryGood:
      return l10n.qualityVeryGood;
    case ChannelQuality.good:
      return l10n.qualityGood;
    case ChannelQuality.fair:
      return l10n.qualityFair;
    case ChannelQuality.congested:
      return l10n.qualityCongested;
  }
}
