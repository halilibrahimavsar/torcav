import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../security/presentation/pages/router_hardening_wizard_page.dart';
import '../../domain/entities/category_explanation.dart';
import '../../domain/entities/diagnosis_evidence.dart';
import '../../domain/entities/diagnostic_action.dart';
import '../../domain/entities/root_cause_category.dart';

class EvidenceCard extends StatefulWidget {
  const EvidenceCard({
    super.key,
    required this.evidence,
    this.explanation,
  });

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
            _translate(context, evidence.metricKey, evidence.metricParams) ??
                evidence.metricLabel,
            style: GoogleFonts.shareTechMono(
              color: theme.colorScheme.onSurface,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _translate(
                  context,
                  evidence.thresholdKey,
                  evidence.thresholdParams,
                ) ??
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
                      _expanded
                          ? context.l10n.hideDetails
                          : context.l10n.whatIsThisHowToFix,
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
    RootCauseCategory.weakSignal => context.l10n.categorySignal,
    RootCauseCategory.crowdedChannel => context.l10n.categoryChannel,
    RootCauseCategory.bufferbloat => context.l10n.categoryBufferbloat,
    RootCauseCategory.ispSlow => context.l10n.categoryIsp,
    RootCauseCategory.slowDns => context.l10n.categoryDns,
    RootCauseCategory.healthy => context.l10n.categoryHealthy,
  };

