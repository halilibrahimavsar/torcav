import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class WifiScannerRadar extends StatefulWidget {
  final bool isScanning;
  final List<double> blips; // normalized distances (0.0 to 1.0)
  final Color color;

  const WifiScannerRadar({
    super.key,
    this.isScanning = true,
    this.blips = const [],
    this.color = AppColors.neonCyan,
  });

  @override
  State<WifiScannerRadar> createState() => _WifiScannerRadarState();
}

class _WifiScannerRadarState extends State<WifiScannerRadar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.isScanning) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(WifiScannerRadar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isScanning && _controller.isAnimating) {
      _controller.stop();
    }
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
          painter: _WifiRadarPainter(
            rotation: _controller.value,
            isScanning: widget.isScanning,
            blips: widget.blips,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _WifiRadarPainter extends CustomPainter {
  final double rotation;
  final bool isScanning;
  final List<double> blips;
  final Color color;

  _WifiRadarPainter({
    required this.rotation,
    required this.isScanning,
    required this.blips,
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

    // ── Sonar Rings ──
    for (int i = 1; i <= 4; i++) {
      paint.color = color.withValues(alpha: 0.1 * i);
      canvas.drawCircle(center, radius * (i / 4), paint);
    }

    // ── Axis Lines ──
    paint.color = color.withValues(alpha: 0.1);
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );

    // ── Scanner Sweep ──
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

      // Sweep Line with Glow
      final lineAngle = rotation * 2 * math.pi;
      final linePaint =
          Paint()
            ..color = color
            ..strokeWidth = 2.0
            ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

      canvas.drawLine(
        center,
        Offset(
          center.dx + math.cos(lineAngle) * radius,
          center.dy + math.sin(lineAngle) * radius,
        ),
        linePaint,
      );
    }

    // ── Blips (Detected Networks) ──
    final blipPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < blips.length; i++) {
      // Deterministic but "random" position for each blip based on index
      final blipAngle =
          (i * 137.5) * (math.pi / 180); // Golden angle for distribution
      final blipDistance = blips[i] * radius;

      final blipPos = Offset(
        center.dx + math.cos(blipAngle) * blipDistance,
        center.dy + math.sin(blipAngle) * blipDistance,
      );

      // Fade blips based on sweep position
      double alpha = 0.2;
      if (isScanning) {
        final currentAngle = rotation * 2 * math.pi;
        double diff = (currentAngle - blipAngle) % (2 * math.pi);
        if (diff < 0) diff += 2 * math.pi;
        alpha = (1.0 - (diff / (2 * math.pi))).clamp(0.1, 1.0);
      }

      blipPaint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(blipPos, 4, blipPaint);

      // Draw a subtle outer ring for the blip
      paint.color = color.withValues(alpha: alpha * 0.5);
      canvas.drawCircle(blipPos, 8 * (1.1 - alpha), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WifiRadarPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.isScanning != isScanning ||
        oldDelegate.blips != blips;
  }
}
