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
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
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
                      Colors.black.withValues(alpha: 0.22),
                    ],
                    stops: const [0.65, 1.0],
                  ),
                ),
              ),
            ),

            // Compass indicator (top-right)
            const Positioned(
              top: 6,
              right: 6,
              child: HeatmapCompass(size: 40),
            ),

            // Animated LIVE badge (top-left)
            Positioned(
              top: 8,
              left: 8,
              child: FadeTransition(
                opacity: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'LIVE',
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
