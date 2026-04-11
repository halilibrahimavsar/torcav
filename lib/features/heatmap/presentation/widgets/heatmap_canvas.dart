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
    super.key,
  });

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
        final worldBounds = _WorldBounds.fromData(
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
                child: CustomPaint(
                  painter: _HeatmapPainter(
                    points: points,
                    floorPlan: widget.floorPlan,
                    viewport: viewport,
                    showPath: widget.showPath,
                    currentPosition: widget.currentPosition,
                    currentHeading: widget.currentHeading,
                    minRssi: effectiveMinRssi,
                    maxRssi: effectiveMaxRssi,
                  ),
                  child: const SizedBox.expand(),
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
// Painter
// ---------------------------------------------------------------------------

class _HeatmapPainter extends CustomPainter {
  final List<HeatmapPoint> points;
  final FloorPlan? floorPlan;
  final _Viewport viewport;
  final bool showPath;
  final Offset? currentPosition;
  final double? currentHeading;
  final int minRssi;
  final int maxRssi;

  _HeatmapPainter({
    required this.points,
    required this.floorPlan,
    required this.viewport,
    required this.showPath,
    this.currentPosition,
    this.currentHeading,
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

    if (points.any((point) => point.isFlagged)) {
      _drawFlags(canvas, points.where((point) => point.isFlagged).toList());
    }

    if (currentPosition != null) {
      _drawCurrentPosition(canvas, currentPosition!, currentHeading ?? 0.0);
    }

    // HUD overlays — drawn on top of all data
    _drawScaleBar(canvas, size);
    _drawCompassRose(canvas);
    if (points.isNotEmpty) {
      _drawRssiLegend(canvas, size);
    }
  }

  // -------------------------------------------------------------------------
  // Current position
  // -------------------------------------------------------------------------

  void _drawCurrentPosition(Canvas canvas, Offset pos, double heading) {
    final center = viewport.worldToCanvas(pos);

    final pulsePaint =
        Paint()
          ..color = const Color(0xFF00E5FF).withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, 14, pulsePaint);

    final ringPaint =
        Paint()
          ..color = const Color(0xFF00E5FF).withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawCircle(center, 8, ringPaint);

    final pointerPaint =
        Paint()
          ..color = const Color(0xFF00E5FF)
          ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(heading);

    final path =
        Path()
          ..moveTo(0, -10)
          ..lineTo(6, 4)
          ..lineTo(0, 1)
          ..lineTo(-6, 4)
          ..close();

    canvas.drawPath(path, pointerPaint);
    canvas.restore();
  }

  // -------------------------------------------------------------------------
  // Heatmap blobs
  // -------------------------------------------------------------------------

  void _drawHeatmap(Canvas canvas, List<HeatmapPoint> points) {
    if (points.isEmpty) return;

    final heatmapRadius = (viewport.scale * 1.8).clamp(28.0, 72.0);
    final blurSigma = heatmapRadius * 0.45;

    canvas.saveLayer(
      Rect.fromLTWH(0, 0, viewport.size.width, viewport.size.height),
      Paint()
        ..imageFilter =
            ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
    );

    for (final point in points) {
      final centre = viewport.worldToCanvas(Offset(point.floorX, point.floorY));
      final signalColor = _signalColor(point.rssi);

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
      final canvasPoint = viewport.worldToCanvas(
        Offset(points[i].floorX, points[i].floorY),
      );
      path.lineTo(canvasPoint.dx, canvasPoint.dy);
    }
    canvas.drawPath(path, pathPaint);

    canvas.drawCircle(
      firstPt,
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

  // -------------------------------------------------------------------------
  // Grid + labels
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

    // Grid labels — show at every major step (5m, 10m, etc.)
    final labelStep = stepMeters * 5;
    final textStyle = GoogleFonts.outfit(
      color: Colors.white.withValues(alpha: 0.22),
      fontSize: 9,
    );

    for (double x = startX; x <= endX; x += labelStep) {
      if (x.abs() < 0.01) continue; // skip origin
      final canvasX = viewport.worldToCanvas(Offset(x, viewport.bounds.minY)).dx;
      if (canvasX < 12 || canvasX > size.width - 12) continue;
      _drawText(
        canvas,
        '${x.round()}m',
        Offset(canvasX, size.height - 14),
        textStyle,
        centerX: true,
      );
    }
    for (double y = startY; y <= endY; y += labelStep) {
      if (y.abs() < 0.01) continue;
      final canvasY = viewport.worldToCanvas(Offset(viewport.bounds.minX, y)).dy;
      if (canvasY < 12 || canvasY > size.height - 12) continue;
      _drawText(
        canvas,
        '${y.round()}m',
        Offset(14, canvasY - 5),
        textStyle,
        centerX: false,
      );
    }
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

    // Pick a nice round distance that fits in maxBarPx
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

    // Horizontal bar
    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), linePaint);
    // End caps
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

    // Label
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

    // Background circle
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

    // North triangle (points up)
    final northPath =
        Path()
          ..moveTo(center.dx, center.dy - 10) // tip
          ..lineTo(center.dx + 5, center.dy + 2)
          ..lineTo(center.dx - 5, center.dy + 2)
          ..close();
    canvas.drawPath(
      northPath,
      Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.9),
    );

    // South triangle (points down, dimmer)
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

    // "N" label above the rose
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
  // RSSI legend (left edge, vertically centered)
  // -------------------------------------------------------------------------

  void _drawRssiLegend(Canvas canvas, Size size) {
    const barW = 8.0;
    const barH = 110.0;
    const marginLeft = 10.0;

    final top = (size.height - barH) / 2;
    final rect = Rect.fromLTWH(marginLeft, top, barW, barH);

    // Gradient bar (strong signal = top = green, weak = bottom = red)
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

    // Rounded rect clip
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)));
    canvas.drawRect(rect, gradPaint);
    canvas.restore();

    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Tick labels: max (top), mid, min (bottom)
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

    // Header
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
  // Signal color
  // -------------------------------------------------------------------------

  Color _signalColor(int rssi) {
    // Normalize against adaptive range, clamped to [0,1]
    final range = (maxRssi - minRssi).abs();
    final normalized =
        range == 0 ? 0.5 : ((rssi - minRssi) / range).clamp(0.0, 1.0);

    const stops = [
      Color(0xFFFF3B30), // weak (red)
      Color(0xFFFF9F0A), // orange
      Color(0xFFFFD60A), // yellow
      Color(0xFF7DFF60), // lime
      Color(0xFF00E676), // strong (green)
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
  bool shouldRepaint(_HeatmapPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.floorPlan != floorPlan ||
      oldDelegate.viewport != viewport ||
      oldDelegate.showPath != showPath ||
      oldDelegate.minRssi != minRssi ||
      oldDelegate.maxRssi != maxRssi;
}

// ---------------------------------------------------------------------------
// Viewport
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

  /// World → canvas. Y is flipped so that north (high Y) = top of screen.
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
