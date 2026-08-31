import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../domain/entities/isp_evidence_labels.dart';
import '../../domain/entities/plan_comparison.dart';
import '../bloc/plan_comparison_cubit.dart';

/// Paying-vs-getting card: declared ISP plan speed against the average of
/// recent speed tests.
///
/// The mission's operator-axis promise — "ödediğin hızın karşılığını alıyor
/// musun?" — answered in one glance, with an ISP-report escape hatch when
/// the answer is no.
class PlanComparisonCard extends StatelessWidget {
  const PlanComparisonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PlanComparisonCubit>()..load(),
      child: const _CardBody(),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<PlanComparisonCubit, PlanComparisonState>(
      builder: (context, state) {
        if (state is PlanComparisonInitial) return const SizedBox.shrink();

        return NeonCard(
          glowColor: scheme.primary,
          glowIntensity: 0.04,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: switch (state) {
            PlanComparisonNoPlan() => _NoPlanRow(
              onEnterPlan: () => _showPlanSheet(context, current: null),
            ),
            PlanComparisonLoaded(:final comparison) => _ComparisonBody(
              comparison: comparison,
              onEditPlan:
                  () => _showPlanSheet(context, current: comparison.planMbps),
            ),
            PlanComparisonInitial() => const SizedBox.shrink(),
          },
        );
      },
    );
  }

  Future<void> _showPlanSheet(
    BuildContext context, {
    required double? current,
  }) async {
    final cubit = context.read<PlanComparisonCubit>();
    final mbps = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PlanSpeedSheet(current: current),
    );
    if (mbps != null) cubit.setPlanSpeed(mbps);
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.receipt_long_rounded, size: 14, color: scheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            context.l10n.planSpeedTitle.toUpperCase(),
            style: GoogleFonts.orbitron(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoPlanRow extends StatelessWidget {
  final VoidCallback onEnterPlan;

  const _NoPlanRow({required this.onEnterPlan});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        const Expanded(child: _Title()),
        TextButton.icon(
          onPressed: onEnterPlan,
          icon: Icon(Icons.add_rounded, size: 16, color: scheme.primary),
          label: Text(
            context.l10n.planSpeedEnterCta,
            style: GoogleFonts.rajdhani(
              color: scheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ComparisonBody extends StatelessWidget {
  final PlanComparison comparison;
  final VoidCallback onEditPlan;

  const _ComparisonBody({required this.comparison, required this.onEditPlan});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final verdictColor = _verdictColor(comparison.verdict, scheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: _Title()),
            InkWell(
              onTap: onEditPlan,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (comparison.verdict == PlanVerdict.noData) ...[
          _SpeedValue(
            label: l10n.planSpeedPlanLabel,
            mbps: comparison.planMbps,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.planSpeedNoData,
            style: GoogleFonts.rajdhani(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _SpeedValue(
                  label: l10n.planSpeedPlanLabel,
                  mbps: comparison.planMbps,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: scheme.onSurface.withValues(alpha: 0.08),
              ),
              Expanded(
                child: _SpeedValue(
                  label: l10n.planSpeedMeasuredLabel,
                  mbps: comparison.avgDownloadMbps,
                  color: verdictColor,
                  caption: l10n.planSpeedSamples(comparison.sampleCount),
                ),
              ),
            ],
          ),
          if (comparison.recentDownloadsMbps.length >= 2) ...[
            const SizedBox(height: 12),
            Semantics(
              // A sparkline against a plan line says nothing out loud; the
              // range and the plan it is measured against are the content.
              label: l10n.a11ySpeedTrendChart(
                comparison.recentDownloadsMbps.length,
                comparison.recentDownloadsMbps
                    .reduce((a, b) => a < b ? a : b)
                    .toStringAsFixed(1),
                comparison.recentDownloadsMbps
                    .reduce((a, b) => a > b ? a : b)
                    .toStringAsFixed(1),
                comparison.planMbps.toStringAsFixed(0),
              ),
              child: SizedBox(
              height: 44,
              width: double.infinity,
              child: CustomPaint(
                painter: _TrendSparklinePainter(
                  samples: comparison.recentDownloadsMbps,
                  planMbps: comparison.planMbps,
                  lineColor: verdictColor,
                  planLineColor: scheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _RatioBar(ratio: comparison.deliveredRatio, color: verdictColor),
          const SizedBox(height: 4),
          Text(
            l10n.planSpeedPercentOfPlan(
              (comparison.deliveredRatio * 100).round(),
            ),
            style: GoogleFonts.rajdhani(
              color: scheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _verdictIcon(comparison.verdict),
                size: 15,
                color: verdictColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _verdictText(context, comparison.verdict),
                  style: GoogleFonts.rajdhani(
                    color: verdictColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (comparison.verdict == PlanVerdict.underDelivering) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _shareIspEvidence(context),
                icon: Icon(
                  Icons.ios_share_rounded,
                  size: 16,
                  color: scheme.primary,
                ),
                label: Text(
                  l10n.planSpeedReportCta,
                  style: GoogleFonts.rajdhani(
                    color: scheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Future<void> _shareIspEvidence(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final text = await context.read<PlanComparisonCubit>().composeIspEvidence(
      IspEvidenceLabels(
        title: l10n.ispEvidenceTitle,
        generatedAtLabel: l10n.ispEvidenceGeneratedAt,
        planLabel: l10n.planSpeedPlanLabel,
        averageLabel: l10n.planSpeedMeasuredLabel,
        bestLabel: l10n.ispEvidenceBest,
        percentOfPlan: l10n.planSpeedPercentOfPlan(
          (comparison.deliveredRatio * 100).round(),
        ),
        samplesHeader: l10n.ispEvidenceSamples,
        disclaimer: l10n.ispEvidenceDisclaimer,
      ),
    );
    if (text != null) {
      await SharePlus.instance.share(ShareParams(text: text));
    }
  }

  static Color _verdictColor(PlanVerdict v, ColorScheme scheme) =>
      switch (v) {
        PlanVerdict.delivering => scheme.primary,
        PlanVerdict.acceptable => const Color(0xFFFFB300),
        PlanVerdict.underDelivering => scheme.error,
        PlanVerdict.noData => scheme.onSurfaceVariant,
      };

  static IconData _verdictIcon(PlanVerdict v) => switch (v) {
    PlanVerdict.delivering => Icons.check_circle_rounded,
    PlanVerdict.acceptable => Icons.info_rounded,
    PlanVerdict.underDelivering => Icons.warning_rounded,
    PlanVerdict.noData => Icons.help_outline_rounded,
  };

  static String _verdictText(BuildContext context, PlanVerdict v) {
    final l10n = context.l10n;
    return switch (v) {
      PlanVerdict.delivering => l10n.planSpeedVerdictDelivering,
      PlanVerdict.acceptable => l10n.planSpeedVerdictAcceptable,
      PlanVerdict.underDelivering => l10n.planSpeedVerdictUnder,
      PlanVerdict.noData => l10n.planSpeedNoData,
    };
  }
}

class _SpeedValue extends StatelessWidget {
  final String label;
  final double mbps;
  final Color color;
  final String? caption;

  const _SpeedValue({
    required this.label,
    required this.mbps,
    required this.color,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${mbps.toStringAsFixed(mbps >= 100 ? 0 : 1)} Mbps',
          style: GoogleFonts.rajdhani(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (caption != null)
          Text(
            caption!,
            style: GoogleFonts.rajdhani(
              color: scheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
      ],
    );
  }
}

/// Download trend of the compared samples with the plan speed as a dashed
/// reference line, so "below what I pay for" is visible at a glance.
class _TrendSparklinePainter extends CustomPainter {
  final List<double> samples;
  final double planMbps;
  final Color lineColor;
  final Color planLineColor;

  const _TrendSparklinePainter({
    required this.samples,
    required this.planMbps,
    required this.lineColor,
    required this.planLineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var maxValue = planMbps;
    for (final s in samples) {
      if (s > maxValue) maxValue = s;
    }
    if (maxValue <= 0) return;
    maxValue *= 1.1;

    double yFor(double value) =>
        size.height - (value / maxValue * size.height);

    // Dashed plan reference line.
    final planY = yFor(planMbps);
    final dashPaint =
        Paint()
          ..color = planLineColor
          ..strokeWidth = 1;
    const dashWidth = 4.0;
    const gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, planY), Offset(x + dashWidth, planY),
          dashPaint,);
      x += dashWidth + gap;
    }

    // Sample polyline.
    final step = size.width / (samples.length - 1);
    final path = Path()..moveTo(0, yFor(samples.first));
    for (var i = 1; i < samples.length; i++) {
      path.lineTo(step * i, yFor(samples[i]));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Dot on the newest sample.
    canvas.drawCircle(
      Offset(size.width, yFor(samples.last)),
      3,
      Paint()..color = lineColor,
    );
  }

  @override
  bool shouldRepaint(_TrendSparklinePainter old) =>
      old.samples != samples ||
      old.planMbps != planMbps ||
      old.lineColor != lineColor;
}

class _RatioBar extends StatelessWidget {
  final double ratio;
  final Color color;

  const _RatioBar({required this.ratio, required this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: ratio.clamp(0.0, 1.0),
        minHeight: 6,
        backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _PlanSpeedSheet extends StatefulWidget {
  final double? current;

  const _PlanSpeedSheet({required this.current});

  @override
  State<_PlanSpeedSheet> createState() => _PlanSpeedSheetState();
}

class _PlanSpeedSheetState extends State<_PlanSpeedSheet> {
  late final TextEditingController _controller = TextEditingController(
    text:
        widget.current == null
            ? ''
            : widget.current!.toStringAsFixed(
              widget.current! % 1 == 0 ? 0 : 1,
            ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? get _parsed {
    final value = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (value == null || value <= 0 || value > 10000) return null;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: scheme.primary.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.planSpeedTitle.toUpperCase(),
            style: GoogleFonts.orbitron(
              color: scheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.planSpeedSheetHint,
            style: GoogleFonts.rajdhani(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.rajdhani(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              suffixText: 'Mbps',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: GoogleFonts.rajdhani(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _parsed == null ? null : _save,
                child: Text(
                  l10n.save,
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _save() {
    final value = _parsed;
    if (value == null) return;
    Navigator.pop(context, value);
  }
}
