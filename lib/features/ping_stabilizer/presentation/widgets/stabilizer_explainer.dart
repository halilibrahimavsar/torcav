import 'package:torcav/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Explains, in plain language, what the on-device Ping Stabilizer does
/// and the trade-offs the user should understand before turning it on.
///
/// Shown on the Ping Stabilizer page header and (collapsed) on the dashboard
/// quick-access card. Honest about the limits — no marketing claims about
/// "boosting" pings beyond what your ISP gives you.
class StabilizerExplainer extends StatelessWidget {
  final bool startCollapsed;

  const StabilizerExplainer({super.key, this.startCollapsed = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Card(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: !startCollapsed,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Icon(Icons.info_outline_rounded, color: scheme.primary),
          title: Text(
            l10n.howPingStabilizerWorksTitle,
            style: GoogleFonts.orbitron(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
              letterSpacing: 1.2,
            ),
          ),
          subtitle: Text(
            l10n.stabilizerExplainerSubtitle,
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurfaceVariant,
            ),
          ),
          children: [
            _ExplainerSection(
              icon: Icons.bolt_rounded,
              title: l10n.whatItDoesTitle,
              bullets: [
                l10n.whatItDoesBullet1,
                l10n.whatItDoesBullet2,
                l10n.whatItDoesBullet3,
                l10n.whatItDoesBullet4,
              ],
            ),
            const SizedBox(height: 12),
            _ExplainerSection(
              icon: Icons.warning_amber_rounded,
              title: l10n.whatItDoesNotTitle,
              bullets: [
                l10n.whatItDoesNotBullet1,
                l10n.whatItDoesNotBullet2,
                l10n.whatItDoesNotBullet3,
              ],
            ),
            const SizedBox(height: 12),
            _ExplainerSection(
              icon: Icons.shield_outlined,
              title: l10n.risksAndThingsToKnowTitle,
              bullets: [
                l10n.risksBullet1,
                l10n.risksBullet2,
                l10n.risksBullet3,
                l10n.risksBullet4,
                l10n.risksBullet5,
                l10n.risksBullet6,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplainerSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> bullets;

  const _ExplainerSection({
    required this.icon,
    required this.title,
    required this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: scheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...bullets.map(
          (b) => Padding(
            padding: const EdgeInsets.only(left: 26, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ',
                    style:
                        TextStyle(color: scheme.onSurfaceVariant, height: 1.4)),
                Expanded(
                  child: Text(
                    b,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
