import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Ambient "constellation" themed background.
///
/// Layers (back → front):
///   1. Radial gradient base
///   2. Breathing particle mesh — nodes drift slowly, nearby nodes link up
///   3. Soft glow on the brighter (near) nodes
///   4. Vignette
class QuantumMeshBackground extends StatefulWidget {
  final Color color;
  final Widget? child;
  final ValueNotifier<double> scrollVelocity;

  const QuantumMeshBackground({
    super.key,
    required this.color,
    required this.scrollVelocity,
    this.child,
  });

  @override
  State<QuantumMeshBackground> createState() => _QuantumMeshBackgroundState();
}

class _QuantumMeshBackgroundState extends State<QuantumMeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _smoothedVelocity = 0.0;

  late final List<_Node> _nodes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();

    final rng = math.Random(53);
    _nodes = List.generate(42, (_) {
      return _Node(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        depth: rng.nextDouble(),
        driftPhase: rng.nextDouble() * math.pi * 2,
        driftSpeed: 0.5 + rng.nextDouble() * 1.2,
        driftAmp: 0.012 + rng.nextDouble() * 0.03,
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
                center: const Alignment(-0.3, -0.4),
                radius: 1.4,
                colors:
                    isLight
                        ? const [Color(0xFFEBEFF5), Color(0xFFC6D0DD)]
                        : const [Color(0xFF0B0E1A), Color(0xFF030409)],
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
                  painter: _QuantumMeshPainter(
                    progress: _controller.value,
                    velocity: _smoothedVelocity,
                    accent: widget.color,
                    isLight: isLight,
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

class _Node {
  final double x; // base position 0..1
  final double y;
  final double depth; // 0=far, 1=near
  final double driftPhase;
  final double driftSpeed;
  final double driftAmp;
  _Node({
    required this.x,
    required this.y,
    required this.depth,
    required this.driftPhase,
    required this.driftSpeed,
    required this.driftAmp,
  });
}

class _QuantumMeshPainter extends CustomPainter {
  final double progress;
  final double velocity;
  final Color accent;
  final bool isLight;
  final List<_Node> nodes;

  _QuantumMeshPainter({
    required this.progress,
    required this.velocity,
    required this.accent,
    required this.isLight,
    required this.nodes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;
    // Global breathing 0.0 .. 1.0
    final breath = 0.5 + 0.5 * math.sin(t);
    final linkDist = size.shortestSide * 0.22;

    // Resolve animated positions once.
    final positions = <Offset>[];
    for (final n in nodes) {
      final parallax = velocity * (0.04 + n.depth * 0.16) / size.width;
      final dx =
          n.x +
          parallax +
          n.driftAmp * math.sin(t * n.driftSpeed + n.driftPhase);
      final dy =
          n.y +
          n.driftAmp * math.cos(t * n.driftSpeed * 0.8 + n.driftPhase);
      positions.add(
        Offset((dx % 1.0) * size.width, (dy % 1.0) * size.height),
      );
    }

    // Links between nearby nodes.
    final linkBase = isLight ? AppColors.inkCyan : AppColors.neonCyan;
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final a = positions[i];
        final b = positions[j];
        final d = (a - b).distance;
        if (d >= linkDist) continue;
        final closeness = 1.0 - d / linkDist;
        final depthMix = (nodes[i].depth + nodes[j].depth) * 0.5;
        final alpha =
            closeness *
            closeness *
            (0.16 + depthMix * 0.22) *
            (0.6 + 0.4 * breath) *
            (isLight ? 0.7 : 1.0);
        canvas.drawLine(
          a,
          b,
          Paint()
            ..strokeWidth = 0.7
            ..color =
                Color.lerp(linkBase, accent, closeness * 0.6)!.withValues(
                  alpha: alpha,
                ),
        );
      }
    }

    // Nodes.
    for (int i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      final pos = positions[i];
      final localBreath =
          0.5 + 0.5 * math.sin(t * n.driftSpeed + n.driftPhase);
      final r = (0.8 + n.depth * 1.8) * (0.7 + 0.3 * localBreath);
      final coreColor = isLight ? AppColors.inkCyan : AppColors.softWhite;

      if (n.depth > 0.6) {
        canvas.drawCircle(
          pos,
          r * 2.6,
          Paint()
            ..color = accent.withValues(
              alpha: (isLight ? 0.12 : 0.22) * localBreath,
            )
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
      canvas.drawCircle(
        pos,
        r,
        Paint()
          ..color = coreColor.withValues(
            alpha: (0.25 + n.depth * 0.6) * (isLight ? 0.6 : 1.0),
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QuantumMeshPainter old) => true;
}