  String _severityLabel(double severity) {
    if (severity >= 0.7) return context.l10n.severityHigh;
    if (severity >= 0.4) return context.l10n.severityMed;
    return context.l10n.severityLow;
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
          _Section(
            title: context.l10n.whatIsThisSection,
            body:
                _translate(context, explanation.whatIsKey) ??
                explanation.whatIs,
          ),
          const SizedBox(height: 10),
          _Section(
            title: context.l10n.whyItMattersSection,
            body:
                _translate(context, explanation.whyItMattersKey) ??
                explanation.whyItMatters,
          ),
          if ((explanation.howToFixKeys?.isNotEmpty ?? false) ||
              explanation.howToFix.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              context.l10n.howToFixSection,
              style: GoogleFonts.orbitron(
                color: theme.colorScheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            if (explanation.howToFixKeys != null)
              for (final key in explanation.howToFixKeys!)
                _StepRow(text: _translate(context, key) ?? key),
            if (explanation.howToFixKeys == null)
              for (final step in explanation.howToFix) _StepRow(text: step),
          ],
          if (explanation.estimatedImprovementKey != null ||
              explanation.estimatedImprovement != null) ...[
            const SizedBox(height: 10),
            _ImprovementBadge(
              text:
                  _translate(
                    context,
                    explanation.estimatedImprovementKey,
                    explanation.estimatedImprovementParams,
                  ) ??
                  explanation.estimatedImprovement!,
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
      onTap:
          hasDeepLink ? () => _navigate(context, action.deepLinkRoute!) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color:
              hasDeepLink
                  ? theme.colorScheme.primary.withValues(alpha: 0.12)
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
                  ),
          border: Border.all(
            color:
                hasDeepLink
                    ? theme.colorScheme.primary.withValues(alpha: 0.45)
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _label(context, action.labelKey),
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
        MaterialPageRoute(
          builder:
              (_) => const RouterHardeningWizardPage(),
        ),
      );
    }
  }

  // Static fallback labels keyed by AppLocalizations getter name. The page
  // will be wired to live AppLocalizations strings in a follow-up; this
  // default keeps the UI usable today.
  String _label(BuildContext context, String key) {
    final l10n = context.l10n;
    return switch (key) {
      'speedDoctorActionMoveCloser' => l10n.speedDoctorActionMoveCloser,
      'speedDoctorActionAddMesh' => l10n.speedDoctorActionAddMesh,
      'speedDoctorActionSwitchTo5Ghz' => l10n.speedDoctorActionSwitchTo5Ghz,
      'speedDoctorActionChangeChannel' => l10n.speedDoctorActionChangeChannel,
      'speedDoctorActionMoveTo5Ghz' => l10n.speedDoctorActionMoveTo5Ghz,
      'speedDoctorActionEnableQos' => l10n.speedDoctorActionEnableQos,
      'speedDoctorActionUpdateFirmware' => l10n.speedDoctorActionUpdateFirmware,
      'speedDoctorActionCallIsp' => l10n.speedDoctorActionCallIsp,
      'speedDoctorActionRunWiredTest' => l10n.speedDoctorActionRunWiredTest,
      'speedDoctorActionChangeDns' => l10n.speedDoctorActionChangeDns,
      'speedDoctorActionEnableDoh' => l10n.speedDoctorActionEnableDoh,
      _ => key,
    };
  }
}

String? _translate(
  BuildContext context,
  String? key, [
  Map<String, dynamic>? params,
]) {
  if (key == null) return null;
  final l10n = context.l10n;
  return switch (key) {
    'sdMetricRssi' => l10n.sdMetricRssi(params?['rssi'] ?? 0),
    'sdThresholdRssi' => l10n.sdThresholdRssi(
      params?['healthy'] ?? 0,
      params?['severe'] ?? 0,
    ),
    'sdMetricChannel' => l10n.sdMetricChannel(
      params?['channel'] ?? 0,
      params?['score'] ?? '',
    ),
    'sdThresholdChannel' => l10n.sdThresholdChannel(
      params?['healthy'] ?? '',
      params?['severe'] ?? '',
    ),
    'sdMetricBufferbloat' => l10n.sdMetricBufferbloat(
      params?['induced'] ?? '',
      params?['latency'] ?? '',
      params?['loaded'] ?? '',
    ),
    'sdThresholdBufferbloat' => l10n.sdThresholdBufferbloat(
      params?['healthy'] ?? '',
      params?['severe'] ?? '',
    ),
    'sdMetricIsp' => l10n.sdMetricIsp(
      params?['download'] ?? '',
      params?['phy'] ?? '',
    ),
    'sdMetricIspNoPhy' => l10n.sdMetricIspNoPhy(params?['download'] ?? ''),
    'sdThresholdIsp' => l10n.sdThresholdIsp(params?['healthy'] ?? ''),
    'sdMetricDns' => l10n.sdMetricDns(
      params?['name'] ?? '',
      params?['latency'] ?? 0,
    ),
    'sdThresholdDns' => l10n.sdThresholdDns(
      params?['healthy'] ?? 0,
      params?['severe'] ?? 0,
    ),
    'sdWeakSignalWhatIs' => l10n.sdWeakSignalWhatIs,
    'sdWeakSignalWhyItMatters' => l10n.sdWeakSignalWhyItMatters,
    'sdWeakSignalHowToFix1' => l10n.sdWeakSignalHowToFix1,
    'sdWeakSignalHowToFix2' => l10n.sdWeakSignalHowToFix2,
    'sdWeakSignalHowToFix3' => l10n.sdWeakSignalHowToFix3,
    'sdWeakSignalHowToFix4' => l10n.sdWeakSignalHowToFix4,
    'sdWeakSignalEstimate' => l10n.sdWeakSignalEstimate(params?['gain'] ?? ''),
    'sdCrowdedChannelWhatIs' => l10n.sdCrowdedChannelWhatIs,
    'sdCrowdedChannelWhyItMatters' => l10n.sdCrowdedChannelWhyItMatters,
    'sdCrowdedChannelHowToFix1' => l10n.sdCrowdedChannelHowToFix1,
    'sdCrowdedChannelHowToFix2' => l10n.sdCrowdedChannelHowToFix2,
    'sdCrowdedChannelHowToFix3' => l10n.sdCrowdedChannelHowToFix3,
    'sdCrowdedChannelHowToFix4' => l10n.sdCrowdedChannelHowToFix4,
    'sdCrowdedChannelEstimate' => l10n.sdCrowdedChannelEstimate(
      params?['gain'] ?? '',
    ),
    'sdBufferbloatWhatIs' => l10n.sdBufferbloatWhatIs,
    'sdBufferbloatWhyItMatters' => l10n.sdBufferbloatWhyItMatters,
    'sdBufferbloatHowToFix1' => l10n.sdBufferbloatHowToFix1,
    'sdBufferbloatHowToFix2' => l10n.sdBufferbloatHowToFix2,
    'sdBufferbloatHowToFix3' => l10n.sdBufferbloatHowToFix3,
    'sdBufferbloatHowToFix4' => l10n.sdBufferbloatHowToFix4,
    'sdBufferbloatEstimate' => l10n.sdBufferbloatEstimate(
      params?['reduction'] ?? '',
    ),
    'sdIspSlowWhatIs' => l10n.sdIspSlowWhatIs,
    'sdIspSlowWhyItMatters' => l10n.sdIspSlowWhyItMatters,
    'sdIspSlowHowToFix1' => l10n.sdIspSlowHowToFix1,
    'sdIspSlowHowToFix2' => l10n.sdIspSlowHowToFix2,
    'sdIspSlowHowToFix3' => l10n.sdIspSlowHowToFix3,
    'sdIspSlowHowToFix4' => l10n.sdIspSlowHowToFix4,
    'sdIspSlowEstimate' => l10n.sdIspSlowEstimate(
      params?['phy'] ?? '',
      params?['download'] ?? '',
    ),
    'sdSlowDnsWhatIs' => l10n.sdSlowDnsWhatIs,
    'sdSlowDnsWhyItMatters' => l10n.sdSlowDnsWhyItMatters,
    'sdSlowDnsHowToFix1' => l10n.sdSlowDnsHowToFix1,
    'sdSlowDnsHowToFix2' => l10n.sdSlowDnsHowToFix2,
    'sdSlowDnsHowToFix3' => l10n.sdSlowDnsHowToFix3,
    'sdSlowDnsEstimate' => l10n.sdSlowDnsEstimate(params?['reduction'] ?? 0),
    'sdHealthyWhatIs' => l10n.sdHealthyWhatIs,
    'sdHealthyWhyItMatters' => l10n.sdHealthyWhyItMatters,
    _ => null,
  };
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
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
              text,
              style: GoogleFonts.rajdhani(
                color: theme.colorScheme.onSurface,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImprovementBadge extends StatelessWidget {
  const _ImprovementBadge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.45)),
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
              text,
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
    );
  }
}
