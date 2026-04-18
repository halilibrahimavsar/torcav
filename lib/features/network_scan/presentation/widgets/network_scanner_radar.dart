import 'dart:math';
import 'package:flutter/material.dart';

class NetworkScannerRadar extends StatefulWidget {
  final bool isScanning;
  final Color? color;

  const NetworkScannerRadar({super.key, required this.isScanning, this.color});

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
    );
    if (widget.isScanning) _controller.repeat();
  }

  @override
  void didUpdateWidget(NetworkScannerRadar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _controller.repeat();
    } else if (!widget.isScanning && oldWidget.isScanning) {
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
    final effectiveColor =
        widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _NetworkRadarPainter(
            scanProgress: _controller.value,
            color: effectiveColor,
            isScanning: widget.isScanning,
          ),
        );
      },
    );
  }
}

class _NetworkRadarPainter extends CustomPainter {
  final double scanProgress;
  final Color color;
  final bool isScanning;

  _NetworkRadarPainter({
    required this.scanProgress,
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
  }

  @override
  bool shouldRepaint(covariant _NetworkRadarPainter oldDelegate) =>
      oldDelegate.scanProgress != scanProgress ||
      oldDelegate.isScanning != isScanning ||
      oldDelegate.color != color;
}
