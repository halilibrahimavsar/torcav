import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/floor_plan.dart';
import '../../domain/entities/heatmap_point.dart';
import '../../domain/entities/heatmap_session.dart';
import '../../domain/entities/wall_segment.dart';

/// Renders signal-strength data and floor plan walls.
class HeatmapCanvas extends StatefulWidget {
  final HeatmapSession session;
  final FloorPlan? floorPlan;
  final void Function(Offset metricPos)? onTap;
  final bool showPath;
  final int? activeFloor;
  final Offset? currentPosition;
  final double? currentHeading;

  /// Optional RSSI bounds for adaptive color scaling.
  /// When null, derived from actual session points.
  final int? minRssi;
  final int? maxRssi;

  /// Show the fit-to-view reset button (bottom-left corner).
  final bool showControls;

  const HeatmapCanvas({
    required this.session,
    this.floorPlan,
    this.onTap,
    this.showPath = false,
    this.activeFloor,
    this.currentPosition,
    this.currentHeading,
    this.minRssi,
    this.maxRssi,
    this.showControls = true,
    this.isMiniMap = false,
    super.key,
  });

  final bool isMiniMap;

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

  void _resetZoom() {
    setState(() {
      _transformationController.value = Matrix4.identity();
    });
  }

  @override
  Widget build(BuildContext context) {
    final points =
        widget.activeFloor == null
            ? widget.session.points
            : widget.session.points
                .where((p) => p.floor == widget.activeFloor)
                .toList();

    // Adaptive RSSI range
    final int effectiveMinRssi;
    final int effectiveMaxRssi;
    if (widget.minRssi != null && widget.maxRssi != null) {
      effectiveMinRssi = widget.minRssi!;
      effectiveMaxRssi = widget.maxRssi!;
    } else if (points.isNotEmpty) {
      effectiveMinRssi = points.map((p) => p.rssi).reduce(math.min);
      effectiveMaxRssi = points.map((p) => p.rssi).reduce(math.max);
    } else {
      effectiveMinRssi = -90;
      effectiveMaxRssi = -35;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final worldBounds = widget.isMiniMap
            ? _WorldBounds.forMiniMap(
                points: points,
                currentPosition: widget.currentPosition,
              )
            : _WorldBounds.fromData(
                points: points,
                walls: widget.floorPlan?.walls ?? const [],
                currentPosition: widget.currentPosition,
              );
        final viewport = _Viewport.fit(size, worldBounds);

        return Stack(
          children: [
            InteractiveViewer(
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
                            final RenderBox box =
                                context.findRenderObject() as RenderBox;
                            final Offset localOffset = box.globalToLocal(
                              details.globalPosition,
                            );
                            final Matrix4 matrix =
                                _transformationController.value;
                            final Matrix4 inverse = Matrix4.inverted(matrix);
                            final Offset transformed =
                                MatrixUtils.transformPoint(inverse, localOffset);
                            widget.onTap!(viewport.canvasToWorld(transformed));
                          },
                child: Stack(
                  children: [
                    // ── Static layer: grid, walls, heatmap, path, HUD overlays ──
                    // RepaintBoundary isolates this from position/heading updates.
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: _StaticHeatmapPainter(
                          points: points,
                          floorPlan: widget.floorPlan,
                          viewport: viewport,
                          showPath: widget.showPath,
                          minRssi: effectiveMinRssi,
                          maxRssi: effectiveMaxRssi,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),

                    // ── Dynamic layer: current-position dot + heading arrow ──
                    // Repaints only when position/heading changes; keeps static
                    // layer untouched (no expensive blur re-computation).
                    if (widget.currentPosition != null)
                      RepaintBoundary(
                        child: CustomPaint(
                          painter: _PositionPainter(
                            position: widget.currentPosition!,
                            heading: widget.currentHeading ?? 0.0,
                            viewport: viewport,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Fit-to-view button — bottom-left
            if (widget.showControls)
              Positioned(
                left: 14,
                bottom: 14,
                child: _FitButton(onTap: _resetZoom),
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Fit-to-view control
// ---------------------------------------------------------------------------

class _FitButton extends StatelessWidget {
  const _FitButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: const Icon(
          Icons.fit_screen_rounded,
          color: Colors.white70,
          size: 18,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Static painter — heavy content, isolated behind RepaintBoundary
// ---------------------------------------------------------------------------

class _StaticHeatmapPainter extends CustomPainter {
  final List<HeatmapPoint> points;
  final FloorPlan? floorPlan;
  final _Viewport viewport;
  final bool showPath;
  final int minRssi;
  final int maxRssi;

  _StaticHeatmapPainter({
    required this.points,
    required this.floorPlan,
    required this.viewport,
    required this.showPath,
    required this.minRssi,
    required this.maxRssi,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    if (floorPlan != null && floorPlan!.walls.isNotEmpty) {
      _drawWalls(canvas, floorPlan!.walls);
    }

    if (showPath) {
      _drawPath(canvas, points);
    }

    if (points.isNotEmpty) {
      _drawHeatmap(canvas, points);
    }

    if (points.any((p) => p.isFlagged)) {
      _drawFlags(canvas, points.where((p) => p.isFlagged).toList());
    }

    // HUD overlays
    _drawScaleBar(canvas, size);
    _drawCompassRose(canvas);
    if (points.isNotEmpty) {
      _drawRssiLegend(canvas, size);
    }
  }

  // -------------------------------------------------------------------------
  // Heatmap blobs
  // -------------------------------------------------------------------------

  void _drawHeatmap(Canvas canvas, List<HeatmapPoint> points) {
    if (points.isEmpty) return;

    final heatmapRadius = (viewport.scale * 1.8).clamp(28.0, 72.0);

    // Thermal Bloom: We layer semi-transparent disks with different blur radii
    // to create a smooth, organic 'glow' that looks premium.
    for (final point in points) {
      final centre = viewport.worldToCanvas(Offset(point.floorX, point.floorY));
      final signalColor = _signalColor(point.rssi);

      // Core: High opacity, small blur
      canvas.drawCircle(
        centre,
        heatmapRadius * 0.45,
        Paint()
          ..color = signalColor.withValues(alpha: 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );

      // Bloom: Lower opacity, wide spread
      canvas.drawCircle(
        centre,
        heatmapRadius,
        Paint()
          ..shader = ui.Gradient.radial(
            centre,
            heatmapRadius,
            [
              signalColor.withValues(alpha: 0.22),
              signalColor.withValues(alpha: 0),
            ],
            const [0.2, 1],
          ),
      );
    }

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

  // -------------------------------------------------------------------------
  // Walk path
  // -------------------------------------------------------------------------

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
    final firstPt =
        viewport.worldToCanvas(Offset(points.first.floorX, points.first.floorY));
    path.moveTo(firstPt.dx, firstPt.dy);
    for (int i = 1; i < points.length; i++) {
      final cp = viewport.worldToCanvas(
        Offset(points[i].floorX, points[i].floorY),
      );
      path.lineTo(cp.dx, cp.dy);
    }
    canvas.drawPath(path, pathPaint);

    canvas.drawCircle(
      firstPt,
      5.0,
      Paint()..color = const Color(0xFF39FF14).withValues(alpha: 0.9),
    );

    final last =
        viewport.worldToCanvas(Offset(points.last.floorX, points.last.floorY));
    canvas.drawCircle(
      last,
      6.5,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  // -------------------------------------------------------------------------
  // Walls — solid architectural style
  // -------------------------------------------------------------------------

  void _drawWalls(Canvas canvas, List<WallSegment> walls) {
    final shadowPaint =
        Paint()
          ..color = Colors.black.withValues(alpha: 0.55)
          ..strokeWidth = 7.0
          ..strokeCap = StrokeCap.square
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    final wallPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.88)
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.square
          ..style = PaintingStyle.stroke;

    for (final wall in walls) {
      final p1 = viewport.worldToCanvas(Offset(wall.x1, wall.y1));
      final p2 = viewport.worldToCanvas(Offset(wall.x2, wall.y2));
      canvas.drawLine(p1, p2, shadowPaint);
      canvas.drawLine(p1, p2, wallPaint);
    }
  }

  // -------------------------------------------------------------------------
  // Flagged zones
  // -------------------------------------------------------------------------

  void _drawFlags(Canvas canvas, List<HeatmapPoint> points) {
    final fill = Paint()
      ..color = const Color(0xFFFF5F57)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
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

  // -------------------------------------------------------------------------
  // Grid (lines only — no labels for performance)
  // -------------------------------------------------------------------------

  void _drawGrid(Canvas canvas, Size size) {
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

    for (double x = startX; x <= endX; x += stepMeters) {
      final canvasX = viewport.worldToCanvas(Offset(x, viewport.bounds.minY)).dx;
      canvas.drawLine(
        Offset(canvasX, 0),
        Offset(canvasX, size.height),
        (x.toInt() % 10 == 0) ? techGridPaint : gridPaint,
      );
    }
    for (double y = startY; y <= endY; y += stepMeters) {
      final canvasY = viewport.worldToCanvas(Offset(viewport.bounds.minX, y)).dy;
      canvas.drawLine(
        Offset(0, canvasY),
        Offset(size.width, canvasY),
        (y.toInt() % 10 == 0) ? techGridPaint : gridPaint,
      );
    }

    // Origin marker
    final origin = viewport.worldToCanvas(Offset.zero);
    canvas.drawCircle(
      origin,
      4,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  double _gridStepMeters(double scale) {
    if (scale > 110) return 1;
    if (scale > 55) return 2;
    return 5;
  }

  // -------------------------------------------------------------------------
  // Scale bar (bottom-right)
  // -------------------------------------------------------------------------

  void _drawScaleBar(Canvas canvas, Size size) {
    const margin = 16.0;
    const barHeight = 4.0;
    const maxBarPx = 80.0;

    final candidateMeters = [1, 2, 5, 10, 20, 50];
    int barMeters = 1;
    for (final m in candidateMeters) {
      if (viewport.scale * m <= maxBarPx) barMeters = m;
    }
    final barPx = viewport.scale * barMeters;

    final right = size.width - margin;
    final bottom = size.height - margin;
    final left = right - barPx;

    final linePaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.75)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.square;

    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), linePaint);
    canvas.drawLine(
      Offset(left, bottom - barHeight),
      Offset(left, bottom + barHeight),
      linePaint,
    );
    canvas.drawLine(
      Offset(right, bottom - barHeight),
      Offset(right, bottom + barHeight),
      linePaint,
    );

    _drawText(
      canvas,
      '$barMeters m',
      Offset((left + right) / 2, bottom - 12),
      GoogleFonts.outfit(
        color: Colors.white.withValues(alpha: 0.75),
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
      centerX: true,
    );
  }

  // -------------------------------------------------------------------------
  // Compass rose (top-right)
  // -------------------------------------------------------------------------

  void _drawCompassRose(Canvas canvas) {
    const margin = 16.0;
    const radius = 16.0;
    final center = Offset(viewport.size.width - margin - radius, margin + radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = Colors.black.withValues(alpha: 0.45),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final northPath =
        Path()
          ..moveTo(center.dx, center.dy - 10)
          ..lineTo(center.dx + 5, center.dy + 2)
          ..lineTo(center.dx - 5, center.dy + 2)
          ..close();
    canvas.drawPath(
      northPath,
      Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.9),
    );

    final southPath =
        Path()
          ..moveTo(center.dx, center.dy + 10)
          ..lineTo(center.dx + 5, center.dy - 2)
          ..lineTo(center.dx - 5, center.dy - 2)
          ..close();
    canvas.drawPath(
      southPath,
      Paint()..color = Colors.white.withValues(alpha: 0.25),
    );

    _drawText(
      canvas,
      'N',
      Offset(center.dx, center.dy - radius - 11),
      GoogleFonts.orbitron(
        color: const Color(0xFF00E5FF).withValues(alpha: 0.9),
        fontSize: 9,
        fontWeight: FontWeight.bold,
      ),
      centerX: true,
    );
  }

  // -------------------------------------------------------------------------
  // RSSI legend (left edge)
  // -------------------------------------------------------------------------

  void _drawRssiLegend(Canvas canvas, Size size) {
    const barW = 8.0;
    const barH = 110.0;
    const marginLeft = 10.0;

    final top = (size.height - barH) / 2;
    final rect = Rect.fromLTWH(marginLeft, top, barW, barH);

    final gradPaint =
        Paint()
          ..shader = ui.Gradient.linear(
            rect.topCenter,
            rect.bottomCenter,
            [
              _signalColor(maxRssi),
              _signalColor((minRssi + maxRssi) ~/ 2),
              _signalColor(minRssi),
            ],
            [0, 0.5, 1],
          );

    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)));
    canvas.drawRect(rect, gradPaint);
    canvas.restore();

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    final labelStyle = GoogleFonts.outfit(
      color: Colors.white.withValues(alpha: 0.6),
      fontSize: 8.5,
    );
    final tickX = marginLeft + barW + 5;
    _drawText(canvas, '$maxRssi', Offset(tickX, top - 1), labelStyle);
    _drawText(
      canvas,
      '${(minRssi + maxRssi) ~/ 2}',
      Offset(tickX, top + barH / 2 - 5),
      labelStyle,
    );
    _drawText(canvas, '$minRssi', Offset(tickX, top + barH - 10), labelStyle);

    _drawText(
      canvas,
      'dBm',
      Offset(marginLeft + barW / 2, top - 13),
      GoogleFonts.outfit(
        color: Colors.white.withValues(alpha: 0.4),
        fontSize: 8,
        fontWeight: FontWeight.w600,
      ),
      centerX: true,
    );
  }

  // -------------------------------------------------------------------------
  // Signal color (adaptive range)
  // -------------------------------------------------------------------------

  Color _signalColor(int rssi) {
    final range = (maxRssi - minRssi).abs();
    final normalized =
        range == 0 ? 0.5 : ((rssi - minRssi) / range).clamp(0.0, 1.0);

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

  // -------------------------------------------------------------------------
  // Text helper
  // -------------------------------------------------------------------------

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    TextStyle style, {
    bool centerX = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = centerX
        ? Offset(position.dx - tp.width / 2, position.dy)
        : position;
    tp.paint(canvas, offset);
  }

  // -------------------------------------------------------------------------

  @override
  bool shouldRepaint(_StaticHeatmapPainter old) =>
      old.points != points ||
      old.floorPlan != floorPlan ||
      old.viewport != viewport ||
      old.showPath != showPath ||
      old.minRssi != minRssi ||
      old.maxRssi != maxRssi;
}

// ---------------------------------------------------------------------------
// Dynamic painter — lightweight position indicator only
// ---------------------------------------------------------------------------

class _PositionPainter extends CustomPainter {
  final Offset position;
  final double heading;
  final _Viewport viewport;

  const _PositionPainter({
    required this.position,
    required this.heading,
    required this.viewport,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = viewport.worldToCanvas(position);

    // Outer glow
    canvas.drawCircle(
      center,
      14,
      Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Directional cone (Premium HUD style)
    // heading is in geographic degrees (0° = North). The viewport flips Y
    // so north = canvas -Y direction. canvas.rotate(0) points to +X (east).
    // Therefore: canvasAngle = (heading - 90) * π/180
    final headingRad = (heading - 90.0) * math.pi / 180.0;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(headingRad);
    final conePath =
        Path()
          ..moveTo(0, 0)
          ..lineTo(-25, -60)
          ..quadraticBezierTo(0, -75, 25, -60)
          ..close();
    canvas.drawPath(
      conePath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          const Offset(0, -70),
          [
            const Color(0xFF00E5FF).withValues(alpha: 0.35),
            const Color(0xFF00E5FF).withValues(alpha: 0.05),
          ],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Directional pointer (Center arrow)
    canvas.drawPath(
      Path()
        ..moveTo(0, -10)
        ..lineTo(6, 4)
        ..lineTo(0, 1)
        ..lineTo(-6, 4)
        ..close(),
      Paint()
        ..color = const Color(0xFF00E5FF)
        ..style = PaintingStyle.fill,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PositionPainter old) =>
      old.position != position ||
      old.heading != heading ||
      old.viewport != viewport;
}

// ---------------------------------------------------------------------------
// Viewport — Y-axis flipped so north (high Y) = top of screen
// ---------------------------------------------------------------------------

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

  /// World → canvas. Y is flipped: north (high world-Y) maps to top of screen.
  Offset worldToCanvas(Offset world) => Offset(
    offsetX + ((world.dx - bounds.minX) * scale),
    offsetY + ((bounds.maxY - world.dy) * scale),
  );

  /// Canvas → world (inverse of worldToCanvas).
  Offset canvasToWorld(Offset canvasPoint) => Offset(
    ((canvasPoint.dx - offsetX) / scale) + bounds.minX,
    bounds.maxY - ((canvasPoint.dy - offsetY) / scale),
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

// ---------------------------------------------------------------------------
// World bounds
// ---------------------------------------------------------------------------

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
    Offset? currentPosition,
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

  factory _WorldBounds.forMiniMap({
    required List<HeatmapPoint> points,
    Offset? currentPosition,
  }) {
    if (currentPosition == null) {
      return _WorldBounds.fromData(points: points, walls: const []);
    }

    // Auto-zoom: padding grows with the survey area's extent, but stays within
    // reasonable bounds for a "mini-map" feel.
    final surveyX = points.isEmpty ? 0.0 : points.map((p) => p.floorX).reduce(math.max) - points.map((p) => p.floorX).reduce(math.min);
    final surveyY = points.isEmpty ? 0.0 : points.map((p) => p.floorY).reduce(math.max) - points.map((p) => p.floorY).reduce(math.min);
    final extent = math.max(surveyX, surveyY);

    // Dynamic radius: starts at 5m, increases slightly as survey grows, capped at 15m.
    final radius = (5.0 + (extent * 0.15)).clamp(5.0, 15.0);

    return _WorldBounds(
      minX: currentPosition.dx - radius,
      maxX: currentPosition.dx + radius,
      minY: currentPosition.dy - radius,
      maxY: currentPosition.dy + radius,
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
