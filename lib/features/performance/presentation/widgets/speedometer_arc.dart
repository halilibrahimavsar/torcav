import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../domain/entities/speed_test_progress.dart';

class SpeedometerArc extends StatefulWidget {
  final double download;
  final double upload;
  final double maxSpeed;
  final SpeedTestPhase phase;
  final Color? downloadColor;
  final Color? uploadColor;

  const SpeedometerArc({
    super.key,
    required this.download,
    required this.upload,
    this.maxSpeed = 100.0,
    this.phase = SpeedTestPhase.idle,
    this.downloadColor,
    this.uploadColor,
  });

  @override
  State<SpeedometerArc> createState() => _SpeedometerArcState();
}

class _SpeedometerArcState extends State<SpeedometerArc>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dlColor = widget.downloadColor ?? AppColors.neonCyan;
    final ulColor = widget.uploadColor ?? AppColors.neonPurple;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: widget.download),
      builder: (context, dlValue, _) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0, end: widget.upload),
          builder: (context, ulValue, _) {
            return AspectRatio(
              aspectRatio: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ── Gauge Base ──
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return CustomPaint(
                        size: Size.infinite,
                        painter: _SpeedometerPainter(
                          download: dlValue,
                          upload: ulValue,
                          maxSpeed: widget.maxSpeed,
                          animationValue: _controller.value,
                          phase: widget.phase,
                          dlColor: dlColor,
                          ulColor: ulColor,
                        ),
                      );
                    },
                  ),

                  // ── Metric Content ──
                  _buildMetricContent(dlValue, ulValue, dlColor, ulColor),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetricContent(
    double dl,
    double ul,
    Color dlColor,
    Color ulColor,
  ) {
    final isIdle = widget.phase == SpeedTestPhase.idle;
    final isUpload = widget.phase == SpeedTestPhase.upload;
    final isDone = widget.phase == SpeedTestPhase.done;

    final centerValue = isUpload ? ul : dl;
    final centerColor = isUpload ? ulColor : dlColor;
    final centerLabel = isUpload ? 'UPLOAD' : 'DOWNLOAD';

    if (isIdle) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.speed_rounded,
            size: 48,
            color: dlColor.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'READY',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: dlColor.withValues(alpha: 0.8),
              letterSpacing: 4,
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
            fontSize: 56,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
          glowColor: centerColor,
          glowRadius: 15,
        ),
        Text(
          'MBPS $centerLabel',
          style: GoogleFonts.orbitron(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: centerColor.withValues(alpha: 0.8),
            letterSpacing: 2,
          ),
        ),
        if (!isDone) ...[
          const SizedBox(height: 20),
          _buildMiniStats(dl, ul, dlColor, ulColor),
        ],
      ],
    );
  }

  Widget _buildMiniStats(double dl, double ul, Color dlColor, Color ulColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _miniStatItem('DL', dl.toStringAsFixed(1), dlColor),
        Container(
          height: 24,
          width: 1,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.white.withValues(alpha: 0.1),
        ),
        _miniStatItem('UL', ul.toStringAsFixed(1), ulColor),
      ],
    );
  }

  Widget _miniStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 8,
            color: color.withValues(alpha: 0.6),
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.sourceCodePro(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double download;
  final double upload;
  final double maxSpeed;
  final double animationValue;
  final SpeedTestPhase phase;
  final Color dlColor;
  final Color ulColor;

  _SpeedometerPainter({
    required this.download,
    required this.upload,
    required this.maxSpeed,
    required this.animationValue,
    required this.phase,
    required this.dlColor,
    required this.ulColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    final dlProgress = (download / maxSpeed).clamp(0.0, 1.0);
    final ulProgress = (upload / maxSpeed).clamp(0.0, 1.0);

    // ── Background Scanning Grid ──
    _drawScanningGrid(canvas, center, radius, animationValue);

    // ── Outer Track Base ──
    final trackPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 15),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // ── Progress Arcs ──
    if (dlProgress > 0) {
      _drawProgressArc(
        canvas: canvas,
        center: center,
        radius: radius - 15,
        startAngle: startAngle,
        sweepAngle: sweepAngle * dlProgress,
        color: dlColor,
        isSecondary: false,
      );
    }

    // ── Inner Track (Upload) ──
    final innerTrackPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.03)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 45),
      startAngle,
      sweepAngle,
      false,
      innerTrackPaint,
    );

    if (ulProgress > 0) {
      _drawProgressArc(
        canvas: canvas,
        center: center,
        radius: radius - 45,
        startAngle: startAngle,
        sweepAngle: sweepAngle * ulProgress,
        color: ulColor,
        isSecondary: true,
      );
    }

    // ── Liquid Pulses ──
    if (phase != SpeedTestPhase.idle && phase != SpeedTestPhase.done) {
      _drawLiquidPulse(
        canvas,
        center,
        radius,
        animationValue,
        phase == SpeedTestPhase.upload ? ulColor : dlColor,
      );
    }

    // ── Tick Marks & Scale ──
    _drawScale(canvas, center, radius, startAngle, sweepAngle);
  }

  void _drawScanningGrid(
    Canvas canvas,
    Offset center,
    double radius,
    double anim,
  ) {
    final gridOpacity = 0.05 + (0.05 * math.sin(anim * math.pi * 2));
    final gridPaint =
        Paint()
          ..color = dlColor.withValues(alpha: gridOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

    // Concentric circles
    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(center, radius * (i / 5), gridPaint);
    }

    // Radial scanning line
    final scanAngle = (anim * 2 * math.pi);
    final scanPaint =
        Paint()
          ..shader = SweepGradient(
            colors: [
              dlColor.withValues(alpha: 0),
              dlColor.withValues(alpha: 0.15),
              dlColor.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.5, 1.0],
            transform: GradientRotation(scanAngle - math.pi / 2),
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, scanPaint);
  }

  void _drawProgressArc({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double startAngle,
    required double sweepAngle,
    required Color color,
    required bool isSecondary,
  }) {
    final strokeWidth = isSecondary ? 6.0 : 16.0;

    // 1. Shadow/Glow base
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 10
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // 2. Main Gradient Arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..shader = SweepGradient(
          colors: [color.withValues(alpha: 0.2), color],
          stops: const [0.0, 1.0],
          transform: GradientRotation(startAngle),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // 3. Flare "Comet" Head
    final headAngle = startAngle + sweepAngle;
    final headPos = Offset(
      center.dx + radius * math.cos(headAngle),
      center.dy + radius * math.sin(headAngle),
    );

    // Bright core
    canvas.drawCircle(
      headPos,
      strokeWidth / 2,
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Outer flare
    canvas.drawCircle(
      headPos,
      strokeWidth * 1.5,
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  void _drawLiquidPulse(
    Canvas canvas,
    Offset center,
    double radius,
    double anim,
    Color color,
  ) {
    for (int i = 0; i < 2; i++) {
      final pAnim = (anim + (i * 0.5)) % 1.0;
      final pPaint =
          Paint()
            ..color = color.withValues(alpha: (1.0 - pAnim) * 0.2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0 - (pAnim * 1.5);

      canvas.drawCircle(
        center,
        (radius * 0.4) + (pAnim * radius * 0.8),
        pPaint,
      );
    }
  }

  void _drawScale(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
  ) {
    final tickPaint = Paint()..strokeCap = StrokeCap.round;

    for (int i = 0; i <= 40; i++) {
      final angle = startAngle + (sweepAngle * (i / 40));
      final isMajor = i % 10 == 0;
      final isMinor = i % 5 == 0;

      final tLen = isMajor ? 12.0 : (isMinor ? 8.0 : 4.0);
      final opacity = isMajor ? 0.4 : (isMinor ? 0.2 : 0.1);

      final p1 = Offset(
        center.dx + (radius - 30) * math.cos(angle),
        center.dy + (radius - 30) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + (radius - 30 - tLen) * math.cos(angle),
        center.dy + (radius - 30 - tLen) * math.sin(angle),
      );

      canvas.drawLine(
        p1,
        p2,
        tickPaint
          ..color = Colors.white.withValues(alpha: opacity)
          ..strokeWidth = isMajor ? 2 : 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedometerPainter oldDelegate) => true;
}
