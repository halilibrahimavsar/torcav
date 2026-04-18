import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/features/heatmap/domain/services/signal_tier.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';
import 'hud_models.dart';

/// Center reticle that pulses to indicate signal strength.
class ReticleHitArea extends StatelessWidget {
  const ReticleHitArea({super.key, required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, ReticleSlice>(
      selector:
          (s) => ReticleSlice(
            rssi: s.currentRssi,
            lastStepTimestamp: s.lastStepTimestamp,
          ),
      builder: (context, slice) {
        final tier = signalTierFor(slice.rssi);
        final color = signalTierColor(tier);
        const size = 120.0;

        return IgnorePointer(
          child: SizedBox(
            width: size,
            height: size,
            child: AnimatedBuilder(
              animation: controller,
              builder:
                  (_, __) => CustomPaint(
                    size: const Size(size, size),
                    painter: _ReticlePainter(
                      progress: controller.value,
                      color: color,
                      stepTs: slice.lastStepTimestamp,
                    ),
                  ),
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

    final ringPaint =
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
    canvas.drawCircle(center, base - 4, ringPaint);

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

    final pulseRadius = (base - 18) + math.sin(progress * 2 * math.pi) * 3;
    final pulsePaint =
        Paint()
          ..color = color.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
    canvas.drawCircle(center, pulseRadius, pulsePaint);

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
