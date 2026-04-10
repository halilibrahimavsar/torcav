import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../domain/entities/floor_plan.dart';
import '../../domain/entities/heatmap_point.dart';
import '../../domain/entities/heatmap_session.dart';
import '../../domain/entities/wall_segment.dart';

/// Renders signal-strength data and floor plan walls.
class HeatmapCanvas extends StatelessWidget {
  const HeatmapCanvas({
    required this.session,
    this.floorPlan,
    this.onTap,
    this.showPath = false,
    this.activeFloor,
    this.currentPosition,
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

  /// Current live metric position in meters from the session origin.
  final Offset? currentPosition;

  @override
  Widget build(BuildContext context) {
    final points =
        activeFloor == null
            ? session.points
            : session.points.where((p) => p.floor == activeFloor).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final worldBounds = _WorldBounds.fromData(
          points: points,
          walls: floorPlan?.walls ?? const [],
          currentPosition: currentPosition,
        );
        final viewport = _Viewport.fit(size, worldBounds);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown:
              onTap == null
                  ? null
                  : (details) =>
                      onTap!(viewport.canvasToWorld(details.localPosition)),
          child: CustomPaint(
            painter: _HeatmapPainter(
              points: points,
              floorPlan: floorPlan,
              viewport: viewport,
              showPath: showPath,
              currentPosition: currentPosition,
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
    required this.points,
    required this.floorPlan,
    required this.viewport,
    required this.showPath,
    required this.currentPosition,
  });

  final List<HeatmapPoint> points;
  final FloorPlan? floorPlan;
  final _Viewport viewport;
  final bool showPath;
  final Offset? currentPosition;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas);

    if (floorPlan != null && floorPlan!.walls.isNotEmpty) {
      _drawWalls(canvas, floorPlan!.walls);
    }

    if (showPath) {
      _drawPath(canvas, points);
    }

    if (points.isNotEmpty) {
      _drawHeatmap(canvas, points);
    }

    if (points.any((point) => point.isFlagged)) {
      _drawFlags(canvas, points.where((point) => point.isFlagged).toList());
    }

    if (currentPosition != null) {
      _drawCurrentPosition(canvas, currentPosition!);
    }
  }

  void _drawHeatmap(Canvas canvas, List<HeatmapPoint> points) {
    final radius = (viewport.scale * 1.4).clamp(22.0, 64.0);

    for (final point in points) {
      final centre = viewport.worldToCanvas(Offset(point.floorX, point.floorY));
      final signalColor = _signalColor(point.rssi);

      final paint =
          Paint()
            ..shader = ui.Gradient.radial(
              centre,
              radius,
              [
                signalColor.withValues(alpha: 0.66),
                signalColor.withValues(alpha: 0.14),
                signalColor.withValues(alpha: 0),
              ],
              const [0, 0.55, 1],
            );
      canvas.drawCircle(centre, radius, paint);

      canvas.drawCircle(
        centre,
        3.2,
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
    }
  }

  void _drawPath(Canvas canvas, List<HeatmapPoint> points) {
    if (points.length < 2) return;

    final pathPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.28)
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(
      viewport
          .worldToCanvas(Offset(points.first.floorX, points.first.floorY))
          .dx,
      viewport
          .worldToCanvas(Offset(points.first.floorX, points.first.floorY))
          .dy,
    );
    for (int i = 1; i < points.length; i++) {
      final canvasPoint = viewport.worldToCanvas(
        Offset(points[i].floorX, points[i].floorY),
      );
      path.lineTo(canvasPoint.dx, canvasPoint.dy);
    }
    canvas.drawPath(path, pathPaint);

    final first = viewport.worldToCanvas(
      Offset(points.first.floorX, points.first.floorY),
    );
    canvas.drawCircle(
      first,
      5.0,
      Paint()..color = const Color(0xFF39FF14).withValues(alpha: 0.9),
    );

    final last = viewport.worldToCanvas(
      Offset(points.last.floorX, points.last.floorY),
    );
    canvas.drawCircle(
      last,
      6.5,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  void _drawWalls(Canvas canvas, List<WallSegment> walls) {
    final wallPaint =
        Paint()
          ..color = Colors.cyanAccent.withValues(alpha: 0.82)
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6);

    for (final wall in walls) {
      canvas.drawLine(
        viewport.worldToCanvas(Offset(wall.x1, wall.y1)),
        viewport.worldToCanvas(Offset(wall.x2, wall.y2)),
        wallPaint,
      );
    }
  }

  void _drawCurrentPosition(Canvas canvas, Offset currentPosition) {
    final center = viewport.worldToCanvas(currentPosition);
    canvas.drawCircle(
      center,
      7.0,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    canvas.drawCircle(
      center,
      2.5,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
  }

  void _drawFlags(Canvas canvas, List<HeatmapPoint> points) {
    final fill =
        Paint()
          ..color = const Color(0xFFFF5F57)
          ..style = PaintingStyle.fill;
    final stroke =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.92)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;

    for (final point in points) {
      final center = viewport.worldToCanvas(Offset(point.floorX, point.floorY));
      canvas.drawCircle(
        center,
        10,
        Paint()
          ..color = const Color(0xFFFF5F57).withValues(alpha: 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      final path =
          Path()
            ..moveTo(center.dx, center.dy - 9)
            ..lineTo(center.dx + 7, center.dy + 3)
            ..lineTo(center.dx, center.dy + 11)
            ..lineTo(center.dx - 7, center.dy + 3)
            ..close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    }
  }

  void _drawGrid(Canvas canvas) {
    final gridPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..strokeWidth = 0.7;

    final accentPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.08)
          ..strokeWidth = 1.0;

    final stepMeters = _gridStepMeters(viewport.scale);
    final startX = (viewport.bounds.minX / stepMeters).floor() * stepMeters;
    final endX = (viewport.bounds.maxX / stepMeters).ceil() * stepMeters;
    final startY = (viewport.bounds.minY / stepMeters).floor() * stepMeters;
    final endY = (viewport.bounds.maxY / stepMeters).ceil() * stepMeters;

    for (double x = startX; x <= endX; x += stepMeters) {
      final canvasX =
          viewport.worldToCanvas(Offset(x, viewport.bounds.minY)).dx;
      canvas.drawLine(
        Offset(canvasX, viewport.topInset),
        Offset(canvasX, viewport.bottomInset),
        x.abs() < 0.001 ? accentPaint : gridPaint,
      );
    }
    for (double y = startY; y <= endY; y += stepMeters) {
      final canvasY =
          viewport.worldToCanvas(Offset(viewport.bounds.minX, y)).dy;
      canvas.drawLine(
        Offset(viewport.leftInset, canvasY),
        Offset(viewport.rightInset, canvasY),
        y.abs() < 0.001 ? accentPaint : gridPaint,
      );
    }
  }

  double _gridStepMeters(double scale) {
    if (scale > 110) return 1;
    if (scale > 55) return 2;
    return 5;
  }

  Color _signalColor(int rssi) {
    final normalized = ((rssi + 90) / 55).clamp(0.0, 1.0);
    const stops = [
      Color(0xFFFF3B30),
      Color(0xFFFF9F0A),
      Color(0xFFFFD60A),
      Color(0xFF7DFF60),
      Color(0xFF00E676),
    ];
    final scaled = normalized * (stops.length - 1);
    final index = scaled.floor().clamp(0, stops.length - 2);
    final fraction = scaled - index;
    return Color.lerp(stops[index], stops[index + 1], fraction)!;
  }

  @override
  bool shouldRepaint(_HeatmapPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.floorPlan != floorPlan ||
      oldDelegate.viewport != viewport ||
      oldDelegate.showPath != showPath ||
      oldDelegate.currentPosition != currentPosition;
}

class _Viewport {
  const _Viewport({
    required this.bounds,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
    required this.size,
  });

  factory _Viewport.fit(Size size, _WorldBounds bounds) {
    const outerPadding = 18.0;
    final usableWidth = math.max(1.0, size.width - (outerPadding * 2));
    final usableHeight = math.max(1.0, size.height - (outerPadding * 2));
    final scale = math.min(
      usableWidth / bounds.width,
      usableHeight / bounds.height,
    );
    final contentWidth = bounds.width * scale;
    final contentHeight = bounds.height * scale;
    final offsetX = (size.width - contentWidth) / 2;
    final offsetY = (size.height - contentHeight) / 2;

    return _Viewport(
      bounds: bounds,
      scale: scale,
      offsetX: offsetX,
      offsetY: offsetY,
      size: size,
    );
  }

  final _WorldBounds bounds;
  final double scale;
  final double offsetX;
  final double offsetY;
  final Size size;

  double get leftInset => offsetX;
  double get topInset => offsetY;
  double get rightInset => size.width - offsetX;
  double get bottomInset => size.height - offsetY;

  Offset worldToCanvas(Offset world) => Offset(
    offsetX + ((world.dx - bounds.minX) * scale),
    offsetY + ((world.dy - bounds.minY) * scale),
  );

  Offset canvasToWorld(Offset canvasPoint) => Offset(
    ((canvasPoint.dx - offsetX) / scale) + bounds.minX,
    ((canvasPoint.dy - offsetY) / scale) + bounds.minY,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _Viewport &&
        other.bounds == bounds &&
        other.scale == scale &&
        other.offsetX == offsetX &&
        other.offsetY == offsetY &&
        other.size == size;
  }

  @override
  int get hashCode => Object.hash(bounds, scale, offsetX, offsetY, size);
}

class _WorldBounds {
  const _WorldBounds({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  factory _WorldBounds.fromData({
    required List<HeatmapPoint> points,
    required List<WallSegment> walls,
    required Offset? currentPosition,
  }) {
    final xs = <double>[0];
    final ys = <double>[0];

    for (final point in points) {
      xs.add(point.floorX);
      ys.add(point.floorY);
    }
    for (final wall in walls) {
      xs
        ..add(wall.x1)
        ..add(wall.x2);
      ys
        ..add(wall.y1)
        ..add(wall.y2);
    }
    if (currentPosition != null) {
      xs.add(currentPosition.dx);
      ys.add(currentPosition.dy);
    }

    var minX = xs.reduce(math.min);
    var maxX = xs.reduce(math.max);
    var minY = ys.reduce(math.min);
    var maxY = ys.reduce(math.max);

    if ((maxX - minX).abs() < 2) {
      final center = (minX + maxX) / 2;
      minX = center - 1.5;
      maxX = center + 1.5;
    }
    if ((maxY - minY).abs() < 2) {
      final center = (minY + maxY) / 2;
      minY = center - 1.5;
      maxY = center + 1.5;
    }

    final padding = math.max(maxX - minX, maxY - minY) * 0.12 + 0.75;

    return _WorldBounds(
      minX: minX - padding,
      maxX: maxX + padding,
      minY: minY - padding,
      maxY: maxY + padding,
    );
  }

  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  double get width => math.max(1.0, maxX - minX);
  double get height => math.max(1.0, maxY - minY);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _WorldBounds &&
        other.minX == minX &&
        other.maxX == maxX &&
        other.minY == minY &&
        other.maxY == maxY;
  }

  @override
  int get hashCode => Object.hash(minX, maxX, minY, maxY);
}
