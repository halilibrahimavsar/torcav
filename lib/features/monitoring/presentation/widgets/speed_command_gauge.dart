import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';

class SpeedCommandGauge extends StatefulWidget {
  final double download;
  final double upload;
  final double maxSpeed;

  const SpeedCommandGauge({
    super.key,
    required this.download,
    required this.upload,
    this.maxSpeed = 100.0,
  });

  @override
  State<SpeedCommandGauge> createState() => _SpeedCommandGaugeState();
}

class _SpeedCommandGaugeState extends State<SpeedCommandGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: widget.download),
      builder: (context, dlValue, _) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0, end: widget.upload),
          builder: (context, ulValue, _) {
            return AspectRatio(
              aspectRatio: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ── Gauge Background & Arcs ──
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return CustomPaint(
                        size: Size.infinite,
                        painter: _GaugePainter(
                          download: dlValue,
                          upload: ulValue,
                          maxSpeed: widget.maxSpeed,
                          animationValue: _controller.value,
                        ),
                      );
                    },
                  ),

                  // ── Central Stats ──
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NeonText(
                        dlValue.toStringAsFixed(1),
                        style: GoogleFonts.orbitron(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                        glowRadius: 10,
                      ),
                      Text(
                        'MBPS DOWNLOAD',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neonCyan.withValues(alpha: 0.7),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.neonPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.neonPurple.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.upload_rounded,
                              size: 12,
                              color: AppColors.neonPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${ulValue.toStringAsFixed(1)} UP',
                              style: GoogleFonts.sourceCodePro(
                                color: AppColors.neonPurple,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double download;
  final double upload;
  final double maxSpeed;
  final double animationValue;

  _GaugePainter({
    required this.download,
    required this.upload,
    required this.maxSpeed,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    final dlPercent = (download / maxSpeed).clamp(0.0, 1.0);
    final ulPercent = (upload / maxSpeed).clamp(0.0, 1.0);

    // ── Background Rails ──
    final railPaint =
        Paint()
          ..color = AppColors.glassWhite.withValues(alpha: 0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round;

    // Download rail
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      startAngle,
      sweepAngle,
      false,
      railPaint..strokeWidth = 16,
    );

    // Upload rail (inner)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 35),
      startAngle,
      sweepAngle,
      false,
      railPaint..strokeWidth = 8,
    );

    // ── Download Neon Arc ──
    final dlGradient = SweepGradient(
      colors: [AppColors.neonCyan.withValues(alpha: 0.2), AppColors.neonCyan],
      stops: const [0.0, 1.0],
      transform: GradientRotation(startAngle),
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    final dlPaint =
        Paint()
          ..shader = dlGradient
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round;

    // Outer glow for DL
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      startAngle,
      sweepAngle * dlPercent,
      false,
      Paint()
        ..color = AppColors.neonCyan.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      startAngle,
      sweepAngle * dlPercent,
      false,
      dlPaint,
    );

    // ── Upload Neon Arc ──
    final ulGradient = SweepGradient(
      colors: [
        AppColors.neonPurple.withValues(alpha: 0.2),
        AppColors.neonPurple,
      ],
      stops: const [0.0, 1.0],
      transform: GradientRotation(startAngle),
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    final ulPaint =
        Paint()
          ..shader = ulGradient
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 35),
      startAngle,
      sweepAngle * ulPercent,
      false,
      ulPaint,
    );

    // ── Tick Marks & Technical Indicators ──
    final tickPaint =
        Paint()
          ..color = AppColors.textMuted.withValues(alpha: 0.4)
          ..strokeWidth = 1;

    for (int i = 0; i <= 20; i++) {
      final angle = startAngle + (sweepAngle * (i / 20));
      final tickLength = i % 5 == 0 ? 10.0 : 5.0;
      final start = Offset(
        center.dx + (radius - 20) * math.cos(angle),
        center.dy + (radius - 20) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius - 20 - tickLength) * math.cos(angle),
        center.dy + (radius - 20 - tickLength) * math.sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }

    // ── Animated "Bit-flow" Particles ──
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final pAngle =
          startAngle + (sweepAngle * ((animationValue + i / 8) % 1.0));
      final pRadius = radius - 10;
      final pPos = Offset(
        center.dx + pRadius * math.cos(pAngle),
        center.dy + pRadius * math.sin(pAngle),
      );

      canvas.drawCircle(
        pPos,
        2,
        particlePaint..color = AppColors.neonCyan.withValues(alpha: 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) => true;
}
