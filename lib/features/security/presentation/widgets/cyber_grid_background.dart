import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:torcav/core/theme/app_theme.dart';

class CyberGridBackground extends StatefulWidget {
  final Color color;
  final Widget? child;

  const CyberGridBackground({
    super.key,
    required this.color,
    this.child,
  });

  /// Static method to update scroll velocity globally
  static void updateScrollVelocity(double velocity) {
    _CyberGridBackgroundState.scrollVelocity.value = velocity.abs();
  }

  @override
  State<CyberGridBackground> createState() => _CyberGridBackgroundState();
}

class _CyberGridBackgroundState extends State<CyberGridBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static final ValueNotifier<double> scrollVelocity = ValueNotifier<double>(0.0);
  
  ui.FragmentShader? _shader;
  bool _shaderLoaded = false;
  
  double _smoothedVelocity = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40), // Balanced relaxing cycle
    )..repeat();

    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset('shaders/cyber_post.frag');
      if (mounted) {
        setState(() {
          _shader = program.fragmentShader();
          _shaderLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading shader: $e');
      // If shader fails, we stay in non-shader mode (fallback handled in build)
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
    final baseColor = isLight ? AppColors.lightBg : AppColors.deepBlack;

    return Stack(
      children: [
        // Base Layer
        Positioned.fill(
          child: Container(color: baseColor),
        ),

        // GPU-Accelerated Neomorphic Layer
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: Listenable.merge([_controller, scrollVelocity]),
              builder: (context, child) {
                // Smooth out the velocity for the shader
                _smoothedVelocity = _smoothedVelocity * 0.9 + (scrollVelocity.value / 20.0).clamp(0.0, 1.0) * 0.1;
                scrollVelocity.value *= 0.95; // Natural decay

                if (_shaderLoaded && _shader != null) {
                  return CustomPaint(
                    painter: _ShaderPainter(
                      shader: _shader!,
                      time: _controller.value * 100.0, // Large t value for noise/waves
                      velocity: _smoothedVelocity,
                      isLight: isLight,
                    ),
                  );
                }

                // Fallback: Simple static grid or empty (prevent laggy CPU version)
                return const SizedBox.shrink();
              },
            ),
          ),
        ),

        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final double velocity;
  final bool isLight;

  _ShaderPainter({
    required this.shader,
    required this.time,
    required this.velocity,
    required this.isLight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, velocity)
      ..setFloat(4, isLight ? 1.0 : 0.0);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _ShaderPainter oldDelegate) {
    return oldDelegate.time != time || 
           oldDelegate.velocity != velocity || 
           oldDelegate.isLight != isLight;
  }
}
