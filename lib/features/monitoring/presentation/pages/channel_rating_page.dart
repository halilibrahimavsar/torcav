import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../features/wifi_scan/domain/entities/scan_request.dart';
import '../../../../features/wifi_scan/domain/entities/wifi_network.dart';
import '../../../../features/wifi_scan/domain/entities/channel_rating.dart';
import '../../../../features/wifi_scan/presentation/bloc/wifi_scan_bloc.dart';
import '../bloc/monitoring_bloc.dart';
import '../widgets/channel_spectral_chart.dart';

class ChannelRatingPage extends StatelessWidget {
  final List<WifiNetwork> networks;
  final ScanRequest? request;

  const ChannelRatingPage({super.key, required this.networks, this.request});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<MonitoringBloc>()..add(AnalyzeChannels(networks)),
      child: _ChannelRatingView(request: request),
    );
  }
}

class _ChannelRatingView extends StatelessWidget {
  final ScanRequest? request;
  const _ChannelRatingView({this.request});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.channelRatingTitle,
            style: GoogleFonts.orbitron(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            BlocBuilder<WifiScanBloc, WifiScanState>(
              builder: (context, state) {
                if (state is WifiScanLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: l10n.refreshScanTooltip,
                  onPressed: () {
                    context.read<WifiScanBloc>().add(
                      WifiScanRefreshed(
                        request: request ?? const ScanRequest(),
                      ),
                    );
                  },
                );
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
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
            ],
          ),
        ),
        body: BlocBuilder<MonitoringBloc, MonitoringState>(
          builder: (context, state) {
            if (state is MonitoringLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChannelAnalysisReady) {
              final ratings24 =
                  state.ratings.where((r) => r.frequency < 4000).toList()
                    ..sort((a, b) => b.rating.compareTo(a.rating));
              final ratings5 =
                  state.ratings
                      .where((r) => r.frequency >= 4000 && r.frequency < 6000)
                      .toList()
                    ..sort((a, b) => b.rating.compareTo(a.rating));
              final ratings6 =
                  state.ratings.where((r) => r.frequency >= 6000).toList()
                    ..sort((a, b) => b.rating.compareTo(a.rating));

              return TabBarView(
                children: [
                  _BandView(
                    ratings: ratings24,
                    historicalAverages: state.historicalAverages,
                    bandLabel: l10n.band24Ghz,
                    accentColor: const Color(0xFF00E5FF),
                    emptyHint: l10n.no24GhzChannels,
                  ),
                  _BandView(
                    ratings: ratings5,
                    historicalAverages: state.historicalAverages,
                    bandLabel: l10n.band5Ghz,
                    accentColor: const Color(0xFF76FF03),
                    emptyHint: l10n.no5GhzChannels,
                  ),
                  _BandView(
                    ratings: ratings6,
                    historicalAverages: state.historicalAverages,
                    bandLabel: l10n.band6Ghz,
                    accentColor: const Color(0xFFEEFF41),
                    emptyHint: l10n.no6GhzChannels,
                  ),
                ],
              );
            } else if (state is MonitoringFailure) {
              return Center(
                child: Text(
                  '${l10n.errorLabel}: ${state.message}',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }
            return Center(child: Text(l10n.analyzing));
          },
        ),
      ),
    );
  }
}

class _BandView extends StatelessWidget {
  final List<ChannelRating> ratings;
  final Map<int, double> historicalAverages;
  final String bandLabel;
  final Color accentColor;
  final String emptyHint;

  const _BandView({
    required this.ratings,
    required this.historicalAverages,
    required this.bandLabel,
    required this.accentColor,
    required this.emptyHint,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    if (ratings.isEmpty) {
      return Center(
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
      );
    }

    final best = ratings.first;
    // Find consistently best channel from history in this band
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
                Text(
                  'CONSISTENTLY BEST CHANNEL',
                  style: GoogleFonts.rajdhani(
                    fontSize: 11,
                    color: accentColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Channel $channel',
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
                'Avg Score',
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
    final l10n = AppLocalizations.of(context)!;
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
                Text(
                  l10n.recommendedChannel,
                  style: GoogleFonts.rajdhani(
                    color: accentColor,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
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
                  '${rating.rating.toStringAsFixed(1)}/10 · ${rating.recommendation}',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final color = _getColorForRating(rating.rating);
    final fraction = (rating.rating / 10).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color:
            isDark
                ? const Color(0xFF0F172A)
                : Theme.of(context).colorScheme.surface,
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
                    const Spacer(),
                    Text(
                      rating.recommendation,
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

  Color _getColorForRating(double r) {
    if (r >= 8) return AppTheme.primaryColor;
    if (r >= 5) return Colors.orange;
    return Colors.red;
  }
}
