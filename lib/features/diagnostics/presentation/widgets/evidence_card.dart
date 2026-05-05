import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../security/presentation/pages/router_hardening_wizard_page.dart';
import '../../domain/entities/category_explanation.dart';
import '../../domain/entities/diagnosis_evidence.dart';
import '../../domain/entities/diagnostic_action.dart';
import '../../domain/entities/root_cause_category.dart';

class EvidenceCard extends StatefulWidget {
  const EvidenceCard({super.key, required this.evidence, this.explanation});

  final DiagnosisEvidence evidence;
  final CategoryExplanation? explanation;

  @override
  State<EvidenceCard> createState() => _EvidenceCardState();
}

class _EvidenceCardState extends State<EvidenceCard> {
  bool _expanded = false;

  DiagnosisEvidence get evidence => widget.evidence;
  CategoryExplanation? get explanation => widget.explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityLabel = _severityLabel(evidence.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surface.withValues(alpha: 0.4),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _categoryLabel(evidence.category),
                  style: GoogleFonts.orbitron(
                    color: theme.colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              _SeverityBadge(severity: evidence.severity, label: severityLabel),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            evidence.metricLabel,
            style: GoogleFonts.shareTechMono(
              color: theme.colorScheme.onSurface,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            evidence.thresholdLabel,
            style: GoogleFonts.rajdhani(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          if (evidence.actions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final action in evidence.actions)
                  _ActionChip(action: action),
              ],
            ),
          ],
          if (explanation != null) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _expanded ? 'Hide details' : 'What is this? · How to fix',
                      style: GoogleFonts.rajdhani(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded) _ExplanationPanel(explanation: explanation!),
          ],
        ],
      ),
    );
  }

  String _categoryLabel(RootCauseCategory c) => switch (c) {
    RootCauseCategory.weakSignal => 'Signal',
    RootCauseCategory.crowdedChannel => 'Channel',
    RootCauseCategory.bufferbloat => 'Bufferbloat',
    RootCauseCategory.ispSlow => 'ISP throughput',
    RootCauseCategory.slowDns => 'DNS',
    RootCauseCategory.healthy => 'Healthy',
  };

  String _severityLabel(double severity) {
    if (severity >= 0.7) return 'HIGH';
    if (severity >= 0.4) return 'MED';
    return 'LOW';
  }
}

class _ExplanationPanel extends StatelessWidget {
  const _ExplanationPanel({required this.explanation});

  final CategoryExplanation explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(title: 'What is this?', body: explanation.whatIs),
          const SizedBox(height: 10),
          _Section(title: 'Why it matters', body: explanation.whyItMatters),
          if (explanation.howToFix.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'How to fix',
              style: GoogleFonts.orbitron(
                color: theme.colorScheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            for (final step in explanation.howToFix)
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
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        step,
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
          if (explanation.estimatedImprovement != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.greenAccent.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.greenAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      explanation.estimatedImprovement!,
                      style: GoogleFonts.rajdhani(
                        color: theme.colorScheme.onSurface,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity, required this.label});

  final double severity;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = _color(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: GoogleFonts.orbitron(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Color _color(double s) {
    if (s >= 0.7) return Colors.redAccent;
    if (s >= 0.4) return Colors.orangeAccent;
    return Colors.greenAccent;
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.action});

  final DiagnosticAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDeepLink = action.deepLinkRoute != null;
    return InkWell(
      onTap: hasDeepLink
          ? () => _navigate(context, action.deepLinkRoute!)
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: hasDeepLink
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                ),
          border: Border.all(
            color: hasDeepLink
                ? theme.colorScheme.primary.withValues(alpha: 0.45)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _label(action.labelKey),
              style: GoogleFonts.rajdhani(
                color: theme.colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasDeepLink) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    if (route == 'router-hardening') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RouterHardeningWizardPage()),
      );
    }
  }

  // Static fallback labels keyed by AppLocalizations getter name. The page
  // will be wired to live AppLocalizations strings in a follow-up; this
  // default keeps the UI usable today.
  String _label(String key) => switch (key) {
    'speedDoctorActionMoveCloser' => 'Move closer to router',
    'speedDoctorActionAddMesh' => 'Add a mesh node',
    'speedDoctorActionSwitchTo5Ghz' => 'Switch to 5 GHz',
    'speedDoctorActionChangeChannel' => 'Change Wi-Fi channel',
    'speedDoctorActionMoveTo5Ghz' => 'Move to 5/6 GHz band',
    'speedDoctorActionEnableQos' => 'Enable router QoS',
    'speedDoctorActionUpdateFirmware' => 'Update router firmware',
    'speedDoctorActionCallIsp' => 'Contact your ISP',
    'speedDoctorActionRunWiredTest' => 'Re-test with cable',
    'speedDoctorActionChangeDns' => 'Change DNS provider',
    'speedDoctorActionEnableDoh' => 'Enable DoH / DoT',
    _ => key,
  };
}
