import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import '../../../domain/services/survey_guidance_service.dart';
import 'hud_models.dart';

/// Top-right status card showing survey stage, progress metrics, and feed status.
class SurveyPilotCard extends StatelessWidget {
  const SurveyPilotCard({super.key, required this.guidance});

  final SurveyGuidance guidance;

  @override
  Widget build(BuildContext context) {
    final accent = surveyToneColor(guidance.tone);
    return SizedBox(
      width: 190,
      child: HolographicCard(
        color: accent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(_toneIcon(guidance.tone), color: accent, size: 14),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      (guidance.customInstruction ?? _stageLabel(guidance.stage)).toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.orbitron(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Primary Completion Metric
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(guidance.overallProgress * 100).toInt()}%',
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'COMPLETE',
                      style: GoogleFonts.orbitron(
                        color: accent.withValues(alpha: 0.7),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MiniRing(
                    value: guidance.coverageScore,
                    color: AppColors.neonCyan,
                    label: 'COV',
                  ),
                  _MiniRing(
                    value: guidance.signalScore,
                    color: AppColors.neonGreen,
                    label: 'SIG',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(height: 1, color: accent.withValues(alpha: 0.25)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FeedDot(label: 'MOT', live: guidance.feeds.motionLive),
                  _FeedDot(label: 'WIFI', live: guidance.feeds.wifiLive),
                  _FeedDot(label: 'CAM', live: guidance.feeds.cameraLive),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _toneIcon(SurveyTone tone) {
    switch (tone) {
      case SurveyTone.info:
        return Icons.info_outline_rounded;
      case SurveyTone.progress:
        return Icons.autorenew_rounded;
      case SurveyTone.caution:
        return Icons.warning_amber_rounded;
      case SurveyTone.success:
        return Icons.check_circle_outline_rounded;
    }
  }

  String _stageLabel(SurveyStage stage) {
    switch (stage) {
      case SurveyStage.idle:
        return 'STANDBY';
      case SurveyStage.calibration:
        return 'INITIALIZING';
      case SurveyStage.coverageSweep:
        return 'SWEEP ROOMS';
      case SurveyStage.weakZoneReview:
        return 'WEAK ZONE';
      case SurveyStage.wrapUp:
        return 'WRAP UP';
      case SurveyStage.review:
        return 'REVIEW';
    }
  }
}

class _MiniRing extends StatelessWidget {
  const _MiniRing({
    required this.value,
    required this.color,
    required this.label,
  });

  final double value;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 38,
          height: 38,
          child: CustomPaint(
            painter: _MiniRingPainter(value: value.clamp(0, 1), color: color),
            child: Center(
              child: Text(
                '${(value.clamp(0, 1) * 100).round()}',
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: color.withValues(alpha: 0.85),
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  _MiniRingPainter({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final trackPaint =
        Paint()
          ..color = color.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniRingPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}

class _FeedDot extends StatelessWidget {
  const _FeedDot({required this.label, required this.live});

  final String label;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final color = live ? AppColors.neonGreen : AppColors.textMuted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        live
            ? PulsingDot(color: color, size: 8)
            : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.orbitron(
            color: color.withValues(alpha: 0.8),
            fontSize: 7,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
