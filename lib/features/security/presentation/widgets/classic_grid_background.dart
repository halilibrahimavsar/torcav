import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:torcav/core/theme/app_theme.dart';

class ClassicGridBackground extends StatefulWidget {
  final Color color;
  final Widget? child;
  final ValueNotifier<double> scrollVelocity;

  const ClassicGridBackground({
    super.key,
    required this.color,
    required this.scrollVelocity,
    this.child,
  });

  @override
  State<ClassicGridBackground> createState() => _ClassicGridBackgroundState();
}

class _ClassicGridBackgroundState extends State<ClassicGridBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ui.FragmentShader? _shader;
  bool _shaderLoaded = false;
  double _smoothedVelocity = 0.0;

  final List<_Star> _stars = List.generate(40, (_) => _Star());
  final List<_DataPacket> _packets = List.generate(12, (_) => _DataPacket());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/premium_grid.frag',
      );
      if (mounted) {
        setState(() {
          _shader = program.fragmentShader();
          _shaderLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading shader: $e');
    }
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
    final bgColor = isLight ? theme.colorScheme.surfaceContainer : const Color(0xFF010204);

    return Stack(
      children: [
        // Base Layer: Theme-aware background
        Positioned.fill(
          child: Container(color: bgColor),
        ),

        // Animated Background Content (Grid + Particles + Stars)
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: Listenable.merge([_controller, widget.scrollVelocity]),
              builder: (context, child) {
                // Smooth the velocity for visual stability
                _smoothedVelocity = _smoothedVelocity * 0.9 + 
                    (widget.scrollVelocity.value / 2.0).clamp(0.0, 500.0) * 0.1;

                // Decay the source velocity
                widget.scrollVelocity.value *= 0.95;

                final painter = _PremiumGridPainter(
                  progress: _controller.value,
                  velocity: _smoothedVelocity,
                  color: widget.color,
                  packets: _packets,
                  stars: _stars,
                  isLight: isLight,
                );

                final paintWidget = CustomPaint(painter: painter);

                if (_shaderLoaded && _shader != null) {
                  return ShaderMask(
                    shaderCallback: (rect) {
                      _shader!
                        ..setFloat(0, rect.width)
                        ..setFloat(1, rect.height)
                        ..setFloat(2, _controller.value)
                        ..setFloat(3, (widget.scrollVelocity.value / 1000.0).clamp(0.0, 1.0))
                        ..setFloat(4, isLight ? 1.0 : 0.0);
                      return _shader!;
                    },
                    blendMode: isLight ? BlendMode.multiply : BlendMode.srcOver,
                    child: paintWidget,
                  );
                }

                return paintWidget;
              },
            ),
          ),
        ),

        // Foreground occlusion (top/bottom gradients for readability)
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isLight ? theme.colorScheme.surfaceContainer : Colors.black,
                    Colors.transparent,
                    Colors.transparent,
                    (isLight ? theme.colorScheme.surfaceContainer : Colors.black).withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.35, 0.7, 1.0],
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
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double size = 0.5 + math.Random().nextDouble() * 1.5;
  double parallax = 0.1 + math.Random().nextDouble() * 0.4;
  double brightness = 0.2 + math.Random().nextDouble() * 0.8;
}

class _DataPacket {
  double depth = math.Random().nextDouble();
  double laneX = math.Random().nextDouble() * 2 - 1;
  double speed = 0.003 + math.Random().nextDouble() * 0.004;

  void update(double velocity) {
    depth += speed + (velocity / 20000.0);
    if (depth > 1.1) {
      depth = -0.1;
      laneX = math.Random().nextDouble() * 2 - 1;
    }
  }
}

class _PremiumGridPainter extends CustomPainter {
  final double progress;
  final double velocity;
  final Color color;
  final List<_DataPacket> packets;
  final List<_Star> stars;
  final bool isLight;

  _PremiumGridPainter({
    required this.progress,
    required this.velocity,
    required this.color,
    required this.packets,
    required this.stars,
    required this.isLight,
  });

