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
    const color = AppColors.neonPurple;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      // ListTile ink'i en yakın Material'e çizer; dekorlu Container ile tile
      // arasına şeffaf Material koymazsak framework assertion fırlatır.
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            iconColor: color,
            collapsedIconColor: color.withValues(alpha: 0.7),
            leading: const Icon(
              Icons.info_outline_rounded,
              color: color,
              size: 22,
            ),
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
              const SizedBox(height: 16),
              // ── Advanced topics ────────────────────────────────────
              Text(
                l10n.advancedTopicsHeader.toUpperCase(),
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 8),
              _AdvancedTile(
                icon: Icons.account_tree_rounded,
                title: l10n.advancedMeshTitle,
                body: l10n.advancedMeshBody,
                color: AppColors.neonCyan,
                onSurface: onSurface,
              ),
              const SizedBox(height: 6),
              _AdvancedTile(
                icon: Icons.swap_horiz_rounded,
                title: l10n.advancedBandSteeringTitle,
                body: l10n.advancedBandSteeringBody,
                color: AppColors.neonPurple,
                onSurface: onSurface,
              ),
              const SizedBox(height: 6),
              _AdvancedTile(
                icon: Icons.high_quality_rounded,
                title: l10n.advancedWmmTitle,
                body: l10n.advancedWmmBody,
                color: AppColors.neonGreen,
                onSurface: onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdvancedTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  final Color onSurface;
  const _AdvancedTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    required this.onSurface,
  });

  @override
  State<_AdvancedTile> createState() => _AdvancedTileState();
}

class _AdvancedTileState extends State<_AdvancedTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: widget.color.withValues(alpha: 0.05),
        border: Border.all(color: widget.color.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(widget.icon, size: 14, color: widget.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.orbitron(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: widget.color.withValues(alpha: 0.9),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Icon(
                    _open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: widget.color.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                widget.body,
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  height: 1.5,
                  color: widget.onSurface.withValues(alpha: 0.85),
                ),
              ),
            ),
        ],
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
