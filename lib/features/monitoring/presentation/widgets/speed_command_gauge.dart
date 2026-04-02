import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../domain/entities/speed_test_progress.dart';

class SpeedCommandGauge extends StatefulWidget {
  final double download;
  final double upload;
  final double maxSpeed;
  final SpeedTestPhase phase;
  final Color? downloadColor;
  final Color? uploadColor;

  const SpeedCommandGauge({
    super.key,
    required this.download,
    required this.upload,
    this.maxSpeed = 100.0,
    this.phase = SpeedTestPhase.idle,
    this.downloadColor,
    this.uploadColor,
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
    final dlColor = widget.downloadColor ?? Theme.of(context).colorScheme.primary;
    final ulColor =
        widget.uploadColor ?? Theme.of(context).colorScheme.secondary;

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
                          phase: widget.phase,
                          downloadColor: dlColor,
                          uploadColor: ulColor,
                        ),
                      );
                    },
                  ),

                  // ── Central Stats ──
                  Builder(
                    builder: (context) {
                      final isIdle = widget.phase == SpeedTestPhase.idle;
                      final isUpload = widget.phase == SpeedTestPhase.upload;
                      final isDone = widget.phase == SpeedTestPhase.done;

                      // During upload phase, highlight upload speed in center
                      final centerValue = isUpload ? ulValue : dlValue;
                      final centerColor = isUpload ? ulColor : dlColor;
                      final centerLabel =
                          isUpload ? 'MBPS UPLOAD' : 'MBPS DOWNLOAD';

                      if (isIdle) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_circle_outline_rounded,
                              size: 32,
                              color: dlColor.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'TAP TO TEST',
                              style: GoogleFonts.orbitron(
                                fontSize: 9,
                                color: dlColor.withValues(alpha: 0.4),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        );
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          NeonText(
                            centerValue.toStringAsFixed(1),
                            style: GoogleFonts.orbitron(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                            glowRadius: isDone ? 14 : 10,
                            glowColor: centerColor,
                          ),
                          Text(
                            centerLabel,
                            style: GoogleFonts.orbitron(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: centerColor.withValues(alpha: 0.7),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Show the other metric as a small badge
                          if (!isUpload)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: ulColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: ulColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.upload_rounded,
                                    size: 11,
                                    color: ulColor,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${ulValue.toStringAsFixed(1)} UP',
                                    style: GoogleFonts.sourceCodePro(
                                      color: ulColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: dlColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: dlColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.download_rounded,
                                    size: 11,
                                    color: dlColor,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${dlValue.toStringAsFixed(1)} DL',
                                    style: GoogleFonts.sourceCodePro(
                                      color: dlColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
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
  final SpeedTestPhase phase;
  final Color downloadColor;
  final Color uploadColor;

  _GaugePainter({
    required this.download,
    required this.upload,
    required this.maxSpeed,
    required this.animationValue,
    required this.phase,
    required this.downloadColor,
    required this.uploadColor,
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
      colors: [downloadColor.withValues(alpha: 0.9), downloadColor],
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
        ..color = downloadColor.withValues(alpha: 0.3)
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
        uploadColor.withValues(alpha: 0.9),
        uploadColor,
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
    // During upload, particles flow on the inner (upload) arc
    final isUpload = phase == SpeedTestPhase.upload;
    final particleColor = isUpload ? uploadColor : downloadColor;
    final particleRadius = isUpload ? radius - 35 : radius - 10;
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final pAngle =
          startAngle + (sweepAngle * ((animationValue + i / 8) % 1.0));
      final pPos = Offset(
        center.dx + particleRadius * math.cos(pAngle),
        center.dy + particleRadius * math.sin(pAngle),
      );
      canvas.drawCircle(
        pPos,
        2,
        particlePaint..color = particleColor.withValues(alpha: 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.download != download ||
      oldDelegate.upload != upload ||
      oldDelegate.maxSpeed != maxSpeed ||
      oldDelegate.animationValue != animationValue ||
      oldDelegate.phase != phase ||
      oldDelegate.downloadColor != downloadColor ||
      oldDelegate.uploadColor != uploadColor;
}
