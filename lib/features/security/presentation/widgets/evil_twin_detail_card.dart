import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/evil_twin_assessment.dart';
import '../../domain/services/evil_twin_explainer.dart';

/// Self-contained explainer card for an [EvilTwinAssessment].
///
/// Designed for non-technical users: opens with the verdict ("Safe" /
/// "Low / Medium / High"), explains what an evil-twin is, why it matters,
/// which signals fired, and the concrete next steps to take.
class EvilTwinDetailCard extends StatelessWidget {
  const EvilTwinDetailCard({
    super.key,
    required this.assessment,
    EvilTwinExplainer? explainer,
  }) : explainer = explainer ?? const EvilTwinExplainer();

  final EvilTwinAssessment assessment;
  final EvilTwinExplainer explainer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exp = explainer.explain(assessment);
    final palette = _palette(exp.confidenceLabel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.withValues(alpha: 0.18),
            palette.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(color: palette.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: palette.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: palette),
                ),
                child: Icon(_icon(exp.confidenceLabel), color: palette),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EVIL TWIN · ${exp.confidenceLabel.toUpperCase()}',
                      style: GoogleFonts.orbitron(
                        color: palette,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      exp.headline,
                      style: GoogleFonts.rajdhani(
                        color: theme.colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              exp.confidencePhrase,
              style: GoogleFonts.rajdhani(
                color: theme.colorScheme.onSurface,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Section(title: 'What is an evil-twin?', body: exp.whatIs),
          const SizedBox(height: 12),
          _Section(title: 'Why does it matter?', body: exp.whyItMatters),
          if (exp.observedSignals.isNotEmpty) ...[
            const SizedBox(height: 12),
            _BulletBlock(
              title: 'What we observed',
              titleColor: Colors.orangeAccent,
              icon: Icons.warning_amber_rounded,
              items: exp.observedSignals,
            ),
          ],
          if (exp.mitigationSignals.isNotEmpty) ...[
            const SizedBox(height: 12),
            _BulletBlock(
              title: 'What looked legitimate',
              titleColor: Colors.greenAccent,
              icon: Icons.verified_user_rounded,
              items: exp.mitigationSignals,
            ),
          ],
          if (exp.recommendedActions.isNotEmpty) ...[
            const SizedBox(height: 14),
            _BulletBlock(
              title: 'What you should do',
              titleColor: theme.colorScheme.primary,
              icon: Icons.task_alt_rounded,
              items: exp.recommendedActions,
            ),
          ],
        ],
      ),
    );
  }

  Color _palette(String label) {
    switch (label) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orangeAccent;
      case 'Low':
        return Colors.amberAccent;
      case 'Safe':
        return Colors.greenAccent;
      default:
        return Colors.cyanAccent;
    }
  }

  IconData _icon(String label) {
    switch (label) {
      case 'High':
        return Icons.gpp_bad_rounded;
      case 'Medium':
        return Icons.gpp_maybe_rounded;
      case 'Low':
        return Icons.shield_outlined;
      case 'Safe':
        return Icons.shield_rounded;
      default:
        return Icons.shield_outlined;
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.orbitron(
            color: theme.colorScheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: GoogleFonts.rajdhani(
            color: theme.colorScheme.onSurface,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _BulletBlock extends StatelessWidget {
  const _BulletBlock({
    required this.title,
    required this.titleColor,
    required this.icon,
    required this.items,
  });

  final String title;
  final Color titleColor;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: titleColor),
            const SizedBox(width: 6),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.orbitron(
                color: titleColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: titleColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.rajdhani(
                      color: theme.colorScheme.onSurface,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
