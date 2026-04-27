import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Premium "command center" themed background.
///
/// Layers (back → front):
///   1. Deep gradient base
///   2. Parallax starfield (3 depths)
///   3. Orbital path ellipses (HUD rings)
///   4. Wireframe rotating sphere — latitude + longitude lines (3D projection)
///   5. Orbiting satellites with glow trails
///   6. Equatorial scanning beam (sweep)
///   7. HUD reticle ticks at frame edges
///   8. Vignette
class HoloSphereBackground extends StatefulWidget {
  final Color color;
  final Widget? child;
  final ValueNotifier<double> scrollVelocity;

  const HoloSphereBackground({
    super.key,
    required this.color,
    required this.scrollVelocity,
    this.child,
  });

  @override
  State<HoloSphereBackground> createState() => _HoloSphereBackgroundState();
}

class _HoloSphereBackgroundState extends State<HoloSphereBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _smoothedVelocity = 0.0;

  late final List<_Star> _stars;
  late final List<_Satellite> _satellites;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    final rng = math.Random(42);
    _stars = List.generate(80, (_) {
      return _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        depth: rng.nextDouble(),
        size: 0.4 + rng.nextDouble() * 1.6,
        twinkle: rng.nextDouble() * math.pi * 2,
      );
    });

    _satellites = List.generate(5, (i) {
      return _Satellite(
        orbitTilt: -0.6 + rng.nextDouble() * 1.2,
        orbitRadius: 0.85 + i * 0.2,
        speed: 0.4 + rng.nextDouble() * 0.7,
        phase: rng.nextDouble() * math.pi * 2,
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
                center: const Alignment(0, -0.2),
                radius: 1.2,
                colors: isLight
                    ? const [Color(0xFFE8EEF5), Color(0xFFC7D3E3)]
                    : const [Color(0xFF071224), Color(0xFF02050C)],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: Listenable.merge([_controller, widget.scrollVelocity]),
              builder: (context, _) {
                _smoothedVelocity = _smoothedVelocity * 0.88 +
                    (widget.scrollVelocity.value / 4.0).clamp(0.0, 250.0) *
                        0.12;
                widget.scrollVelocity.value *= 0.94;
                return CustomPaint(
                  painter: _HoloSpherePainter(
                    progress: _controller.value,
                    velocity: _smoothedVelocity,
                    accent: widget.color,
                    isLight: isLight,
                    stars: _stars,
                    satellites: _satellites,
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
                  center: Alignment.center,
                  radius: 1.3,
                  colors: [
                    Colors.transparent,
                    (isLight ? Colors.white : Colors.black)
                        .withValues(alpha: isLight ? 0.18 : 0.6),
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

class _Star {
  final double x;
  final double y;
  final double depth; // 0=far, 1=near
  final double size;
  final double twinkle;
  _Star({
    required this.x,
    required this.y,
    required this.depth,
    required this.size,
    required this.twinkle,
  });
}

class _Satellite {
  final double orbitTilt; // -1..1
  final double orbitRadius; // multiplier of sphere radius
  final double speed;
  final double phase;
  final int hue;
  _Satellite({
    required this.orbitTilt,
    required this.orbitRadius,
    required this.speed,
    required this.phase,
    required this.hue,
  });
}

class _HoloSpherePainter extends CustomPainter {
  final double progress;
  final double velocity;
  final Color accent;
  final bool isLight;
  final List<_Star> stars;
  final List<_Satellite> satellites;

  _HoloSpherePainter({
    required this.progress,
    required this.velocity,
    required this.accent,
    required this.isLight,
    required this.stars,
    required this.satellites,
  });

  static const _hues = [
    AppColors.neonCyan,
    AppColors.neonPurple,
    AppColors.neonGreen,
    AppColors.neonOrange,
    AppColors.neonBlue,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.42);
    final sphereR = size.shortestSide * 0.32;

    _paintStars(canvas, size);
    _paintOrbitRings(canvas, center, sphereR);
    _paintSphere(canvas, center, sphereR);
    _paintSatellites(canvas, center, sphereR);
    _paintScanBeam(canvas, center, sphereR);
    _paintHudTicks(canvas, size);
  }

  void _paintStars(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in stars) {
      final parallax = velocity * (0.05 + star.depth * 0.15);
      final x = (star.x * size.width + parallax) % size.width;
      final y = star.y * size.height;
      final tw = 0.55 + 0.45 * math.sin(progress * 12 + star.twinkle);
      final base = isLight ? AppColors.inkCyan : AppColors.softWhite;
      paint.color = base.withValues(
        alpha: (0.15 + star.depth * 0.55) * tw * (isLight ? 0.5 : 1.0),
      );
      canvas.drawCircle(Offset(x, y), star.size * (0.5 + star.depth * 0.7),
          paint);
    }
  }

  void _paintOrbitRings(Canvas canvas, Offset center, double r) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    for (int i = 1; i <= 4; i++) {
      final mult = 0.85 + i * 0.22;
      final alpha = (0.18 - i * 0.03) * (isLight ? 0.7 : 1.0);
      paint.color = accent.withValues(alpha: alpha);
      final rect = Rect.fromCenter(
        center: center,
        width: r * 2.2 * mult,
        height: r * 0.9 * mult,
      );
      canvas.drawOval(rect, paint);
    }
  }

  void _paintSphere(Canvas canvas, Offset center, double r) {
    final rotY = progress * math.pi * 2;
    final tilt = 0.35; // earth-like tilt
    final cosT = math.cos(tilt);
    final sinT = math.sin(tilt);

    final lineColor = (isLight ? AppColors.inkCyan : AppColors.neonCyan)
        .withValues(alpha: isLight ? 0.42 : 0.55);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = lineColor;

    // Soft inner glow disc
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: isLight ? 0.08 : 0.14),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r * 1.1));
    canvas.drawCircle(center, r * 1.1, glowPaint);

    // Latitudes (horizontal slices)
    const latCount = 9;
    for (int i = 1; i < latCount; i++) {
      final lat = math.pi * (i / latCount) - math.pi / 2;
      final y = math.sin(lat) * r;
      final ringR = math.cos(lat) * r;
      // tilt projection: rotate (0, y, 0) around X axis
      final yProj = y * cosT;
      // ellipse height after tilt
      final ellH = ringR * sinT.abs() * 2;
      final rect = Rect.fromCenter(
        center: center + Offset(0, yProj),
        width: ringR * 2,
        height: ellH.clamp(2.0, double.infinity),
      );
      paint.color = lineColor.withValues(
        alpha: lineColor.a * (0.6 + 0.4 * math.sin(lat).abs()),
      );
      canvas.drawOval(rect, paint);
    }

    // Longitudes (rotating verticals)
    const lonCount = 12;
    for (int i = 0; i < lonCount; i++) {
      final lon = (i / lonCount) * math.pi * 2 + rotY;
      // Visibility (front-facing brighter)
      final facing = math.cos(lon).clamp(-1.0, 1.0);
      if (facing < -0.05) continue;
      final alpha = lineColor.a * (0.25 + facing * 0.75);

      final path = Path();
      const steps = 24;
      for (int s = 0; s <= steps; s++) {
        final lat = -math.pi / 2 + (s / steps) * math.pi;
        // 3D point on sphere
        final x3 = math.cos(lat) * math.sin(lon) * r;
        final y3 = math.sin(lat) * r;
        final z3 = math.cos(lat) * math.cos(lon) * r;
        // Rotate around X (tilt)
        final yT = y3 * cosT - z3 * sinT;
        final px = center.dx + x3;
        final py = center.dy + yT;
        if (s == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      paint.color = lineColor.withValues(alpha: alpha);
      canvas.drawPath(path, paint);
    }

    // Outline
    paint
      ..color = lineColor.withValues(alpha: lineColor.a * 0.9)
      ..strokeWidth = 1.1;
    canvas.drawCircle(center, r, paint);
  }

  void _paintSatellites(Canvas canvas, Offset center, double r) {
    for (final sat in satellites) {
      final color = _hues[sat.hue % _hues.length];
      final t = progress * math.pi * 2 * sat.speed + sat.phase;
      // Orbit on tilted ellipse: param eq
      final ox = math.cos(t) * r * sat.orbitRadius;
      final oy = math.sin(t) * r * sat.orbitRadius * 0.5;
      // Apply tilt
      final cosT = math.cos(sat.orbitTilt);
      final sinT = math.sin(sat.orbitTilt);
      final px = ox * cosT - oy * sinT;
      final py = ox * sinT + oy * cosT;
      final pos = center + Offset(px, py);

      // Trail
      const trailSteps = 14;
      final trailPath = Path();
      for (int i = 0; i < trailSteps; i++) {
        final tt = t - (i / trailSteps) * 0.4;
        final tx = math.cos(tt) * r * sat.orbitRadius;
        final ty = math.sin(tt) * r * sat.orbitRadius * 0.5;
        final tpx = tx * cosT - ty * sinT;
        final tpy = tx * sinT + ty * cosT;
        final tp = center + Offset(tpx, tpy);
        if (i == 0) {
          trailPath.moveTo(tp.dx, tp.dy);
        } else {
          trailPath.lineTo(tp.dx, tp.dy);
        }
      }
      final trailPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            color.withValues(alpha: isLight ? 0.7 : 0.9),
            color.withValues(alpha: 0),
          ],
        ).createShader(
          Rect.fromCenter(center: pos, width: r, height: r * 0.5),
        );
      canvas.drawPath(trailPath, trailPaint);

      // Body + glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: isLight ? 0.6 : 0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(pos, 3.2, glowPaint);

      final corePaint = Paint()..color = color.withValues(alpha: 1);
      canvas.drawCircle(pos, 1.6, corePaint);
    }
  }

  void _paintScanBeam(Canvas canvas, Offset center, double r) {
    // Vertical sweeping beam crossing the sphere
    final t = progress * 2.0; // 0..2
    final phase = (t % 2.0) - 1.0; // -1..1
    final x = center.dx + phase * r;
    final beamColor = accent.withValues(alpha: isLight ? 0.18 : 0.22);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          beamColor,
          beamColor,
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(
        Rect.fromLTWH(x - 6, center.dy - r, 12, r * 2),
      );
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: r)));
    canvas.drawRect(
      Rect.fromLTWH(x - 6, center.dy - r, 12, r * 2),
      paint,
    );
    canvas.restore();
  }

  void _paintHudTicks(Canvas canvas, Size size) {
    final color = accent.withValues(alpha: isLight ? 0.35 : 0.45);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const corner = 18.0;
    const tick = 10.0;
    // Four corners
    final corners = [
      const Offset(corner, corner),
      Offset(size.width - corner, corner),
      Offset(corner, size.height - corner),
      Offset(size.width - corner, size.height - corner),
    ];
    for (int i = 0; i < 4; i++) {
      final c = corners[i];
      final dx = i.isEven ? 1.0 : -1.0;
      final dy = i < 2 ? 1.0 : -1.0;
      canvas.drawLine(c, c + Offset(tick * dx, 0), paint);
      canvas.drawLine(c, c + Offset(0, tick * dy), paint);
    }

    // Top/bottom center reticle
    final cx = size.width / 2;
    canvas.drawLine(Offset(cx - 6, 8), Offset(cx + 6, 8), paint);
    canvas.drawLine(Offset(cx, 4), Offset(cx, 14), paint);
  }

  @override
  bool shouldRepaint(covariant _HoloSpherePainter old) => true;
}
