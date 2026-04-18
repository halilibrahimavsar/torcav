import 'dart:math' as math;
import 'package:flutter/material.dart';

class SecurityStatusRadar extends StatefulWidget {
  final double score;
  final bool isScanning;
  final Color? color;
  final double size;

  const SecurityStatusRadar({
    super.key,
    required this.score,
    this.isScanning = false,
    this.color,
    this.size = 200,
  });

  @override
  State<SecurityStatusRadar> createState() => _SecurityStatusRadarState();
}

class _SecurityStatusRadarState extends State<SecurityStatusRadar>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _hudController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _hudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _hudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationController,
        _pulseController,
        _hudController,
      ]),
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _AdvancedRadarPainter(
            rotation: _rotationController.value,
            pulse: _pulseController.value,
            hudRotation: _hudController.value,
            score: widget.score,
            isScanning: widget.isScanning,
            color: effectiveColor,
          ),
        );
      },
    );
  }
}

class _AdvancedRadarPainter extends CustomPainter {
  final double rotation;
  final double pulse;
  final double hudRotation;
  final double score;
  final bool isScanning;
  final Color color;

  _AdvancedRadarPainter({
    required this.rotation,
    required this.pulse,
    required this.hudRotation,
    required this.score,
    required this.isScanning,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Add internal padding to prevent clipping of degree markers and outer rings
    final radius = (math.min(size.width, size.height) - 16) / 2;

    final basePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = color.withValues(alpha: 0.1);

    // ── 1. HUD Grid & Rings ──
    for (int i = 1; i <= 4; i++) {
      final ringRadius = radius * (i / 4);
      canvas.drawCircle(center, ringRadius, basePaint);
    }

    // ── 2. Outer Rotating Segments (The "Armor") ──
    final armorPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = color.withValues(alpha: 0.2 + (pulse * 0.2));

    _drawRotatingArcs(
      canvas,
      center,
      radius - 4,
      rotation * 2 * math.pi,
      4,
      0.6,
      armorPaint,
    );

    // ── 3. Degree Markers (VIP HUD Detail) ──
    final markerPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    for (int i = 0; i < 72; i++) {
      final angle = (i * 5) * (math.pi / 180);
      final isMajor = i % 18 == 0; // N, E, S, W
      final isMinor = i % 2 == 0;

      if (!isMinor && !isMajor) continue;

      final markerLength = isMajor ? 12.0 : (isMinor ? 6.0 : 3.0);
      final startRadius = radius + 2;
      final endRadius = startRadius + markerLength;

      markerPaint.color = color.withValues(alpha: isMajor ? 0.4 : 0.15);

      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * startRadius,
          center.dy + math.sin(angle) * startRadius,
        ),
        Offset(
          center.dx + math.cos(angle) * endRadius,
          center.dy + math.sin(angle) * endRadius,
        ),
        markerPaint,
      );
    }

    // ── 4. Scanner Sweep (if scanning) ──
    if (isScanning) {
      final sweepPaint =
          Paint()
            ..shader = SweepGradient(
              colors: [
                color.withValues(alpha: 0.0),
                color.withValues(alpha: 0.4),
                color.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.95, 1.0],
              transform: GradientRotation(rotation * 2 * math.pi),
            ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, sweepPaint);

      // Sweep Line
      final lineAngle = rotation * 2 * math.pi;
      final linePaint =
          Paint()
            ..color = color
            ..strokeWidth = 1.5
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
      canvas.drawLine(
        center,
        Offset(
          center.dx + math.cos(lineAngle) * radius,
          center.dy + math.sin(lineAngle) * radius,
        ),
        linePaint,
      );
    }

    // ── 5. Score Progress Ring (The "Shield Integrity") ──
    final scoreRadius = radius - 15;
    final progressPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6.0
          ..strokeCap = StrokeCap.round;

    // Background track (Subtle)
    canvas.drawCircle(
      center,
      scoreRadius,
      progressPaint..color = color.withValues(alpha: 0.05),
    );

    // Glow for progress
    final glowPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..color = color.withValues(alpha: 0.3 * pulse);

    final sweepAngle =
        (score / 100) * 2 * math.pi; // Corrected score normalization
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: scoreRadius),
      -math.pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: scoreRadius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint
        ..color = color
        ..maskFilter = null,
    );

    // ── 6. Center Hub ──
    canvas.drawCircle(center, 4, Paint()..color = color);
    canvas.drawCircle(
      center,
      8 + (pulse * 4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.5 - (pulse * 0.5)),
    );
  }

  void _drawRotatingArcs(
    Canvas canvas,
    Offset center,
    double radius,
    double startRotation,
    int count,
    double arcLengthRatio,
    Paint paint,
  ) {
    final arcLength = (2 * math.pi / count) * arcLengthRatio;
    final gap = (2 * math.pi / count) * (1 - arcLengthRatio);

    for (int i = 0; i < count; i++) {
      final startAngle = startRotation + (i * (arcLength + gap));
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        arcLength,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AdvancedRadarPainter oldDelegate) {
    return true; // Simple for animations
  }
}
