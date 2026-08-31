import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:torcav/core/theme/app_theme.dart';

/// Premium "guardian" themed background — the app's default.
///
/// Layers (back → front):
///   1. Deep radial gradient base
///   2. Drifting dust motes (parallax)
///   3. Orbiting encrypted nodes + soft connection lines to the core
///   4. Central pulsing hexagonal shield (nested hex rings + crest glow)
///   5. Rotating scan sweep clipped to the shield
///   6. Vignette
class AegisShieldBackground extends StatefulWidget {
  final Color color;
  final Widget? child;
  final ValueNotifier<double> scrollVelocity;

  const AegisShieldBackground({
    super.key,
    required this.color,
    required this.scrollVelocity,
    this.child,
  });

  @override
  State<AegisShieldBackground> createState() => _AegisShieldBackgroundState();
}

class _AegisShieldBackgroundState extends State<AegisShieldBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _smoothedVelocity = 0.0;

  late final List<_Mote> _motes;
  late final List<_ShieldNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();

    final rng = math.Random(7);
    _motes = List.generate(54, (_) {
      return _Mote(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        depth: rng.nextDouble(),
        size: 0.4 + rng.nextDouble() * 1.4,
        twinkle: rng.nextDouble() * math.pi * 2,
      );
    });

    _nodes = List.generate(6, (i) {
      return _ShieldNode(
        orbitRadius: 1.35 + (i % 3) * 0.42,
        speed: 0.35 + rng.nextDouble() * 0.5,
        phase: rng.nextDouble() * math.pi * 2,
        wobble: 0.6 + rng.nextDouble() * 0.8,
        hue: i,
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
              gradient: RadialGradient(
                center: const Alignment(0, -0.15),
                radius: 1.25,
                colors:
                    isLight
                        ? const [Color(0xFFEAF0F6), Color(0xFFC4D0E0)]
                        : const [Color(0xFF0A1322), Color(0xFF02040A)],
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
                  painter: _AegisShieldPainter(
                    progress: _controller.value,
                    velocity: _smoothedVelocity,
                    accent: widget.color,
                    isLight: isLight,
                    motes: _motes,
                    nodes: _nodes,
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
                      alpha: isLight ? 0.16 : 0.6,
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

class _Mote {
  final double x;
  final double y;
  final double depth; // 0=far, 1=near
  final double size;
  final double twinkle;
  _Mote({
    required this.x,
    required this.y,
    required this.depth,
    required this.size,
    required this.twinkle,
  });
}

class _ShieldNode {
  final double orbitRadius; // multiplier of shield radius
  final double speed;
  final double phase;
  final double wobble;
  final int hue;
  _ShieldNode({
    required this.orbitRadius,
    required this.speed,
    required this.phase,
    required this.wobble,
    required this.hue,
  });
}

class _AegisShieldPainter extends CustomPainter {
  final double progress;
  final double velocity;
  final Color accent;
  final bool isLight;
  final List<_Mote> motes;
  final List<_ShieldNode> nodes;

  _AegisShieldPainter({
    required this.progress,
    required this.velocity,
    required this.accent,
    required this.isLight,
    required this.motes,
    required this.nodes,
  });

  static const _hues = [
    AppColors.neonCyan,
    AppColors.neonGreen,
    AppColors.neonPurple,
    AppColors.neonBlue,
    AppColors.neonCyan,
    AppColors.neonGreen,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.42);
    final shieldR = size.shortestSide * 0.2;
    // Gentle breathing pulse 0.94 .. 1.06
    final pulse = 1.0 + 0.06 * math.sin(progress * math.pi * 2);

    _paintMotes(canvas, size);
    _paintNodes(canvas, center, shieldR * pulse);
    _paintShield(canvas, center, shieldR * pulse);
    _paintScanSweep(canvas, center, shieldR * pulse);
  }

  void _paintMotes(Canvas canvas, Size size) {
    final paint = Paint();
    for (final m in motes) {
      final parallax = velocity * (0.04 + m.depth * 0.16);
      final x = (m.x * size.width + parallax) % size.width;
      final y = m.y * size.height;
      final tw = 0.5 + 0.5 * math.sin(progress * 10 + m.twinkle);
      final base = isLight ? AppColors.inkCyan : AppColors.softWhite;
      paint.color = base.withValues(
        alpha: (0.1 + m.depth * 0.45) * tw * (isLight ? 0.5 : 1.0),
      );
      canvas.drawCircle(Offset(x, y), m.size * (0.5 + m.depth * 0.6), paint);
    }
  }

  /// Builds a flat-top hexagon path centred at [c] with circumradius [r].
  Path _hexPath(Offset c, double r, double rotation) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = rotation + i * math.pi / 3;
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  void _paintNodes(Canvas canvas, Offset center, double shieldR) {
    final linkColor = (isLight ? AppColors.inkCyan : AppColors.neonCyan);
    for (final node in nodes) {
      final color = _hues[node.hue % _hues.length];
      final t = progress * math.pi * 2 * node.speed + node.phase;
      final r =
          shieldR *
          node.orbitRadius *
          (1.0 + 0.08 * math.sin(t * node.wobble));
      final pos = center + Offset(math.cos(t) * r, math.sin(t) * r * 0.62);

      // Connection line back to the core
      final linkPaint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8
            ..shader = LinearGradient(
              colors: [
                linkColor.withValues(alpha: 0),
                linkColor.withValues(alpha: isLight ? 0.28 : 0.4),
              ],
            ).createShader(Rect.fromPoints(center, pos));
      canvas.drawLine(center, pos, linkPaint);

      // Node glow + core
      canvas.drawCircle(
        pos,
        3.4,
        Paint()
          ..color = color.withValues(alpha: isLight ? 0.55 : 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(pos, 1.5, Paint()..color = color.withValues(alpha: 1));
    }
  }

  void _paintShield(Canvas canvas, Offset center, double r) {
    final rot = progress * math.pi * 2 * 0.15;
    final lineColor = (isLight ? AppColors.inkCyan : AppColors.neonCyan);

    // Crest glow disc
    canvas.drawCircle(
      center,
      r * 1.5,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(alpha: isLight ? 0.1 : 0.18),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r * 1.5)),
    );

    // Nested hex rings
    for (int i = 0; i < 4; i++) {
      final ringR = r * (0.45 + i * 0.32);
      final ringRot = rot * (i.isEven ? 1 : -1.4) + i * 0.2;
      final alpha = (isLight ? 0.5 : 0.62) * (1.0 - i * 0.18);
      canvas.drawPath(
        _hexPath(center, ringR, ringRot),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 1 ? 1.6 : 1.0
          ..strokeJoin = StrokeJoin.round
          ..color = (i == 1 ? accent : lineColor).withValues(alpha: alpha),
      );
    }

    // Inner filled core
    canvas.drawPath(
      _hexPath(center, r * 0.42, rot),
      Paint()..color = accent.withValues(alpha: isLight ? 0.12 : 0.2),
    );

    // Spokes from core to outer hex vertices
    final spokePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7
          ..color = lineColor.withValues(alpha: isLight ? 0.3 : 0.38);
    for (int i = 0; i < 6; i++) {
      final a = rot + i * math.pi / 3;
      canvas.drawLine(
        center + Offset(math.cos(a) * r * 0.42, math.sin(a) * r * 0.42),
        center + Offset(math.cos(a) * r * 1.41, math.sin(a) * r * 1.41),
        spokePaint,
      );
    }
  }

  void _paintScanSweep(Canvas canvas, Offset center, double r) {
    final sweepR = r * 1.45;
    final angle = progress * math.pi * 2;
    canvas.save();
    canvas.clipPath(_hexPath(center, r * 1.4, progress * math.pi * 2 * 0.15));
    final paint =
        Paint()
          ..shader = SweepGradient(
            startAngle: angle,
            endAngle: angle + math.pi / 2,
            colors: [
              accent.withValues(alpha: isLight ? 0.22 : 0.3),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: center, radius: sweepR));
    canvas.drawCircle(center, sweepR, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AegisShieldPainter old) => true;
}
