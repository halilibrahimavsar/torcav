import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/diagnosis_result.dart';
import '../../domain/entities/root_cause_category.dart';

class PrimaryCauseCard extends StatelessWidget {
  const PrimaryCauseCard({super.key, required this.result});

  final DiagnosisResult result;

  @override
  Widget build(BuildContext context) {
    final category = result.primaryCause;
    final palette = _palette(category);
    final theme = Theme.of(context);
    final headline = _headline(category);
    final detail = _detail(category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.withValues(alpha: 0.18),
            palette.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(color: palette.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: palette.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: palette),
                ),
                child: Icon(_icon(category), color: palette),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  headline,
                  style: GoogleFonts.orbitron(
                    color: palette,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            detail,
            style: GoogleFonts.rajdhani(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          if (result.allEvidence.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              result.allEvidence.first.metricLabel,
              style: GoogleFonts.shareTechMono(
                color: palette,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _icon(RootCauseCategory c) => switch (c) {
    RootCauseCategory.weakSignal => Icons.signal_wifi_bad_rounded,
    RootCauseCategory.crowdedChannel => Icons.graphic_eq_rounded,
    RootCauseCategory.bufferbloat => Icons.network_check_rounded,
    RootCauseCategory.ispSlow => Icons.cloud_off_rounded,
    RootCauseCategory.slowDns => Icons.dns_rounded,
    RootCauseCategory.healthy => Icons.check_circle_rounded,
  };

  Color _palette(RootCauseCategory c) => switch (c) {
    RootCauseCategory.weakSignal => Colors.orangeAccent,
    RootCauseCategory.crowdedChannel => AppColors.neonPurple,
    RootCauseCategory.bufferbloat => Colors.redAccent,
    RootCauseCategory.ispSlow => Colors.indigoAccent,
    RootCauseCategory.slowDns => Colors.cyanAccent,
    RootCauseCategory.healthy => Colors.greenAccent,
  };

  String _headline(RootCauseCategory c) => switch (c) {
    RootCauseCategory.weakSignal => 'WEAK SIGNAL',
    RootCauseCategory.crowdedChannel => 'CROWDED CHANNEL',
    RootCauseCategory.bufferbloat => 'BUFFERBLOAT',
    RootCauseCategory.ispSlow => 'ISP IS SLOW',
    RootCauseCategory.slowDns => 'SLOW DNS',
    RootCauseCategory.healthy => 'NETWORK HEALTHY',
  };

  String _detail(RootCauseCategory c) => switch (c) {
    RootCauseCategory.weakSignal =>
      'Your device is far from the router or has too many walls in the way. '
          'Move closer or add a mesh node in this area.',
    RootCauseCategory.crowdedChannel =>
      'Several neighbouring access points are sharing your channel. '
          'Switching to a less crowded channel — or to 5/6 GHz — should help.',
    RootCauseCategory.bufferbloat =>
      'Latency spikes when the link is busy. Enable QoS / SQM on your router '
          'or update its firmware so video calls and games stay responsive.',
    RootCauseCategory.ispSlow =>
      'Your Wi-Fi link is healthy but the download speed is low. '
          'The bottleneck is most likely your internet plan or upstream provider.',
    RootCauseCategory.slowDns =>
      'Names take too long to resolve. Switching DNS provider or enabling '
          'DoH/DoT typically removes the delay.',
    RootCauseCategory.healthy =>
      'No bottleneck reached an alert threshold. Your link looks fine right now.',
  };
}
