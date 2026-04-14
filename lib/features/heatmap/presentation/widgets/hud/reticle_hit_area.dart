import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/features/heatmap/domain/entities/survey_gate.dart';
import 'package:torcav/features/heatmap/domain/services/signal_tier.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';
import 'hud_models.dart';

/// Center reticle that pulses and handles manual weak zone flagging.
class ReticleHitArea extends StatelessWidget {
  const ReticleHitArea({
    super.key,
    required this.controller,
    required this.onFlagWeakZone,
  });

  final AnimationController controller;
  final VoidCallback? onFlagWeakZone;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, ReticleSlice>(
      selector:
          (s) => ReticleSlice(
            rssi: s.currentRssi,
            lastStepTimestamp: s.lastStepTimestamp,
            surveyGate: s.surveyGate,
            hasPendingWall: s.pendingWalls.any((wall) {
              final cx = (wall.x1 + wall.x2) / 2;
              final cy = (wall.y1 + wall.y2) / 2;
              return (cx - 0.5).abs() < 0.15 && (cy - 0.5).abs() < 0.15;
            }),
          ),
      builder: (context, slice) {
        final tier = signalTierFor(slice.rssi);
        final color = slice.hasPendingWall ? AppColors.neonYellow : signalTierColor(tier);
        final isWeak =
            slice.surveyGate == SurveyGate.none &&
            (tier == SignalTier.weak || tier == SignalTier.poor) &&
            !slice.hasPendingWall;
        
        final hitSize = (isWeak || slice.hasPendingWall) ? 140.0 : 120.0;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (slice.hasPendingWall) {
              context.read<HeatmapBloc>().addNearestPendingWall();
            } else if (isWeak) {
              onFlagWeakZone?.call();
            }
          },
          child: SizedBox(
            width: hitSize,
            height: hitSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: controller,
                  builder:
                      (_, __) => CustomPaint(
                        size: Size(hitSize, hitSize),
                        painter: _ReticlePainter(
                          progress: controller.value,
                          color: color,
                          stepTs: slice.lastStepTimestamp,
                        ),
                      ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (slice.hasPendingWall) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.neonYellow.withValues(alpha: 0.18),
                          border: Border.all(
                            color: AppColors.neonYellow.withValues(alpha: 0.8),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ADD WALL',
                          style: GoogleFonts.orbitron(
                            color: AppColors.neonYellow,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ] else if (isWeak) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.18),
                          border: Border.all(
                            color: color.withValues(alpha: 0.8),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'TAP TO FLAG',
                          style: GoogleFonts.orbitron(
                            color: color,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReticlePainter extends CustomPainter {
  _ReticlePainter({
    required this.progress,
    required this.color,
    required this.stepTs,
  });

  final double progress;
  final Color color;
  final DateTime? stepTs;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final base = math.min(size.width, size.height) / 2;

    // Outer static ring.
    final ringPaint =
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
    canvas.drawCircle(center, base - 4, ringPaint);

    // Corner brackets.
    final bracketPaint =
        Paint()
          ..color = color.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
    const bracket = 14.0;
    for (final corner in const [
      Offset(-1, -1),
      Offset(1, -1),
      Offset(1, 1),
      Offset(-1, 1),
    ]) {
      final cx = center.dx + corner.dx * (base - 10);
      final cy = center.dy + corner.dy * (base - 10);
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx - corner.dx * bracket, cy),
        bracketPaint,
      );
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx, cy - corner.dy * bracket),
        bracketPaint,
      );
    }

    // Pulsing inner ring.
    final pulseRadius = (base - 18) + math.sin(progress * 2 * math.pi) * 3;
    final pulsePaint =
        Paint()
          ..color = color.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
    canvas.drawCircle(center, pulseRadius, pulsePaint);

    // Crosshair.
    final crossPaint =
        Paint()
          ..color = color.withValues(alpha: 0.7)
          ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(center.dx - 10, center.dy),
      Offset(center.dx + 10, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 10),
      Offset(center.dx, center.dy + 10),
      crossPaint,
    );

    // Step pulse — expanding ring on footstep detection.
    if (stepTs != null) {
      final diffMs = DateTime.now().difference(stepTs!).inMilliseconds;
      if (diffMs < 800) {
        final t = diffMs / 800.0;
        final stepPaint =
            Paint()
              ..color = AppColors.neonCyan.withValues(alpha: (1 - t) * 0.45)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2;
        canvas.drawCircle(center, 22 + (t * 80), stepPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ReticlePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.stepTs != stepTs;
}
