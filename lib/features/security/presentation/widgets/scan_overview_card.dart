import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import '../bloc/security_bloc.dart';

class ScanOverviewCard extends StatelessWidget {
  final SecurityScanSummary summary;

  const ScanOverviewCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return StaggeredEntry(
      delay: const Duration(milliseconds: 300),
      child: Row(
        children: [
          _MiniStatChip(
            label: 'APs',
            value: '${summary.totalNetworks}',
            color: scheme.primary,
            index: 0,
          ),
          const SizedBox(width: 8),
          _MiniStatChip(
            label: 'OPEN',
            value: '${summary.openCount}',
            color: summary.openCount > 0 ? scheme.error : scheme.tertiary,
            index: 1,
          ),
          const SizedBox(width: 8),
          _MiniStatChip(
            label: 'WPS',
            value: '${summary.wpsCount}',
            color:
                summary.wpsCount > 0
                    ? const Color(0xFFFFB300)
                    : scheme.tertiary,
            index: 2,
          ),
          const SizedBox(width: 8),
          _MiniStatChip(
            label: 'WEP',
            value: '${summary.wepCount}',
            color: summary.wepCount > 0 ? scheme.error : scheme.tertiary,
            index: 3,
          ),
        ],
      ),
    );
  }
}

class _MiniStatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final int index;

  const _MiniStatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StaggeredEntry(
        delay: Duration(milliseconds: 100 + (index * 60)),
        child: GlassmorphicContainer(
          borderColor: color.withValues(alpha: 0.3),
          backgroundColor: color.withValues(alpha: 0.02),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeonText(
                value,
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
                glowRadius: 6,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.rajdhani(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
