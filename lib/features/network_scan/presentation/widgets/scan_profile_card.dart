import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/network_scan_profile.dart';

/// Compact card that explains what the currently selected [NetworkScanProfile]
/// actually does — estimated duration, sweep parallelism and probe depth — so
/// the fast / balanced / aggressive choice has a visible effect.
class ScanProfileCard extends StatelessWidget {
  const ScanProfileCard({super.key, required this.profile});

  final NetworkScanProfile profile;

  /// Estimated wall-clock duration for a /24 sweep, mirroring the parallelism
  /// and timeout tuning in `arp_data_source.dart`.
  String get _eta {
    switch (profile) {
      case NetworkScanProfile.fast:
        return '~3-5 s';
      case NetworkScanProfile.balanced:
        return '~8-12 s';
      case NetworkScanProfile.aggressive:
        return '~20-40 s';
    }
  }

  /// Concurrent ping-sweep batches used by the profile.
  String get _parallelism {
    switch (profile) {
      case NetworkScanProfile.fast:
        return '50×';
      case NetworkScanProfile.balanced:
        return '30×';
      case NetworkScanProfile.aggressive:
        return '15×';
    }
  }

  String _description(BuildContext context) {
    switch (profile) {
      case NetworkScanProfile.fast:
        return context.l10n.infoScanProfileFastDesc;
      case NetworkScanProfile.balanced:
        return context.l10n.infoScanProfileBalancedDesc;
      case NetworkScanProfile.aggressive:
        return context.l10n.infoScanProfileAggressiveDesc;
    }
  }

  IconData get _icon {
    switch (profile) {
      case NetworkScanProfile.fast:
        return Icons.bolt_rounded;
      case NetworkScanProfile.balanced:
        return Icons.tune_rounded;
      case NetworkScanProfile.aggressive:
        return Icons.travel_explore_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (profile) {
      NetworkScanProfile.fast => scheme.tertiary,
      NetworkScanProfile.balanced => scheme.primary,
      NetworkScanProfile.aggressive => scheme.error,
    };

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  profile.name.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                _Metric(icon: Icons.timer_outlined, value: _eta, color: color),
                const SizedBox(width: 10),
                _Metric(
                  icon: Icons.dynamic_feed_rounded,
                  value: _parallelism,
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _description(context),
              style: GoogleFonts.rajdhani(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 3),
        Text(
          value,
          style: GoogleFonts.sourceCodePro(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
