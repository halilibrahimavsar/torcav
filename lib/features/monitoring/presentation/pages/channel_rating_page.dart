import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../features/wifi_scan/domain/entities/wifi_network.dart';
import '../../domain/entities/channel_rating.dart';
import '../bloc/monitoring_bloc.dart';

class ChannelRatingPage extends StatelessWidget {
  final List<WifiNetwork> networks;

  const ChannelRatingPage({super.key, required this.networks});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<MonitoringBloc>()..add(AnalyzeChannels(networks)),
      child: const _ChannelRatingView(),
    );
  }
}

class _ChannelRatingView extends StatelessWidget {
  const _ChannelRatingView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
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
          bottom: TabBar(
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.white38,
            labelStyle: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            tabs: [Tab(text: l10n.band24Ghz), Tab(text: l10n.band5Ghz)],
          ),
        ),
        body: BlocBuilder<MonitoringBloc, MonitoringState>(
          builder: (context, state) {
            if (state is MonitoringLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChannelAnalysisReady) {
              final r24 =
                  state.ratings.where((r) => r.frequency < 3000).toList()
                    ..sort((a, b) => b.rating.compareTo(a.rating));
              final r5 =
                  state.ratings.where((r) => r.frequency >= 5000).toList()
                    ..sort((a, b) => b.rating.compareTo(a.rating));
              return TabBarView(
                children: [
                  _BandView(
                    ratings: r24,
                    bandLabel: l10n.band24Ghz,
                    accentColor: const Color(0xFF00E5FF),
                    emptyHint: l10n.no24GhzChannels,
                  ),
                  _BandView(
                    ratings: r5,
                    bandLabel: l10n.band5Ghz,
                    accentColor: const Color(0xFF76FF03),
                    emptyHint: l10n.no5GhzChannels,
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
  final String bandLabel;
  final Color accentColor;
  final String emptyHint;

  const _BandView({
    required this.ratings,
    required this.bandLabel,
    required this.accentColor,
    required this.emptyHint,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (ratings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white24, size: 48),
            const SizedBox(height: 12),
            Text(
              emptyHint,
              style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Top recommendation
    final best = ratings.first;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Best channel highlight
        Container(
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
                    '${best.channel}',
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
                      l10n.channelInfo(best.channel, best.frequency),
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${best.rating.toStringAsFixed(1)}/10 · ${best.recommendation}',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.star_rounded, color: accentColor, size: 28),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Text(
          l10n.bandChannels(bandLabel),
          style: GoogleFonts.orbitron(
            color: Colors.white70,
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),

        // All channels
        ...ratings.map(
          (r) => _ChannelTile(rating: r, accentColor: accentColor),
        ),
      ],
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final ChannelRating rating;
  final Color accentColor;

  const _ChannelTile({required this.rating, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final color = _getColorForRating(rating.rating);
    final fraction = (rating.rating / 10).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          // Channel number
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

          // Bar + info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${rating.frequency} MHz',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white54,
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

          // Score
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