  void _drawSplitLine(Canvas canvas, Offset p1, Offset p2, Paint basePaint, double aberration) {
    if (aberration > 0.1) {
      final cyanPaint = Paint()
        ..color = const Color(0xFF00F5FF).withValues(alpha: basePaint.color.a * 0.6)
        ..strokeWidth = basePaint.strokeWidth;
      final magentaPaint = Paint()
        ..color = const Color(0xFFFF00FF).withValues(alpha: basePaint.color.a * 0.6)
        ..strokeWidth = basePaint.strokeWidth;

      canvas.drawLine(p1 + Offset(-aberration, 0), p2 + Offset(-aberration, 0), cyanPaint);
      canvas.drawLine(p1 + Offset(aberration, 0), p2 + Offset(aberration, 0), magentaPaint);
    }
    canvas.drawLine(p1, p2, basePaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.35;
    final vanishingPoint = Offset(size.width / 2, horizonY);
    final aberration = (velocity / 25.0).clamp(0.0, 5.0);

    // Starfield
    final starPaint = Paint();
    for (final star in stars) {
      final x = (star.x * size.width + (velocity * star.parallax * 0.1)) % size.width;
      final y = star.y * size.height * 0.45;

      final flicker = 0.8 + 0.2 * math.sin(progress * 25 + star.x * 100);
      starPaint.color = (isLight ? color : AppColors.softWhite).withValues(alpha: star.brightness * flicker * (isLight ? 0.3 : 0.4));

      canvas.drawCircle(Offset(x, y), star.size, starPaint);
    }

    // Grid
    final baseOpacity = isLight ? (0.3 + (velocity / 400)).clamp(0.0, 0.6) : (0.15 + (velocity / 600)).clamp(0.0, 0.4);
    final gridColor = color.withValues(alpha: baseOpacity);
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    // Horizontal Lines (Perspective)
    const int hLineCount = 20;
    final movingOffset = (progress * 4 + velocity * 0.05) % 1.0;

    for (int i = 0; i < hLineCount; i++) {
      final lineProgress = (i + movingOffset) / hLineCount;
      final y = horizonY + math.pow(lineProgress, 3.2) * (size.height - horizonY);

      final opacity = math.pow(lineProgress, 2.0).toDouble();
      gridPaint.color = gridColor.withValues(alpha: gridColor.a * opacity);

      _drawSplitLine(canvas, Offset(0, y), Offset(size.width, y), gridPaint, aberration);
    }

    // Vertical Lines (Vanishing Points)
    const int vLineCount = 14;
    for (int i = 0; i <= vLineCount; i++) {
      final xOffset = (i / vLineCount) * 2 - 1;
      final bottomX = (size.width / 2) + (xOffset * size.width * 2.8);

      gridPaint.color = gridColor.withValues(alpha: gridColor.a * 0.3);
      _drawSplitLine(canvas, vanishingPoint, Offset(bottomX, size.height), gridPaint, aberration * 0.5);
    }

    // Neural Data Packets
    final packetPaint = Paint()..style = PaintingStyle.fill;
    final trailPaint = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    for (final packet in packets) {
      packet.update(velocity);
      if (packet.depth < 0) continue;

      final depthCalc = math.pow(packet.depth, 3.2);
      final y = horizonY + depthCalc * (size.height - horizonY);

      final xSpread = (packet.laneX * size.width * 2.8) * packet.depth;
      final x = (size.width / 2) + xSpread;

      final pSize = 1.5 + (packet.depth * 7.0);
      final pOpacity = (packet.depth * 2.0).clamp(0.0, 1.0);

      final trailLen = (12.0 + velocity * 0.15) * packet.depth;

      trailPaint.color = color.withValues(alpha: pOpacity * 0.4);
      trailPaint.strokeWidth = pSize / 2;
      canvas.drawLine(Offset(x, y), Offset(x, y - trailLen), trailPaint);

      packetPaint.color = color.withValues(alpha: pOpacity);
      packetPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, pSize * 0.3);
      canvas.drawCircle(Offset(x, y), pSize / 2, packetPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumGridPainter oldDelegate) => true;
}
