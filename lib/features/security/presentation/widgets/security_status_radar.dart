import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';


class SecurityStatusRadar extends StatefulWidget {
  final double score;
  final bool isScanning;
  final Color color;

  const SecurityStatusRadar({
    super.key,
    required this.score,
    this.isScanning = false,
    this.color = AppColors.neonCyan,
  });

  @override
  State<SecurityStatusRadar> createState() => _SecurityStatusRadarState();
}

class _SecurityStatusRadarState extends State<SecurityStatusRadar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 200),
          painter: _RadarPainter(
            rotation: _controller.value,
            score: widget.score,
            isScanning: widget.isScanning,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double rotation;
  final double score;
  final bool isScanning;
  final Color color;

  _RadarPainter({
    required this.rotation,
    required this.score,
    required this.isScanning,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    // ── Grid Rings ──
    for (int i = 1; i <= 3; i++) {
      paint.color = color.withValues(alpha: 0.05 * i);
      canvas.drawCircle(center, radius * (i / 3), paint);
    }

    // ── Rotating Outer Segments ──
    final outerPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = color.withValues(alpha: 0.4);

    const int segments = 4;
    final segmentGap = math.pi / 4;
    final segmentLength = (2 * math.pi / segments) - segmentGap;

    for (int i = 0; i < segments; i++) {
      final startAngle = rotation * 2 * math.pi + (i * (segmentLength + segmentGap));
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 5),
        startAngle,
        segmentLength,
        false,
        outerPaint,
      );
    }

    // ── Scanner Sweep ──
    if (isScanning) {
      final sweepPaint =
          Paint()
            ..shader = SweepGradient(
              colors: [
                color.withValues(alpha: 0.0),
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.05),
              ],
              stops: const [0.0, 0.9, 1.0],
              transform: GradientRotation(rotation * 2 * math.pi),
            ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, sweepPaint);

      // Sweep Line
      final lineAngle = rotation * 2 * math.pi;
      final linePaint =
          Paint()
            ..color = color
            ..strokeWidth = 1.5;
      canvas.drawLine(
        center,
        Offset(
          center.dx + math.cos(lineAngle) * radius,
          center.dy + math.sin(lineAngle) * radius,
        ),
        linePaint,
      );
    }

    // ── Score Percentage ──
    final scoreAngle = score * 2 * math.pi;
    final progressPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6.0
          ..strokeCap = StrokeCap.round
          ..color = color;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 15),
      -math.pi / 2,
      scoreAngle,
      false,
      progressPaint..color = color.withValues(alpha: 0.1),
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 15),
      -math.pi / 2,
      scoreAngle,
      false,
      progressPaint..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.score != score ||
        oldDelegate.isScanning != isScanning;
  }
}
