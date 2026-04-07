import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../domain/entities/floor_plan.dart';
import '../../domain/entities/heatmap_point.dart';
import '../../domain/entities/heatmap_session.dart';

/// Renders signal-strength data and floor plan walls.
class HeatmapCanvas extends StatelessWidget {
  const HeatmapCanvas({
    required this.session,
    this.floorPlan,
    this.onTap,
    this.showPath = false,
    this.activeFloor,
    super.key,
  });

  final HeatmapSession session;
  final FloorPlan? floorPlan;

  /// Called with the metric [Offset] (meters) when the user taps.
  final void Function(Offset metricPos)? onTap;

  /// Whether to draw the walking path overlay.
  final bool showPath;

  /// When set, only points on this floor are rendered (barometer-based).
  final int? activeFloor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final maxMetersX = floorPlan?.widthMeters ?? 20.0;
        final maxMetersY = floorPlan?.heightMeters ?? 20.0;

        final scaleX = size.width / maxMetersX;
        final scaleY = size.height / maxMetersY;
        final scale = math.min(scaleX, scaleY);

        return GestureDetector(
          onTapDown: onTap == null
              ? null
              : (d) {
                  final local = d.localPosition;
                  onTap!(Offset(local.dx / scale, local.dy / scale));
                },
          child: CustomPaint(
            painter: _HeatmapPainter(
              session: session,
              floorPlan: floorPlan,
              scale: scale,
              showPath: showPath,
              activeFloor: activeFloor,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.session,
    this.floorPlan,
    required this.scale,
    this.showPath = false,
    this.activeFloor,
  });

  final HeatmapSession session;
  final FloorPlan? floorPlan;
  final double scale;
  final bool showPath;
  final int? activeFloor;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    if (floorPlan != null) {
      _drawWalls(canvas);
    }

    final points = activeFloor == null
        ? session.points
        : session.points.where((p) => p.floor == activeFloor).toList();

    if (showPath) _drawPath(canvas, points);

    if (points.isEmpty) return;

    final minRssi = points.map((p) => p.rssi).reduce((a, b) => a < b ? a : b);
    final maxRssi = points.map((p) => p.rssi).reduce((a, b) => a > b ? a : b);
    final rssiRange = math.max(1, maxRssi - minRssi);

    for (final point in points) {
      final t = ((point.rssi - minRssi) / rssiRange).clamp(0.0, 1.0);

      final centre = Offset(point.floorX * scale, point.floorY * scale);
      final radius = 2.5 * scale;

      final paint = Paint()
        ..shader = ui.Gradient.radial(
          centre,
          radius,
          [
            _signalColour(t).withValues(alpha: 0.6),
            _signalColour(t).withValues(alpha: 0.0),
          ],
        );
      canvas.drawCircle(centre, radius, paint);

      canvas.drawCircle(
        centre,
        3,
        Paint()..color = Colors.white.withValues(alpha: 0.8),
      );
    }
  }

  void _drawPath(Canvas canvas, List<HeatmapPoint> points) {
    if (points.length < 2) return;

    final pathPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final first = points.first;
    path.moveTo(first.floorX * scale, first.floorY * scale);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].floorX * scale, points[i].floorY * scale);
    }
    canvas.drawPath(path, pathPaint);

    // Start marker — green filled circle.
    canvas.drawCircle(
      Offset(first.floorX * scale, first.floorY * scale),
      5.0,
      Paint()..color = Colors.green.withValues(alpha: 0.85),
    );

    // Current position marker — white outline circle.
    final last = points.last;
    canvas.drawCircle(
      Offset(last.floorX * scale, last.floorY * scale),
      6.0,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  void _drawWalls(Canvas canvas) {
    final wallPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.8)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    for (final wall in floorPlan!.walls) {
      canvas.drawLine(
        Offset(wall.x1 * scale, wall.y1 * scale),
        Offset(wall.x2 * scale, wall.y2 * scale),
        wallPaint,
      );
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;
    
    // Grid every 5 meters
    final step = 5.0 * scale;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  Color _signalColour(double t) {
    const stops = [
      Color(0xFF0033FF), // deep blue
      Color(0xFF00CCFF), // cyan
      Color(0xFF00FF99), // mint
      Color(0xFFFFFF00), // yellow
      Color(0xFFFF3300), // red-orange
    ];
    final scaled = t * (stops.length - 1);
    final idx = scaled.floor().clamp(0, stops.length - 2);
    final frac = scaled - idx;
    return Color.lerp(stops[idx], stops[idx + 1], frac)!;
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) =>
      old.session != session ||
      old.floorPlan != floorPlan ||
      old.scale != scale ||
      old.showPath != showPath ||
      old.activeFloor != activeFloor;
}
