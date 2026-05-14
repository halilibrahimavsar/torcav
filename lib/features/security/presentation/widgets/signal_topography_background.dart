import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Calm "signal map" themed background.
///
/// Layers (back → front):
///   1. Diagonal gradient base
///   2. Flowing topographic contour lines (drifting sine fields)
///   3. Drifting light particles (parallax)
///   4. Thin horizontal scan wave that brightens contours it crosses
///   5. Vignette
class SignalTopographyBackground extends StatefulWidget {
  final Color color;
  final Widget? child;
  final ValueNotifier<double> scrollVelocity;

  const SignalTopographyBackground({
    super.key,
    required this.color,
    required this.scrollVelocity,
    this.child,
  });

  @override
  State<SignalTopographyBackground> createState() =>
      _SignalTopographyBackgroundState();
}

class _SignalTopographyBackgroundState extends State<SignalTopographyBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _smoothedVelocity = 0.0;

  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 32),
    )..repeat();

    final rng = math.Random(19);
    _particles = List.generate(46, (_) {
      return _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        depth: rng.nextDouble(),
        size: 0.5 + rng.nextDouble() * 1.5,
        twinkle: rng.nextDouble() * math.pi * 2,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isLight
                        ? const [Color(0xFFEDF1F6), Color(0xFFC9D4E1)]
                        : const [Color(0xFF071019), Color(0xFF02060A)],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: Listenable.merge([_controller, widget.scrollVelocity]),
              builder: (context, _) {
                _smoothedVelocity =
                    _smoothedVelocity * 0.88 +
                    (widget.scrollVelocity.value / 4.0).clamp(0.0, 250.0) *
                        0.12;
                widget.scrollVelocity.value *= 0.94;
                return CustomPaint(
                  painter: _SignalTopographyPainter(
                    progress: _controller.value,
                    velocity: _smoothedVelocity,
                    accent: widget.color,
                    isLight: isLight,
                    particles: _particles,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.3,
                  colors: [
                    Colors.transparent,
                    (isLight ? Colors.white : Colors.black).withValues(
                      alpha: isLight ? 0.16 : 0.58,
                    ),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double depth; // 0=far, 1=near
  final double size;
  final double twinkle;
  _Particle({
    required this.x,
    required this.y,
    required this.depth,
    required this.size,
    required this.twinkle,
  });
}

class _SignalTopographyPainter extends CustomPainter {
  final double progress;
  final double velocity;
  final Color accent;
  final bool isLight;
  final List<_Particle> particles;

  _SignalTopographyPainter({
    required this.progress,
    required this.velocity,
    required this.accent,
    required this.isLight,
    required this.particles,
  });

  static const _lineCount = 16;

  @override
  void paint(Canvas canvas, Size size) {
    _paintContours(canvas, size);
    _paintParticles(canvas, size);
    _paintScanWave(canvas, size);
  }

  /// Vertical offset of contour [index] at horizontal position [x] (0..1).
  double _fieldY(int index, double x, Size size) {
    final base = (index + 0.5) / _lineCount * size.height;
    final drift = progress * math.pi * 2;
    final amp = size.height * 0.045;
    final phase = index * 0.6;
    return base +
        amp *
            math.sin(x * 3.1 + drift + phase) *
            math.cos(x * 1.7 - drift * 0.6 + phase) +
        amp * 0.5 * math.sin(x * 6.3 - drift * 1.3 + phase);
  }

  void _paintContours(Canvas canvas, Size size) {
    final lineColor = isLight ? AppColors.inkCyan : AppColors.neonCyan;
    const steps = 48;
    final scanY = ((progress * 1.6) % 1.4 - 0.2) * size.height;

    for (int i = 0; i < _lineCount; i++) {
      final path = Path();
      for (int s = 0; s <= steps; s++) {
        final x = s / steps;
        final px = x * size.width;
        final py = _fieldY(i, x, size);
        if (s == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      // Lines near the scan wave glow brighter.
      final midY = _fieldY(i, 0.5, size);
      final prox = (1.0 - (midY - scanY).abs() / (size.height * 0.18)).clamp(
        0.0,
        1.0,
      );
      final baseAlpha = (isLight ? 0.18 : 0.22) + 0.06 * (i / _lineCount);
      final glow = prox * (isLight ? 0.35 : 0.5);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9 + prox * 1.1
          ..color =
              Color.lerp(
                lineColor.withValues(alpha: baseAlpha),
                accent.withValues(alpha: baseAlpha + glow),
                prox,
              )!,
      );
    }
  }

  void _paintParticles(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final parallax = velocity * (0.05 + p.depth * 0.18);
      final x = (p.x * size.width + parallax) % size.width;
      final y = p.y * size.height;
      final tw = 0.5 + 0.5 * math.sin(progress * 9 + p.twinkle);
      final base = isLight ? AppColors.inkCyan : AppColors.softWhite;
      paint.color = base.withValues(
        alpha: (0.12 + p.depth * 0.5) * tw * (isLight ? 0.5 : 1.0),
      );
      canvas.drawCircle(Offset(x, y), p.size * (0.5 + p.depth * 0.7), paint);
    }
  }

  void _paintScanWave(Canvas canvas, Size size) {
    final scanY = ((progress * 1.6) % 1.4 - 0.2) * size.height;
    final band = size.height * 0.16;
    final rect = Rect.fromLTWH(0, scanY - band, size.width, band * 2);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            accent.withValues(alpha: isLight ? 0.1 : 0.14),
            Colors.transparent,
          ],
        ).createShader(rect),
    );
    canvas.drawLine(
      Offset(0, scanY),
      Offset(size.width, scanY),
      Paint()
        ..strokeWidth = 1.0
        ..color = accent.withValues(alpha: isLight ? 0.3 : 0.4),
    );
  }

  @override
  bool shouldRepaint(covariant _SignalTopographyPainter old) => true;
}
