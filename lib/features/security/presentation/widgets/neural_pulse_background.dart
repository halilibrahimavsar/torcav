import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Premium neural-network themed background.
///
/// Layers (back → front):
///   1. Deep gradient base
///   2. Floating dust particles
///   3. Synapse curves — Bezier connections between neuron nodes
///   4. Traveling pulses along synapses (luminous packets)
///   5. Neuron nodes — soft pulsing glow
///   6. EEG-style waveform along bottom
///   7. Vignette
class NeuralPulseBackground extends StatefulWidget {
  final Color color;
  final Widget? child;
  final ValueNotifier<double> scrollVelocity;

  const NeuralPulseBackground({
    super.key,
    required this.color,
    required this.scrollVelocity,
    this.child,
  });

  @override
  State<NeuralPulseBackground> createState() => _NeuralPulseBackgroundState();
}

class _NeuralPulseBackgroundState extends State<NeuralPulseBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _smoothedVelocity = 0.0;

  late final List<_Neuron> _neurons;
  late final List<_Synapse> _synapses;
  late final List<_Dust> _dust;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    final rng = math.Random(11);

    _neurons = List.generate(14, (i) {
      return _Neuron(
        x: 0.08 + rng.nextDouble() * 0.84,
        y: 0.12 + rng.nextDouble() * 0.7,
        baseRadius: 4.0 + rng.nextDouble() * 4.0,
        pulsePhase: rng.nextDouble() * math.pi * 2,
        hue: i % _NeuralPainter.hues.length,
      );
    });

    // Build synapses by connecting each neuron to its 2 nearest peers
    _synapses = [];
    for (int i = 0; i < _neurons.length; i++) {
      final distances = <MapEntry<int, double>>[];
      for (int j = 0; j < _neurons.length; j++) {
        if (i == j) continue;
        final dx = _neurons[i].x - _neurons[j].x;
        final dy = _neurons[i].y - _neurons[j].y;
        distances.add(MapEntry(j, dx * dx + dy * dy));
      }
      distances.sort((a, b) => a.value.compareTo(b.value));
      for (int k = 0; k < 2; k++) {
        final j = distances[k].key;
        if (j > i) {
          _synapses.add(_Synapse(
            from: i,
            to: j,
            curveOffset: -0.15 + rng.nextDouble() * 0.3,
            pulseSeed: rng.nextDouble(),
            pulseSpeed: 0.4 + rng.nextDouble() * 0.6,
          ));
        }
      }
    }

    _dust = List.generate(60, (_) {
      return _Dust(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: 0.6 + rng.nextDouble() * 1.4,
        drift: 0.04 + rng.nextDouble() * 0.08,
        phase: rng.nextDouble() * math.pi * 2,
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
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isLight
                    ? const [
                        Color(0xFFF1EBFA),
                        Color(0xFFE5DCEF),
                        Color(0xFFCFC4DE),
                      ]
                    : const [
                        Color(0xFF0A0618),
                        Color(0xFF120A28),
                        Color(0xFF06030E),
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
                    (widget.scrollVelocity.value / 4.0).clamp(0.0, 250.0) *
                        0.12;
                widget.scrollVelocity.value *= 0.94;
                return CustomPaint(
                  painter: _NeuralPainter(
                    progress: _controller.value,
                    velocity: _smoothedVelocity,
                    accent: widget.color,
                    isLight: isLight,
                    neurons: _neurons,
                    synapses: _synapses,
                    dust: _dust,
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
                  radius: 1.25,
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

class _Neuron {
  final double x;
  final double y;
  final double baseRadius;
  final double pulsePhase;
  final int hue;
  _Neuron({
    required this.x,
    required this.y,
    required this.baseRadius,
    required this.pulsePhase,
    required this.hue,
  });
}

class _Synapse {
  final int from;
  final int to;
  final double curveOffset;
  final double pulseSeed;
  final double pulseSpeed;
  _Synapse({
    required this.from,
    required this.to,
    required this.curveOffset,
    required this.pulseSeed,
    required this.pulseSpeed,
  });
}

class _Dust {
  final double x;
  final double y;
  final double size;
  final double drift;
  final double phase;
  _Dust({
    required this.x,
    required this.y,
    required this.size,
    required this.drift,
    required this.phase,
  });
}

class _NeuralPainter extends CustomPainter {
  final double progress;
  final double velocity;
  final Color accent;
  final bool isLight;
  final List<_Neuron> neurons;
  final List<_Synapse> synapses;
  final List<_Dust> dust;

  _NeuralPainter({
    required this.progress,
    required this.velocity,
    required this.accent,
    required this.isLight,
    required this.neurons,
    required this.synapses,
    required this.dust,
  });

  static const hues = [
    AppColors.neonCyan,
    AppColors.neonPurple,
    AppColors.neonMagenta,
    AppColors.neonBlue,
    AppColors.neonGreen,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _paintDust(canvas, size);
    _paintSynapses(canvas, size);
    _paintPulses(canvas, size);
    _paintNeurons(canvas, size);
    _paintEeg(canvas, size);
  }

  Offset _neuronPos(_Neuron n, Size size) {
    final wobble = math.sin(progress * math.pi * 2 + n.pulsePhase) * 6;
    return Offset(n.x * size.width, n.y * size.height + wobble);
  }

  Offset _synapseControl(Offset a, Offset b, double curve) {
    final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1) return mid;
    // perpendicular
    final nx = -dy / len;
    final ny = dx / len;
    return mid + Offset(nx * curve * len, ny * curve * len);
  }

  Offset _bezier(Offset a, Offset c, Offset b, double t) {
    final u = 1 - t;
    return Offset(
      u * u * a.dx + 2 * u * t * c.dx + t * t * b.dx,
      u * u * a.dy + 2 * u * t * c.dy + t * t * b.dy,
    );
  }

  void _paintDust(Canvas canvas, Size size) {
    final paint = Paint();
    final base = isLight ? AppColors.inkPurple : AppColors.softWhite;
    for (final d in dust) {
      final drift = velocity * d.drift * 0.4;
      final x = (d.x * size.width + drift) % size.width;
      final y = (d.y * size.height +
              math.sin(progress * math.pi * 2 + d.phase) * 8) %
          size.height;
      final alpha = (0.18 + 0.18 * math.sin(progress * 8 + d.phase)) *
          (isLight ? 0.4 : 0.7);
      paint.color = base.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), d.size, paint);
    }
  }

  void _paintSynapses(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;
    final lineColor = (isLight ? AppColors.inkCyan : AppColors.neonCyan)
        .withValues(alpha: isLight ? 0.28 : 0.28);

    for (final s in synapses) {
      final a = _neuronPos(neurons[s.from], size);
      final b = _neuronPos(neurons[s.to], size);
      final c = _synapseControl(a, b, s.curveOffset);
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(c.dx, c.dy, b.dx, b.dy);
      paint.color = lineColor;
      canvas.drawPath(path, paint);
    }
  }

  void _paintPulses(Canvas canvas, Size size) {
    for (final s in synapses) {
      final a = _neuronPos(neurons[s.from], size);
      final b = _neuronPos(neurons[s.to], size);
      final c = _synapseControl(a, b, s.curveOffset);
      final t = (progress * s.pulseSpeed + s.pulseSeed) % 1.0;

      // Trail of 5 dots
      const trailLen = 5;
      for (int i = 0; i < trailLen; i++) {
        final tt = (t - i * 0.025).clamp(0.0, 1.0);
        if (tt < 0) continue;
        final pos = _bezier(a, c, b, tt);
        final fade = 1.0 - i / trailLen;
        final col = hues[s.from % hues.length];
        final paint = Paint()
          ..color = col.withValues(alpha: fade * (isLight ? 0.7 : 0.95))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.6 * fade);
        canvas.drawCircle(pos, 2.2 * fade + 0.6, paint);
      }
    }
  }

  void _paintNeurons(Canvas canvas, Size size) {
    for (final n in neurons) {
      final pos = _neuronPos(n, size);
      final pulse = 0.7 + 0.3 * math.sin(progress * math.pi * 4 + n.pulsePhase);
      final color = hues[n.hue % hues.length];

      // Outer aura
      final aura = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: (isLight ? 0.25 : 0.4) * pulse),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: pos, radius: n.baseRadius * 5),
        );
      canvas.drawCircle(pos, n.baseRadius * 5, aura);

      // Glow ring
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = color.withValues(alpha: (isLight ? 0.55 : 0.7) * pulse);
      canvas.drawCircle(pos, n.baseRadius * 1.8, ring);

      // Core
      final core = Paint()
        ..color = color.withValues(alpha: isLight ? 0.85 : 1.0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawCircle(pos, n.baseRadius * 0.85 * pulse, core);

      // Inner bright dot
      final dot = Paint()..color = Colors.white.withValues(alpha: 0.9);
      canvas.drawCircle(pos, n.baseRadius * 0.35, dot);
    }
  }

  void _paintEeg(Canvas canvas, Size size) {
    final baseY = size.height * 0.92;
    final amp = 14.0 + (velocity / 6.0).clamp(0.0, 18.0);
    final color = (isLight ? AppColors.inkGreen : AppColors.neonGreen)
        .withValues(alpha: isLight ? 0.6 : 0.75);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = color;

    final path = Path();
    const samples = 120;
    for (int i = 0; i <= samples; i++) {
      final x = i / samples * size.width;
      final t = i / samples * math.pi * 8 + progress * math.pi * 6;
      // EEG-like spike pattern: combine sines + occasional spike
      double y = math.sin(t) * 0.4 + math.sin(t * 2.3) * 0.25;
      // Spike every ~25 samples
      final spikeCenter = ((progress * samples * 0.6) % 25).abs();
      final di = (i % 25 - spikeCenter).abs();
      if (di < 3) {
        y += math.exp(-di * di * 0.5) * (1.5 + math.sin(progress * 30) * 0.3);
      }
      final py = baseY - y * amp;
      if (i == 0) {
        path.moveTo(x, py);
      } else {
        path.lineTo(x, py);
      }
    }
    canvas.drawPath(path, paint);

    // Glow under
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = color.withValues(alpha: color.a * 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, glow);
  }

  @override
  bool shouldRepaint(covariant _NeuralPainter old) => true;
}
