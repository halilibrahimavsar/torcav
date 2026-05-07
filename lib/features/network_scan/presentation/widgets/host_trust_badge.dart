import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/host_trust_assessment.dart';

/// Compact pill (green / amber / red) showing a host's trust verdict.
///
/// Tap to expand the reason list in a bottom sheet. Designed to be
/// embedded in `host_device_card.dart` next to the IP / vendor row.
class HostTrustBadge extends StatelessWidget {
  const HostTrustBadge({super.key, required this.assessment});

  final HostTrustAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(assessment.level);
    return InkWell(
      onTap: () => _showDetails(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: palette.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: palette.withValues(alpha: 0.55)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon(assessment.level), size: 12, color: palette),
            const SizedBox(width: 4),
            Text(
              _label(assessment.level),
              style: GoogleFonts.orbitron(
                color: palette,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _HostTrustSheet(assessment: assessment),
    );
  }

  Color _palette(HostTrustLevel l) => switch (l) {
    HostTrustLevel.safe => Colors.greenAccent,
    HostTrustLevel.caution => Colors.orangeAccent,
    HostTrustLevel.risky => Colors.redAccent,
  };

  IconData _icon(HostTrustLevel l) => switch (l) {
    HostTrustLevel.safe => Icons.verified_user_rounded,
    HostTrustLevel.caution => Icons.shield_outlined,
    HostTrustLevel.risky => Icons.gpp_bad_rounded,
  };

  String _label(HostTrustLevel l) => switch (l) {
    HostTrustLevel.safe => 'SAFE',
    HostTrustLevel.caution => 'CAUTION',
    HostTrustLevel.risky => 'RISKY',
  };
}

class _HostTrustSheet extends StatelessWidget {
  const _HostTrustSheet({required this.assessment});

  final HostTrustAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scroll) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'WHY IS THIS ${_levelText(assessment.level)}?',
              style: GoogleFonts.orbitron(
                color: theme.colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              assessment.headline,
              style: GoogleFonts.rajdhani(
                color: theme.colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            if (assessment.reasons.isEmpty)
              Text(
                'No specific concerns logged for this device. The badge '
                'reflects an aggregate score.',
                style: GoogleFonts.rajdhani(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            for (final reason in assessment.reasons)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reason.summary,
                        style: GoogleFonts.rajdhani(
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                      if (reason.remediation != null &&
                          reason.remediation!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'WHAT TO DO',
                          style: GoogleFonts.orbitron(
                            color: theme.colorScheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reason.remediation!,
                          style: GoogleFonts.rajdhani(
                            color: theme.colorScheme.onSurface,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _levelText(HostTrustLevel l) => switch (l) {
    HostTrustLevel.safe => 'SAFE',
    HostTrustLevel.caution => 'CAUTION',
    HostTrustLevel.risky => 'RISKY',
  };
}
