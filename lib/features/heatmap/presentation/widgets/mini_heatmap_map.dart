import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap_canvas.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap_compass.dart';

/// A compact, premium version of the heatmap map for AR HUD display.
class MiniHeatmapMap extends StatefulWidget {
  final HeatmapSession session;
  final Offset? currentPosition;
  final double? currentHeading;
  final VoidCallback? onTap;

  const MiniHeatmapMap({
    required this.session,
    this.currentPosition,
    this.currentHeading,
    this.onTap,
    super.key,
  });

  @override
  State<MiniHeatmapMap> createState() => _MiniHeatmapMapState();
}

class _MiniHeatmapMapState extends State<MiniHeatmapMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final pulseVal = _pulseAnimation.value;
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00E676).withValues(
                  alpha: 0.2 + (pulseVal * 0.4),
                ),
                width: 1.5 + (pulseVal * 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E676).withValues(
                    alpha: 0.15 * pulseVal,
                  ),
                  blurRadius: 10 + (pulseVal * 8),
                  spreadRadius: pulseVal * 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // The actual heatmap canvas, non-interactive in mini mode
                AbsorbPointer(
                  child: HeatmapCanvas(
                    session: widget.session,
                    floorPlan: widget.session.floorPlan,
                    showPath: true,
                    showControls: false,
                    isMiniMap: true,
                    currentPosition: widget.currentPosition,
                    currentHeading: widget.currentHeading,
                  ),
                ),

                // Vignette overlay for a premium look
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.35),
                        ],
                        stops: const [0.55, 1.0],
                      ),
                    ),
                  ),
                ),

                // Compass indicator (top-right): forward the already-resolved heading
                // from the parent BlocSelector so both widgets update in lockstep.
                Positioned(
                  top: 8,
                  right: 8,
                  child: HeatmapCompass(size: 42, heading: widget.currentHeading),
                ),

                // Animated LIVE badge (top-left)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Opacity(
                          opacity: pulseVal,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E676)
                                      .withValues(alpha: 0.6),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'LIVE',
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
