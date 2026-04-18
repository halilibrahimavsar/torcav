import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';

/// A dynamic, animated "Security Core" that represents the real-time
/// security state with rotation, pulse, and glow effects.
class SecurityCore extends StatefulWidget {
  final Color statusColor;
  final String label;
  final String subLabel;
  final bool isLoading;

  const SecurityCore({
    super.key,
    this.statusColor = AppColors.neonCyan,
    required this.label,
    required this.subLabel,
    this.isLoading = false,
  });

  @override
  State<SecurityCore> createState() => _SecurityCoreState();
}

class _SecurityCoreState extends State<SecurityCore>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow
          AnimatedBuilder(
            animation: _pulseController,
            builder:
                (context, _) => Container(
                  width: 220 + (_pulseController.value * 20),
                  height: 220 + (_pulseController.value * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.statusColor.withValues(
                          alpha: 0.1 * (1 - _pulseController.value),
                        ),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
          ),

          // Custom Painted Rings
          AnimatedBuilder(
            animation: _rotationController,
            builder:
                (context, _) => CustomPaint(
                  size: const Size(260, 260),
                  painter: _CorePainter(
                    rotation: _rotationController.value,
                    pulse: _pulseController.value,
                    color: widget.statusColor,
                  ),
                ),
          ),

          // Inner Glassy Core
          GlassmorphicContainer(
            borderRadius: BorderRadius.circular(100),
            padding: EdgeInsets.zero,
            blurSigma: 15,
            borderColor: widget.statusColor.withValues(alpha: 0.3),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.statusColor.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(widget.statusColor),
                      ),
                    )
                  else
                    PulsingDot(color: widget.statusColor, size: 10),
                  const SizedBox(height: 12),
                  Text(
                    widget.label.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.orbitron(
                      color: widget.statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      widget.subLabel,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.orbitron(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CorePainter extends CustomPainter {
  final double rotation;
  final double pulse;
  final Color color;

  _CorePainter({
    required this.rotation,
    required this.pulse,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    // ── Outer Dashed Ring ──────────────────────────────────────────────
    paint.strokeWidth = 1.5;
    paint.color = color.withValues(alpha: 0.2 + (pulse * 0.1));
    final outerRadius = size.width / 2 - 10;

    _drawDashedArc(
      canvas,
      center,
      outerRadius,
      0 + (rotation * 2 * math.pi),
      0.8 * math.pi,
      paint,
      12,
    );
    _drawDashedArc(
      canvas,
      center,
      outerRadius,
      math.pi + (rotation * 2 * math.pi),
      0.8 * math.pi,
      paint,
      12,
    );

    // ── Middle Solid Accent Ring ───────────────────────────────────────
    paint.strokeWidth = 3;
    paint.color = color.withValues(alpha: 0.4);
    final midRadius = size.width / 2 - 30;

    // Rotating accent arcs
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: midRadius),
      -math.pi / 2 - (rotation * 4 * math.pi),
      math.pi / 3,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: midRadius),
      math.pi / 2 - (rotation * 4 * math.pi),
      math.pi / 3,
      false,
      paint,
    );

    // ── Inner Scanner Line ─────────────────────────────────────────────
    paint.strokeWidth = 1;
    paint.color = color.withValues(alpha: 0.6);
    final innerRadius = size.width / 2 - 45;

    final scannerX = center.dx + math.cos(rotation * 8 * math.pi) * innerRadius;
    final scannerY = center.dy + math.sin(rotation * 8 * math.pi) * innerRadius;

    canvas.drawLine(
      center,
      Offset(scannerX, scannerY),
      paint..color = color.withValues(alpha: 0.3),
    );
    canvas.drawCircle(
      Offset(scannerX, scannerY),
      3,
      paint
        ..style = PaintingStyle.fill
        ..color = color,
    );
  }

  void _drawDashedArc(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    Paint paint,
    int dashCount,
  ) {
    final dashSweep = sweepAngle / (dashCount * 2 - 1);
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + (i * 2 * dashSweep),
        dashSweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CorePainter oldDelegate) =>
      oldDelegate.rotation != rotation || oldDelegate.pulse != pulse;
}
