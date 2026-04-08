import 'dart:math' as math;
import 'package:flutter/material.dart';

class CyberGridBackground extends StatefulWidget {
  final Color color;
  final Widget? child;

  const CyberGridBackground({
    super.key,
    required this.color,
    this.child,
  });

  @override
  State<CyberGridBackground> createState() => _CyberGridBackgroundState();
}

class _CyberGridBackgroundState extends State<CyberGridBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = List.generate(15, (_) => _Particle());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // Slow rotation/movement
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _GridPainter(
                    progress: _controller.value,
                    color: widget.color.withValues(alpha: 0.08),
                    particles: _particles,
                  ),
                );
              },
            ),
          ),
        ),
        // Add a subtle radial vignette for depth - Breathing effect
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final pulse = (math.sin(_controller.value * 2 * math.pi) + 1) / 2;
              final opacity = 0.3 + (pulse * 0.2);
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: opacity),
                    ],
                    stops: const [0.2, 1.0],
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _Particle {
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double speed = 0.0005 + (math.Random().nextDouble() * 0.001);
  double size = 1 + (math.Random().nextDouble() * 2);
  double opacity = 0.1 + (math.Random().nextDouble() * 0.3);

  void update() {
    y -= speed;
    if (y < -0.1) {
      y = 1.1;
      x = math.Random().nextDouble();
    }
  }
}

class _GridPainter extends CustomPainter {
  final double progress;
  final Color color;
  final List<_Particle> particles;

  _GridPainter({
    required this.progress,
    required this.color,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    final dotPaint = Paint()
      ..color = color.withValues(alpha: color.a * 2)
      ..style = PaintingStyle.fill;

    const gridSize = 40.0;
    final offsetX = (progress * gridSize) % gridSize;
    final offsetY = (progress * gridSize) % gridSize;

    // Vertical lines
    for (double x = -gridSize; x < size.width + gridSize; x += gridSize) {
      final currentX = x + offsetX;
      canvas.drawLine(
        Offset(currentX, 0),
        Offset(currentX, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = -gridSize; y < size.height + gridSize; y += gridSize) {
      final currentY = y + offsetY;
      canvas.drawLine(
        Offset(0, currentY),
        Offset(size.width, currentY),
        paint,
      );
    }

    // ── Scanning Line (VIP effect) ──
    final scanLineY = (progress * 2 * size.height) % size.height;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0),
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, scanLineY - 50, size.width, 100));
    
    canvas.drawRect(Rect.fromLTWH(0, scanLineY - 1, size.width, 2), scanPaint);

    // ── Drifting Particles (Hexagon Bits) ──
    for (final p in particles) {
      p.update();
      final pos = Offset(p.x * size.width, p.y * size.height);
      final pPaint = Paint()
        ..color = color.withValues(alpha: p.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
      
      canvas.drawRect(
        Rect.fromCenter(center: pos, width: p.size, height: p.size),
        pPaint,
      );
    }

    // ── Subtle Intersections ──
    final random = math.Random(42);
    for (int i = 0; i < 8; i++) {
      final gx = (random.nextDouble() * size.width / gridSize).floor() * gridSize + offsetX;
      final gy = (random.nextDouble() * size.height / gridSize).floor() * gridSize + offsetY;
      
      final pulse = (math.sin(progress * 4 * math.pi + i) + 1) / 2;
      if (pulse > 0.7) {
        canvas.drawCircle(
          Offset(gx, gy), 
          1.5, 
          dotPaint..color = color.withValues(alpha: (pulse - 0.7) * 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => true;
}

