import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/services/signal_tier.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';
import 'ar_models.dart';

/// Screen-space dBm label overlay for AR view.
///
/// Projects floor markers from metric world space into Flutter screen space.
class SignalLabelOverlay extends StatelessWidget {
  const SignalLabelOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, LabelOverlaySlice>(
      selector: (s) {
        final points =
            s.isViewingInAr
                ? (s.selectedSession?.points ?? const [])
                : (s.currentSession?.points ?? const []);
        return LabelOverlaySlice(
          points: points,
          camX: s.currentPosition?.dx ?? 0,
          camY: s.currentPosition?.dy ?? 0,
          heading: s.currentHeading,
          headingOffset: s.arOriginHeadingOffset,
          hasOrigin: s.hasArOrigin,
        );
      },
      builder: (context, slice) {
        if (!slice.hasOrigin || slice.points.isEmpty) {
          return const SizedBox.shrink();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final labels = <Widget>[];

            // Only render the last 80 points to match the 3D disc cap and prevent jank.
            final pointsToRender =
                slice.points.length > 80
                    ? slice.points.sublist(slice.points.length - 80)
                    : slice.points;

            for (final point in pointsToRender) {
              final result = _projectToScreen(
                point,
                slice.camX,
                slice.camY,
                slice.heading - slice.headingOffset,
                size,
              );
              if (result == null) continue;

              final screen = result.offset;
              final depth = result.depth;
              final depthFactor = (1.5 / depth).clamp(0.5, 1.8);
              final color = signalGradientColor(point.rssi);

              // Step B: Vertical projection.
              // Approximate mobile vFOV (~55-60 deg).
              const vFovRad = 55.0 * math.pi / 180.0;
              final focalPxY = size.height / (2 * math.tan(vFovRad / 2));
              // The disc is on the floor (~1m below camera).
              const cameraHeight = 1.0;
              final discScreenY =
                  size.height / 2 + (cameraHeight / depth) * focalPxY;
              final labelScreenY = discScreenY - 32 * depthFactor;

              labels.add(
                Positioned(
                  left: screen.dx,
                  top: labelScreenY,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -1.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DbmPill(
                          rssi: point.rssi,
                          color: color,
                          depthFactor: depthFactor,
                          bssid: point.bssid,
                        ),
                        CustomPaint(
                          size: Size(2, discScreenY - labelScreenY),
                          painter: _VerticalStemPainter(color: color),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Stack(children: labels);
          },
        );
      },
    );
  }

  /// Projects a floor-space point onto screen coordinates.
  /// Returns null if the point is behind the camera or out of bounds.
  ProjectionResult? _projectToScreen(
    HeatmapPoint point,
    double camX,
    double camY,
    double headingDeg,
    Size screenSize,
  ) {
    final dx = point.floorX - camX;
    final dy = point.floorY - camY;
    final headingRad = headingDeg * math.pi / 180;

    // Depth: how far the point is in front of the camera.
    final depth = dx * math.cos(headingRad) + dy * math.sin(headingRad);
    // Lateral: how far the point is to the right of the camera.
    final lateral = -dx * math.sin(headingRad) + dy * math.cos(headingRad);

    if (depth < 0.4 || depth > 7.0) return null;

    const hFovRad = 60.0 * math.pi / 180.0;
    final focalPx = screenSize.width / (2 * math.tan(hFovRad / 2));

    final screenX = screenSize.width / 2 + (lateral / depth) * focalPx;
    if (screenX < -60 || screenX > screenSize.width + 60) return null;

    return ProjectionResult(Offset(screenX, 0), depth);
  }
}

class _VerticalStemPainter extends CustomPainter {
  const _VerticalStemPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    // Tiny dot at the base for visual grounding.
    canvas.drawCircle(
      Offset(size.width / 2, size.height),
      1.5,
      paint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DbmPill extends StatelessWidget {
  const _DbmPill({
    required this.rssi,
    required this.color,
    required this.depthFactor,
    required this.bssid,
  });

  final int rssi;
  final Color color;
  final double depthFactor;
  final String bssid;

  @override
  Widget build(BuildContext context) {
    final scale = depthFactor;
    final bssidSuffix =
        bssid.length > 5 ? bssid.substring(bssid.length - 5) : '';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(
          color: color.withValues(alpha: 0.6),
          width: 1.5 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 8 * scale,
            spreadRadius: 1 * scale,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.waves_rounded, color: color, size: 10 * scale),
              SizedBox(width: 4 * scale),
              Text(
                '$rssi dBm',
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5 * scale,
                ),
              ),
            ],
          ),
          if (bssidSuffix.isNotEmpty) ...[
            SizedBox(height: 2 * scale),
            Text(
              bssidSuffix.toUpperCase(),
              style: GoogleFonts.orbitron(
                color: color.withValues(alpha: 0.6),
                fontSize: 7 * scale,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2 * scale,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
