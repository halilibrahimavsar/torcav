import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Premium WiFi-analyzer themed background.
///
/// Layers (back → front):
///   1. Deep gradient base
///   2. Aurora blobs — slowly drifting radial gradients
///   3. Hex mesh — animated hexagonal lattice with pulsing nodes
///   4. Radar sweep — rotating cone with trailing fade from a focal point
///   5. Signal rings — concentric pulses emitted from the radar focus
///   6. Spectrum analyzer — frequency bars across the bottom
///   7. Vignette — darkening for content readability
class AuroraMeshBackground extends StatefulWidget {
  final Color color;
  final Widget? child;
  final ValueNotifier<double> scrollVelocity;

  const AuroraMeshBackground({
    super.key,
    required this.color,
    required this.scrollVelocity,
    this.child,
  });

  @override
  State<AuroraMeshBackground> createState() => _AuroraMeshBackgroundState();
}

class _AuroraMeshBackgroundState extends State<AuroraMeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _smoothedVelocity = 0.0;

  late final List<_SpectrumBar> _bars;
  late final List<_AuroraBlob> _blobs;
  late final List<_SignalRing> _rings;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    final rng = math.Random(7);
    _bars = List.generate(48, (i) {
      return _SpectrumBar(
        seed: rng.nextDouble() * 100,
        speed: 0.6 + rng.nextDouble() * 1.4,
      );
    });

    _blobs = [
      _AuroraBlob(
        baseColor: AppColors.neonCyan,
        cx: 0.2,
        cy: 0.25,
        radius: 0.55,
        driftX: 0.08,
        driftY: 0.05,
        phase: 0.0,
      ),
      _AuroraBlob(
        baseColor: AppColors.neonPurple,
        cx: 0.85,
        cy: 0.2,
        radius: 0.5,
        driftX: -0.07,
        driftY: 0.06,
        phase: 1.4,
      ),
      _AuroraBlob(
        baseColor: AppColors.neonBlue,
        cx: 0.7,
        cy: 0.85,
        radius: 0.6,
        driftX: 0.06,
        driftY: -0.05,
        phase: 2.6,
      ),
      _AuroraBlob(
        baseColor: AppColors.neonGreen,
        cx: 0.15,
        cy: 0.8,
        radius: 0.45,
        driftX: -0.05,
        driftY: -0.06,
        phase: 3.9,
      ),
    ];

    _rings = List.generate(4, (i) => _SignalRing(phase: i / 4.0));
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
                colors: isLight
                    ? const [
                        Color(0xFFEFF3F8),
                        Color(0xFFDDE6F0),
                        Color(0xFFC9D6E4),
                      ]
                    : const [
                        Color(0xFF050912),
                        Color(0xFF0A1428),
                        Color(0xFF050912),
                      ],
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
                    (widget.scrollVelocity.value / 4.0).clamp(0.0, 250.0) * 0.12;
                widget.scrollVelocity.value *= 0.94;

                return CustomPaint(
                  painter: _AuroraMeshPainter(
                    progress: _controller.value,
                    velocity: _smoothedVelocity,
                    accent: widget.color,
                    isLight: isLight,
                    bars: _bars,
                    blobs: _blobs,
                    rings: _rings,
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
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    (isLight ? Colors.white : Colors.black)
                        .withValues(alpha: isLight ? 0.18 : 0.55),
                  ],
                  stops: const [0.55, 1.0],
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

class _SpectrumBar {
  final double seed;
  final double speed;
  _SpectrumBar({required this.seed, required this.speed});

  double amplitude(double progress, double velocity) {
    final t = progress * math.pi * 2 * speed + seed;
    final base = 0.35 + 0.35 * math.sin(t) + 0.15 * math.sin(t * 2.7);
    final boost = (velocity / 80.0).clamp(0.0, 0.4);
    return (base + boost).clamp(0.05, 1.0);
  }
}

class _AuroraBlob {
  final Color baseColor;
  final double cx;
  final double cy;
  final double radius;
  final double driftX;
  final double driftY;
  final double phase;

  _AuroraBlob({
    required this.baseColor,
    required this.cx,
    required this.cy,
    required this.radius,
    required this.driftX,
    required this.driftY,
    required this.phase,
  });

  Offset center(Size size, double progress) {
    final t = progress * math.pi * 2;
    final x = cx + driftX * math.sin(t + phase);
    final y = cy + driftY * math.cos(t * 0.8 + phase);
    return Offset(x * size.width, y * size.height);
  }
}

class _SignalRing {
  final double phase;
  _SignalRing({required this.phase});
}

class _AuroraMeshPainter extends CustomPainter {
  final double progress;
  final double velocity;
  final Color accent;
  final bool isLight;
  final List<_SpectrumBar> bars;
  final List<_AuroraBlob> blobs;
  final List<_SignalRing> rings;

  _AuroraMeshPainter({
    required this.progress,
    required this.velocity,
    required this.accent,
    required this.isLight,
    required this.bars,
    required this.blobs,
    required this.rings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintAurora(canvas, size);
    _paintHexMesh(canvas, size);
    _paintSignalRings(canvas, size);
    _paintRadarSweep(canvas, size);
    _paintSpectrum(canvas, size);
  }

  // ── Aurora Blobs ──────────────────────────────────────────────────
  void _paintAurora(Canvas canvas, Size size) {
    final blobAlpha = isLight ? 0.22 : 0.32;
    canvas.saveLayer(Offset.zero & size, Paint());
    for (final blob in blobs) {
      final c = blob.center(size, progress);
      final r = blob.radius * size.shortestSide;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            blob.baseColor.withValues(alpha: blobAlpha),
            blob.baseColor.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r))
        ..blendMode = BlendMode.plus;
      canvas.drawCircle(c, r, paint);
    }
    canvas.restore();
  }

  // ── Hex Mesh ──────────────────────────────────────────────────────
  void _paintHexMesh(Canvas canvas, Size size) {
    const hexSize = 38.0;
    final hexW = hexSize * math.sqrt(3);
    final hexH = hexSize * 1.5;

    final lineColor = (isLight ? AppColors.inkCyan : AppColors.neonCyan)
        .withValues(alpha: isLight ? 0.18 : 0.16);
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final cols = (size.width / hexW).ceil() + 2;
    final rows = (size.height / hexH).ceil() + 2;

    final drift = velocity * 0.4;

    for (int r = -1; r < rows; r++) {
      for (int c = -1; c < cols; c++) {
        final offsetX = (r.isOdd ? hexW / 2 : 0);
        final cx = c * hexW + offsetX;
        final cy = r * hexH + (drift % hexH);

        // Skip far off-screen
        if (cx < -hexW || cx > size.width + hexW) continue;

        // Pulse — distance-based wave
        final dist = (Offset(cx, cy) - size.center(Offset.zero)).distance;
        final wave = math.sin(progress * math.pi * 4 - dist / 90.0);
        final alphaMul = (0.4 + 0.6 * wave).clamp(0.0, 1.0);

        _drawHex(canvas, Offset(cx, cy), hexSize, linePaint, alphaMul);

        // Pulsing node at vertex if wave is high
        if (wave > 0.78) {
          final nodeAlpha = ((wave - 0.78) / 0.22).clamp(0.0, 1.0);
          final nodePaint = Paint()
            ..color = accent.withValues(alpha: nodeAlpha * (isLight ? 0.7 : 0.9))
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
          canvas.drawCircle(Offset(cx, cy), 2.2, nodePaint);
        }
      }
    }
  }

  void _drawHex(
    Canvas canvas,
    Offset center,
    double size,
    Paint basePaint,
    double alphaMul,
  ) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = math.pi / 3 * i + math.pi / 6;
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final paint = Paint()
      ..color = basePaint.color.withValues(alpha: basePaint.color.a * alphaMul)
      ..strokeWidth = basePaint.strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  // ── Radar Sweep ───────────────────────────────────────────────────
  void _paintRadarSweep(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.42);
    final radius = size.shortestSide * 0.55;

    final sweepAngle = (progress * math.pi * 2) % (math.pi * 2);

    // Base disc fade
    final discPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: isLight ? 0.06 : 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, discPaint);

    // Sweep cone
    const sweepWidth = math.pi / 4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: sweepAngle - sweepWidth,
        endAngle: sweepAngle,
        colors: [
          Colors.transparent,
          accent.withValues(alpha: isLight ? 0.12 : 0.18),
        ],
        transform: GradientRotation(0),
      ).createShader(rect);

    canvas.save();
    final clip = Path()..addOval(rect);
    canvas.clipPath(clip);
    final wedge = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(rect, sweepAngle - sweepWidth, sweepWidth, false)
      ..close();
    canvas.drawPath(wedge, sweepPaint);
    canvas.restore();

    // Crosshair
    final axisPaint = Paint()
      ..color = accent.withValues(alpha: isLight ? 0.18 : 0.22)
      ..strokeWidth = 0.8;
    for (int i = 0; i < 4; i++) {
      final a = math.pi / 2 * i;
      canvas.drawLine(
        center,
        center + Offset(math.cos(a), math.sin(a)) * radius,
        axisPaint,
      );
    }

    // Concentric guide rings
    final guidePaint = Paint()
      ..color = accent.withValues(alpha: isLight ? 0.1 : 0.13)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * (i / 3), guidePaint);
    }
  }

  // ── Signal Rings ──────────────────────────────────────────────────
  void _paintSignalRings(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.42);
    final maxR = size.shortestSide * 0.6;

    for (final ring in rings) {
      final t = (progress + ring.phase) % 1.0;
      final r = maxR * t;
      final alpha = (1.0 - t) * (isLight ? 0.35 : 0.45);

      final paint = Paint()
        ..color = accent.withValues(alpha: alpha)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, r, paint);
    }
  }

  // ── Spectrum Analyzer ─────────────────────────────────────────────
  void _paintSpectrum(Canvas canvas, Size size) {
    final baseY = size.height;
    final maxBarH = size.height * 0.18;
    final barW = size.width / bars.length;
    final gap = barW * 0.25;

    for (int i = 0; i < bars.length; i++) {
      final amp = bars[i].amplitude(progress, velocity);
      final h = amp * maxBarH;
      final x = i * barW + gap / 2;
      final rect = Rect.fromLTWH(x, baseY - h, barW - gap, h);

      // Frequency-based color: cyan → green → magenta
      final freq = i / bars.length;
      final Color barColor;
      if (freq < 0.5) {
        barColor = Color.lerp(
          AppColors.neonCyan,
          AppColors.neonGreen,
          freq * 2,
        )!;
      } else {
        barColor = Color.lerp(
          AppColors.neonGreen,
          AppColors.neonMagenta,
          (freq - 0.5) * 2,
        )!;
      }

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            barColor.withValues(alpha: isLight ? 0.55 : 0.75),
            barColor.withValues(alpha: 0),
          ],
        ).createShader(rect);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );

      // Peak cap
      if (amp > 0.55) {
        final capPaint = Paint()
          ..color = barColor.withValues(alpha: isLight ? 0.7 : 0.95)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
        canvas.drawRect(
          Rect.fromLTWH(x, baseY - h, barW - gap, 2),
          capPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraMeshPainter old) => true;
}
