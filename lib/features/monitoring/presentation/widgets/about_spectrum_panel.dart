import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';

/// Expandable info panel that explains "What is the spectrum optimization?",
/// "What is it for?" and "How does it work?" — written for users who have
/// never encountered the concept before.
class AboutSpectrumPanel extends StatelessWidget {
  const AboutSpectrumPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = AppColors.neonPurple;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Theme(
        data: Theme.of(
          context,
        ).copyWith(dividerColor: Colors.transparent, splashColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: color,
          collapsedIconColor: color.withValues(alpha: 0.7),
          leading: Icon(Icons.info_outline_rounded, color: color, size: 22),
          title: Text(
            l10n.aboutSpectrumTitle,
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          children: [
            _Section(
              header: l10n.aboutSpectrumWhatHeader,
              body: l10n.aboutSpectrumWhatBody,
              icon: Icons.help_outline_rounded,
              color: color,
              onSurface: onSurface,
            ),
            const SizedBox(height: 12),
            _Section(
              header: l10n.aboutSpectrumWhyHeader,
              body: l10n.aboutSpectrumWhyBody,
              icon: Icons.bolt_rounded,
              color: AppColors.neonCyan,
              onSurface: onSurface,
            ),
            const SizedBox(height: 12),
            _Section(
              header: l10n.aboutSpectrumHowHeader,
              body: l10n.aboutSpectrumHowBody,
              icon: Icons.tune_rounded,
              color: AppColors.neonGreen,
              onSurface: onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String header;
  final String body;
  final IconData icon;
  final Color color;
  final Color onSurface;

  const _Section({
    required this.header,
    required this.body,
    required this.icon,
    required this.color,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              header,
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: GoogleFonts.rajdhani(
            color: onSurface.withValues(alpha: 0.82),
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
