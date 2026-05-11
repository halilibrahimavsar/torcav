import 'dart:math' as math;
import 'package:flutter/material.dart';

class StarfieldBackground extends StatefulWidget {
  final Widget? child;
  const StarfieldBackground({super.key, this.child});

  @override
  State<StarfieldBackground> createState() => _StarfieldBackgroundState();
}

class _StarfieldBackgroundState extends State<StarfieldBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Star> _stars = [];
  final int _starCount = 150;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // Initialize stars
    for (int i = 0; i < _starCount; i++) {
      _stars.add(
        Star(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 2 + 0.5,
          velocity: _random.nextDouble() * 0.05 + 0.01,
          opacity: _random.nextDouble() * 0.7 + 0.3,
          layer: _random.nextInt(3), // 0: far, 1: mid, 2: near
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: StarfieldPainter(stars: _stars, progress: _controller.value),
          child: widget.child,
        );
      },
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double velocity;
  final double opacity;
  final int layer;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.velocity,
    required this.opacity,
    required this.layer,
  });
}

class StarfieldPainter extends CustomPainter {
  final List<Star> stars;
  final double progress;

  StarfieldPainter({required this.stars, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    // Draw a subtle nebula background glow
    final nebulaPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF1A0B2E).withValues(alpha: 0.3), // Deep Purple
              Colors.transparent,
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebulaPaint);

    for (final star in stars) {
      // Calculate position based on progress and velocity for parallax
      // Movement is slightly downwards and to the left
      double currentY = (star.y + progress * star.velocity) % 1.0;
      double currentX = (star.x - progress * (star.velocity * 0.5)) % 1.0;

      final x = currentX * size.width;
      final y = currentY * size.height;

      // Twinkle effect
      final twinkle = 0.8 + 0.2 * math.sin(progress * 50 + star.x * 100);
      paint.color = Colors.white.withValues(alpha: star.opacity * twinkle);

      // Distant stars are smaller and dimmer
      final radius = star.size * (1 + star.layer * 0.5);

      canvas.drawCircle(Offset(x, y), radius, paint);

      // Add a tiny glow to near stars
      if (star.layer == 2 && star.opacity > 0.7) {
        final glowPaint =
            Paint()
              ..color = Colors.white.withValues(alpha: 0.2)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(x, y), radius * 2, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StarfieldPainter oldDelegate) => true;
}
