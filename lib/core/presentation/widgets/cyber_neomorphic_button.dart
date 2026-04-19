import 'package:flutter/material.dart';
import 'package:torcav/core/theme/app_theme.dart';

/// A professional neomorphic button with high-fidelity "pressed" state.
///
/// Uses separate animation controllers for organic breathing and tactile pressing,
/// featuring a CustomPainter for true 3D inner shadows.
class CyberNeomorphicButton extends StatefulWidget {
  const CyberNeomorphicButton({
    required this.onPressed,
    required this.child,
    this.onLongPress,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderRadius = 16.0,
    this.useBreathing = true,
    super.key,
  });

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool useBreathing;

  @override
  State<CyberNeomorphicButton> createState() => _CyberNeomorphicButtonState();
}

class _CyberNeomorphicButtonState extends State<CyberNeomorphicButton>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _pressController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Rhythmic Breathing Logic
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), // Sync with shader period
    );

    _breathingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutSine,
      ),
    );

    if (widget.useBreathing) {
      _breathingController.repeat(reverse: true);
    }

    // 2. Tactile Press Logic
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _pressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _pressController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _pressController.reverse();
    }
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Neomorphic shadow palette constants
    final double baseHighlightAlpha = isDark ? 0.05 : 0.8; // Subtler highlights
    final double baseShadowAlpha = isDark ? 0.7 : 0.45; // Balanced depth

    final Color highlightColor = isDark ? AppColors.neonCyan : Colors.white;
    final Color shadowColor = isDark ? Colors.black : const Color(0xFFC0CCE0);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathingAnimation, _pressAnimation]),
        builder: (context, child) {
          final double p = _pressAnimation.value;
          final double b =
              widget.useBreathing ? _breathingAnimation.value : 0.0;

          // Realistic physics: breathing is subtle, pressing is significant
          final double breatheOffset = b * 1.5;
          final double scale = (1.0 + (b * 0.003)) - (p * 0.04);

          return Transform.scale(
            scale: scale,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDark
                          ? [AppColors.darkSurfaceLight, AppColors.darkSurface]
                          : [Colors.white, const Color(0xFFF1F5F9)],
                ),
                boxShadow: [
                  // Outer Shadows (fade out as button is pressed)
                  BoxShadow(
                    color: shadowColor.withValues(
                      alpha: baseShadowAlpha * (1.0 - p),
                    ),
                    offset: Offset(6 + breatheOffset, 6 + breatheOffset),
                    blurRadius: 12 + breatheOffset,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: highlightColor.withValues(
                      alpha: baseHighlightAlpha * (1.0 - p),
                    ),
                    offset: Offset(-6 - breatheOffset, -6 - breatheOffset),
                    blurRadius: 12 + breatheOffset,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Stack(
                  children: [
                    // Inner Shadows (fade in as button is pressed)
                    if (p > 0.01)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _InnerShadowPainter(
                            shadowColor: shadowColor.withValues(
                              alpha: baseShadowAlpha * p,
                            ),
                            highlightColor: highlightColor.withValues(
                              alpha: baseHighlightAlpha * p,
                            ),
                            borderRadius: widget.borderRadius,
                            depth: p * 6.0,
                          ),
                        ),
                      ),
                    Padding(
                      padding: widget.padding,
                      child: Center(child: widget.child),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Painter that draws high-fidelity inner shadows to simulate depth.
class _InnerShadowPainter extends CustomPainter {
  _InnerShadowPainter({
    required this.shadowColor,
    required this.highlightColor,
    required this.borderRadius,
    required this.depth,
  });

  final Color shadowColor;
  final Color highlightColor;
  final double borderRadius;
  final double depth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Support layered depth for professional look
    _drawInnerShadow(
      canvas,
      rrect,
      shadowColor,
      Offset(depth, depth),
      depth * 2,
    );
    _drawInnerShadow(
      canvas,
      rrect,
      highlightColor,
      Offset(-depth / 2, -depth / 2),
      depth,
    );
  }

  void _drawInnerShadow(
    Canvas canvas,
    RRect rrect,
    Color color,
    Offset offset,
    double blur,
  ) {
    final shadowPaint =
        Paint()
          ..color = color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    canvas.save();
    canvas.clipRRect(rrect);

    final shadowPath =
        Path()
          ..addRRect(rrect)
          ..addRect(rrect.outerRect.inflate(blur * 2))
          ..fillType = PathFillType.evenOdd;

    canvas.drawPath(shadowPath.shift(offset), shadowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InnerShadowPainter oldDelegate) =>
      oldDelegate.depth != depth || oldDelegate.shadowColor != shadowColor;
}
