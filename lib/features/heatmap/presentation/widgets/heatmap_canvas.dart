import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../domain/entities/floor_plan.dart';
import '../../domain/entities/heatmap_point.dart';
import '../../domain/entities/heatmap_session.dart';
import '../../domain/entities/wall_segment.dart';

/// Renders signal-strength data and floor plan walls.
class HeatmapCanvas extends StatefulWidget {
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
  final void Function(Offset metricPos)? onTap;
  final bool showPath;
  final int? activeFloor;
  final Offset? currentPosition;

  @override
  State<HeatmapCanvas> createState() => _HeatmapCanvasState();
}

class _HeatmapCanvasState extends State<HeatmapCanvas> {
  late final TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points =
        widget.activeFloor == null
            ? widget.session.points
            : widget.session.points
                .where((p) => p.floor == widget.activeFloor)
                .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final worldBounds = _WorldBounds.fromData(
          points: points,
          walls: widget.floorPlan?.walls ?? const [],
          currentPosition: widget.currentPosition,
        );
        final viewport = _Viewport.fit(size, worldBounds);

        return InteractiveViewer(
          transformationController: _transformationController,
          maxScale: 5.0,
          minScale: 0.5,
          clipBehavior: Clip.none,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown:
                widget.onTap == null
                    ? null
                    : (details) {
                        // FIX: Account for InteractiveViewer transform
                        final RenderBox box =
                            context.findRenderObject() as RenderBox;
                        final Offset localOffset = box.globalToLocal(
                          details.globalPosition,
                        );

                        // The InteractiveViewer scales and translates the child.
                        // We must inverse-transform the tap to find the position
                        // in the original 'fitted' coordinate space.
                        final Matrix4 matrix = _transformationController.value;
                        final Matrix4 inverse = Matrix4.inverted(matrix);
                        final Offset transformed = MatrixUtils.transformPoint(
                          inverse,
                          localOffset,
                        );

                        widget.onTap!(
                          viewport.canvasToWorld(transformed),
                        );
                      },
            child: CustomPaint(
              painter: _HeatmapPainter(
                points: points,
                floorPlan: widget.floorPlan,
                viewport: viewport,
                showPath: widget.showPath,
                currentPosition: widget.currentPosition,
              ),
              child: const SizedBox.expand(),
            ),
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
    if (points.isEmpty) return;

    // Premium Blending: Create an off-screen layer to draw points, then blur them
    // to create a continuous signal field instead of isolated circles.
    final heatmapRadius = (viewport.scale * 1.8).clamp(28.0, 72.0);
    final blurSigma = heatmapRadius * 0.45;

    canvas.saveLayer(
      Rect.fromLTWH(0, 0, viewport.size.width, viewport.size.height),
      Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
    );

    for (final point in points) {
      final centre = viewport.worldToCanvas(Offset(point.floorX, point.floorY));
      final signalColor = _signalColor(point.rssi);

      // We use a stronger inner core and let the layer blur handle the "spread"
      final paint =
          Paint()
            ..shader = ui.Gradient.radial(
              centre,
              heatmapRadius,
              [
                signalColor.withValues(alpha: 0.85),
                signalColor.withValues(alpha: 0.45),
                signalColor.withValues(alpha: 0),
              ],
              const [0, 0.4, 1],
            );
      canvas.drawCircle(centre, heatmapRadius, paint);
    }
    canvas.restore();

    // Draw high-precision point markers on top
    for (final point in points) {
      final centre = viewport.worldToCanvas(Offset(point.floorX, point.floorY));
      canvas.drawCircle(
        centre,
        2.4,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
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
    // Architectural Style: Thick walls with inner glow and glass-like border
    final outerWallPaint =
        Paint()
          ..color = const Color(0xFF00E5FF).withValues(alpha: 0.6)
          ..strokeWidth = 5.0
          ..strokeCap = StrokeCap.round;

    final innerWallPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round;

    final wallGlowPaint =
        Paint()
          ..color = const Color(0xFF00E5FF).withValues(alpha: 0.15)
          ..strokeWidth = 12.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    for (final wall in walls) {
      final p1 = viewport.worldToCanvas(Offset(wall.x1, wall.y1));
      final p2 = viewport.worldToCanvas(Offset(wall.x2, wall.y2));

      // 1. Shadow/Glow
      canvas.drawLine(p1, p2, wallGlowPaint);
      // 2. Thick physical wall
      canvas.drawLine(p1, p2, outerWallPaint);
      // 3. Sharp edge detail
      canvas.drawLine(p1, p2, innerWallPaint);
    }
  }

  void _drawCurrentPosition(Canvas canvas, Offset currentPosition) {
    final center = viewport.worldToCanvas(currentPosition);

    // Premium Scanner Pulse
    final pulsePaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    // Draw three ripples
    canvas.drawCircle(center, 12, pulsePaint);
    canvas.drawCircle(center, 24, pulsePaint..color = pulsePaint.color.withValues(alpha: 0.2));

    // Core Marker
    canvas.drawCircle(
      center,
      8.0,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(
      center,
      3.0,
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0),
    );

    // Crosshair lines
    final crossPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..strokeWidth = 1.0;
    canvas.drawLine(center - const Offset(14, 0), center - const Offset(6, 0), crossPaint);
    canvas.drawLine(center + const Offset(6, 0), center + const Offset(14, 0), crossPaint);
    canvas.drawLine(center - const Offset(0, 14), center - const Offset(0, 6), crossPaint);
    canvas.drawLine(center + const Offset(0, 6), center + const Offset(0, 14), crossPaint);
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
          ..color = Colors.white.withValues(alpha: 0.04)
          ..strokeWidth = 0.6;

    final techGridPaint =
        Paint()
          ..color = const Color(0xFF00E5FF).withValues(alpha: 0.025)
          ..strokeWidth = 1.2;

    final stepMeters = _gridStepMeters(viewport.scale);
    final startX = (viewport.bounds.minX / stepMeters).floor() * stepMeters;
    final endX = (viewport.bounds.maxX / stepMeters).ceil() * stepMeters;
    final startY = (viewport.bounds.minY / stepMeters).floor() * stepMeters;
    final endY = (viewport.bounds.maxY / stepMeters).ceil() * stepMeters;

    // Background patterns
    for (double x = startX; x <= endX; x += stepMeters) {
      final canvasX = viewport.worldToCanvas(Offset(x, viewport.bounds.minY)).dx;
      canvas.drawLine(
        Offset(canvasX, 0),
        Offset(canvasX, viewport.size.height),
        (x.toInt() % 10 == 0) ? techGridPaint : gridPaint,
      );
    }
    for (double y = startY; y <= endY; y += stepMeters) {
      final canvasY = viewport.worldToCanvas(Offset(viewport.bounds.minX, y)).dy;
      canvas.drawLine(
        Offset(0, canvasY),
        Offset(viewport.size.width, canvasY),
        (y.toInt() % 10 == 0) ? techGridPaint : gridPaint,
      );
    }

    // Origin axis marker
    final origin = viewport.worldToCanvas(Offset.zero);
    final originPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;
    canvas.drawCircle(origin, 4, originPaint);
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
