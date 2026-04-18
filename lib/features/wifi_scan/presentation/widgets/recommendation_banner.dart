import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../domain/entities/scan_snapshot.dart';
import '../../domain/entities/wifi_band.dart';

class RecommendationBanner extends StatelessWidget {
  final ScanSnapshot snapshot;
  final VoidCallback onDismiss;

  const RecommendationBanner({
    super.key,
    required this.snapshot,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.bandStats.isEmpty) return const SizedBox.shrink();

    final sortedBands = List.of(snapshot.bandStats)..sort(
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
                    AppLocalizations.of(
                      context,
                    )!.recommendationTip(channels, bandName),
                    style: GoogleFonts.rajdhani(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                InfoIconButton(
                  title: AppLocalizations.of(context)!.channelInterferenceTitle,
                  body:
                      AppLocalizations.of(
                        context,
                      )!.channelInterferenceDescription,
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
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
