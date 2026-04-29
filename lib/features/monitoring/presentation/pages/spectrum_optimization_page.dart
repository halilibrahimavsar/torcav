import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../wifi_scan/domain/entities/channel_rating.dart';
import '../../../wifi_scan/domain/entities/channel_rating_sample.dart';
import '../../../wifi_scan/domain/entities/scan_request.dart';
import '../../../wifi_scan/domain/entities/wifi_network.dart';
import '../../../wifi_scan/domain/repositories/channel_rating_repository.dart';
import '../../../wifi_scan/presentation/bloc/wifi_scan_bloc.dart';
import '../bloc/monitoring_bloc.dart';
import '../widgets/about_spectrum_panel.dart';
import '../widgets/channel_history_chart.dart';
import '../widgets/channel_spectral_chart.dart';
import '../widgets/router_admin_guide_card.dart';

/// Operations Hub entry-point for the Spectrum / Channel Optimization tool.
///
/// Triggers a fresh Wi-Fi scan on open and pipes the result into
/// [MonitoringBloc] for channel rating analysis. Hosts a 4-tab view:
/// 2.4 GHz · 5 GHz · 6 GHz · History.
class SpectrumOptimizationPage extends StatelessWidget {
  const SpectrumOptimizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.I<MonitoringBloc>()),
        BlocProvider.value(value: GetIt.I<WifiScanBloc>()),
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
  static const _scanRequest = ScanRequest();

  @override
  void initState() {
    super.initState();
    // Trigger a scan as soon as the page mounts. If the bloc already has a
    // recent loaded snapshot, the BlocListener below will analyse it
    // immediately; otherwise the listener fires when the new scan finishes.
    final scanBloc = context.read<WifiScanBloc>();
    final state = scanBloc.state;
    if (state is WifiScanLoaded) {
      _analyse(state);
    }
    scanBloc.add(const WifiScanRefreshed(request: _scanRequest));
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
    return BlocListener<WifiScanBloc, WifiScanState>(
      listenWhen:
          (prev, curr) => curr is WifiScanLoaded && prev != curr,
      listener: (context, state) {
        if (state is WifiScanLoaded) _analyse(state);
      },
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
                        const WifiScanRefreshed(request: _scanRequest),
                      );
                    },
                  );
                },
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
                  accentColor:
                      [
                        const Color(0xFF00E5FF),
                        const Color(0xFF76FF03),
                        const Color(0xFFEEFF41),
                      ][band],
                  emptyHint:
                      [
                        l10n.no24GhzChannels,
                        l10n.no5GhzChannels,
                        l10n.no6GhzChannels,
                      ][band],
                ),
              const _HistoryTab(),
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

  const _BandTab({
    required this.band,
    required this.bandLabel,
    required this.accentColor,
    required this.emptyHint,
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
            message: '${l10n.errorLabel}: ${state.message}',
            onRetry: () {
              final s = context.read<WifiScanBloc>().state;
              if (s is WifiScanLoaded) {
                final networks =
                    s.snapshot.networks
                        .map((n) => n.toWifiNetwork())
                        .toList();
                context.read<MonitoringBloc>().add(AnalyzeChannels(networks));
              }
            },
          );
        }
        if (state is ChannelAnalysisReady) {
          final ratings =
              switch (band) {
                  0 => state.ratings.where((r) => r.frequency < 4000),
                  1 => state.ratings.where(
                    (r) => r.frequency >= 5000 && r.frequency < 5925,
                  ),
                  _ => state.ratings.where((r) => r.frequency >= 5925),
                }.toList()
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
            historicalAverages: state.historicalAverages,
            bandLabel: bandLabel,
            accentColor: accentColor,
            emptyHint: emptyHint,
            networks: networks,
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
  const _HistoryTab();

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  List<ChannelRatingSample>? _samples;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final repo = GetIt.I<ChannelRatingRepository>();
    final result = await repo.getHistory(limit: const Duration(days: 7));
    if (mounted) {
      setState(() {
        _samples = result.getOrElse(() => []);
        _loading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Theme.of(ctx).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'CLEAR CHANNEL HISTORY',
              style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Delete all channel rating records? This cannot be undone.',
              style: GoogleFonts.rajdhani(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'CANCEL',
                  style: GoogleFonts.orbitron(fontSize: 10),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'DELETE ALL',
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
      await GetIt.I<ChannelRatingRepository>().clearHistory();
      _reload();
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
                    'CLEAR HISTORY',
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
            StaggeredEntry(child: ChannelHistoryChart(samples: _samples ?? [])),
          ],
        ),
      ),
    );
  }
}

// ── Band view (per-band content rendered inside each tab) ─────────────

class _BandView extends StatelessWidget {
  final List<ChannelRating> ratings;
  final Map<int, double> historicalAverages;
  final String bandLabel;
  final Color accentColor;
  final String emptyHint;
  final List<WifiNetwork> networks;

  const _BandView({
    required this.ratings,
    required this.historicalAverages,
    required this.bandLabel,
    required this.accentColor,
    required this.emptyHint,
    required this.networks,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;

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

    final best = ratings.first;
    final bandChannels = ratings.map((r) => r.channel).toSet();
    final historicalBest =
        historicalAverages.entries
            .where((e) => bandChannels.contains(e.key))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final consistentlyBest =
        historicalBest.isNotEmpty ? historicalBest.first : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const AboutSpectrumPanel(),
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
        _RecommendationCard(rating: best, accentColor: accentColor),
        const SizedBox(height: 16),
        const RouterAdminGuideCard(),
        Text(
          l10n.bandChannels(bandLabel),
          style: GoogleFonts.orbitron(
            color: onSurface.withValues(alpha: 0.82),
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        ...ratings.map(
          (r) => _ChannelTile(rating: r, accentColor: accentColor),
        ),
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

  const _RecommendationCard({required this.rating, required this.accentColor});

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
              ],
            ),
          ),
          Icon(Icons.star_rounded, color: accentColor, size: 28),
        ],
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final ChannelRating rating;
  final Color accentColor;

  const _ChannelTile({required this.rating, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;
    final color = _getColorForRating(rating.rating, primary);
    final fraction = (rating.rating / 10).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
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
                    if (rating.isDfs) ...[
                      const SizedBox(width: 8),
                      _DfsBadge(),
                    ],
                    const Spacer(),
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
        ],
      ),
    );
  }

  Color _getColorForRating(double r, Color primary) {
    if (r >= 8) return primary;
    if (r >= 5) return Colors.orange;
    return Colors.red;
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
                    'CH ${n.channel}',
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
                      '$width MHz',
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
