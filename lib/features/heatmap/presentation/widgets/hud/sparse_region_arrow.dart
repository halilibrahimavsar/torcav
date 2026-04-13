import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hud_models.dart';

/// Floating directional arrow with marching chevrons for sparse data coverage.
class SparseRegionArrow extends StatelessWidget {
  const SparseRegionArrow({
    super.key,
    required this.region,
    required this.controller,
    required this.tone,
  });

  final SparseRegion region;
  final AnimationController controller;
  final SurveyTone tone;

  @override
  Widget build(BuildContext context) {
    final color = surveyToneColor(tone);
    final (label, rotation) = switch (region) {
      SparseRegion.leftWing => ('HEAD LEFT', -math.pi / 2),
      SparseRegion.rightWing => ('HEAD RIGHT', math.pi / 2),
      SparseRegion.topWing => ('MOVE FORWARD', 0.0),
      SparseRegion.bottomWing => ('STEP BACK', math.pi),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 16),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: rotation,
            child: AnimatedBuilder(
              animation: controller,
              builder:
                  (_, __) => _MarchingChevrons(
                    progress: controller.value,
                    color: color,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '— SPARSE COVERAGE',
            style: GoogleFonts.outfit(
              color: color.withValues(alpha: 0.85),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarchingChevrons extends StatelessWidget {
  const _MarchingChevrons({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 16,
      child: CustomPaint(
        painter: _ChevronsPainter(progress: progress, color: color),
      ),
    );
  }
}

class _ChevronsPainter extends CustomPainter {
  _ChevronsPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final phase = ((progress + i / 3) % 1.0);
      final opacity = (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0);
      paint.color = color.withValues(alpha: opacity);
      final x = phase * size.width - size.width * 0.15;
      final path =
          Path()
            ..moveTo(x, 2)
            ..lineTo(x + 6, size.height / 2)
            ..lineTo(x, size.height - 2);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChevronsPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
