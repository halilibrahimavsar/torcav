import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class NetworkScannerRadar extends StatefulWidget {
  final bool isScanning;
  final int nodeCount;
  final Color color;

  const NetworkScannerRadar({
    super.key,
    required this.isScanning,
    this.nodeCount = 0,
    this.color = AppColors.neonCyan,
  });

  @override
  State<NetworkScannerRadar> createState() => _NetworkScannerRadarState();
}

class _NetworkScannerRadarState extends State<NetworkScannerRadar>
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
          size: Size.infinite,
          painter: _NetworkRadarPainter(
            scanProgress: _controller.value,
            nodeCount: widget.nodeCount,
            color: widget.color,
            isScanning: widget.isScanning,
          ),
        );
      },
    );
  }
}

class _NetworkRadarPainter extends CustomPainter {
  final double scanProgress;
  final int nodeCount;
  final Color color;
  final bool isScanning;

  _NetworkRadarPainter({
    required this.scanProgress,
    required this.nodeCount,
    required this.color,
    required this.isScanning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final paint =
        Paint()
          ..color = color.withValues(alpha: 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    // ── Grid Lines ──
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * (i / 4), paint);
    }

    final linePaint =
        Paint()
          ..color = color.withValues(alpha: 0.05)
          ..strokeWidth = 0.5;

    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4);
      canvas.drawLine(
        center,
        Offset(
          center.dx + cos(angle) * radius,
          center.dy + sin(angle) * radius,
        ),
        linePaint,
      );
    }

    // ── Scanning Sweep ──
    if (isScanning) {
      final sweepAngle = scanProgress * 2 * pi;
      final sweepPaint =
          Paint()
            ..shader = SweepGradient(
              colors: [
                color.withValues(alpha: 0),
                color.withValues(alpha: 0.5),
              ],
              stops: const [0.8, 1.0],
              transform: GradientRotation(sweepAngle - pi / 2),
            ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, sweepPaint);

      // Sweep Line
      final lineEnd = Offset(
        center.dx + cos(sweepAngle) * radius,
        center.dy + sin(sweepAngle) * radius,
      );
      canvas.drawLine(
        center,
        lineEnd,
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2),
      );
    }

    // ── Pseudo-Nodes ──
    final Random random = Random(42); // Deterministic nodes
    final int displayNodes =
        isScanning ? (nodeCount + 3).clamp(5, 12) : nodeCount;

    for (int i = 0; i < displayNodes; i++) {
      final distance = (0.2 + random.nextDouble() * 0.7) * radius;
      final initialAngle = random.nextDouble() * 2 * pi;

      // Calculate discovery status based on sweep
      final currentSweepAngle = scanProgress * 2 * pi;
      final nodeAngle = initialAngle % (2 * pi);

      double opacity = 0.1;
      if (isScanning) {
        final angleDiff = (currentSweepAngle - nodeAngle) % (2 * pi);
        if (angleDiff < 0.5) {
          opacity = 0.8 * (1.0 - (angleDiff / 0.5));
        }
      } else {
        opacity = 0.4;
      }

      final nodePos = Offset(
        center.dx + cos(initialAngle) * distance,
        center.dy + sin(initialAngle) * distance,
      );

      // Draw Node
      canvas.drawCircle(
        nodePos,
        3,
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, opacity * 4),
      );

      canvas.drawCircle(
        nodePos,
        1.5,
        Paint()..color = color.withValues(alpha: opacity + 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NetworkRadarPainter oldDelegate) => true;
}
