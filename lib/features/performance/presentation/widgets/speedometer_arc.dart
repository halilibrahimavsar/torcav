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
      double dl, double ul, Color dlColor, Color ulColor) {
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

    // ── Grid Lines (Background) ──
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 10; i++) {
        canvas.drawCircle(center, radius * (i / 10), gridPaint);
    }

    // ── Outer Track ──
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // ── Download Progress ──
    if (dlProgress > 0) {
      final dlPaint = Paint()
        ..shader = SweepGradient(
          colors: [dlColor.withValues(alpha: 0.5), dlColor],
          stops: const [0.0, 1.0],
          transform: GradientRotation(startAngle),
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round;

      // Outer glow
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 10),
        startAngle,
        sweepAngle * dlProgress,
        false,
        Paint()
          ..color = dlColor.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 30
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 10),
        startAngle,
        sweepAngle * dlProgress,
        false,
        dlPaint,
      );
    }

    // ── Upload Progress (Inner Ring) ──
    final innerTrackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 40),
      startAngle,
      sweepAngle,
      false,
      innerTrackPaint,
    );

    if (ulProgress > 0) {
      final ulPaint = Paint()
        ..color = ulColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 40),
        startAngle,
        sweepAngle * ulProgress,
        false,
        ulPaint,
      );
    }

    // ── Dynamic Pulses ──
    if (phase != SpeedTestPhase.idle && phase != SpeedTestPhase.done) {
        final activeColor = phase == SpeedTestPhase.upload ? ulColor : dlColor;
        final pulseRadius = radius - 10;
        
        final pulsePaint = Paint()
          ..color = activeColor.withValues(alpha: (1.0 - animationValue) * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawCircle(center, pulseRadius + (animationValue * 20), pulsePaint);
    }

    // ── Tick Marks ──
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 2;

    for (int i = 0; i <= 30; i++) {
        final angle = startAngle + (sweepAngle * (i / 30));
        final isMajor = i % 5 == 0;
        final tLength = isMajor ? 12.0 : 6.0;
        
        final p1 = Offset(
            center.dx + (radius - 20) * math.cos(angle),
            center.dy + (radius - 20) * math.sin(angle),
        );
        final p2 = Offset(
            center.dx + (radius - 20 - tLength) * math.cos(angle),
            center.dy + (radius - 20 - tLength) * math.sin(angle),
        );
        
        canvas.drawLine(p1, p2, tickPaint..color = Colors.white.withValues(alpha: isMajor ? 0.3 : 0.1));
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedometerPainter oldDelegate) => true;
}
