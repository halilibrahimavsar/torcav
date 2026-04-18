import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/theme/app_theme.dart';

import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';
import 'heatmap_compass.dart';

/// Renders signal-strength data as a 2D heatmap.
class HeatmapCanvas extends StatefulWidget {
  final HeatmapSession session;
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
    this.onTap,
    this.showPath = false,
    this.activeFloor,
    this.currentPosition,
    this.currentHeading,
    this.minRssi,
    this.maxRssi,
    this.showControls = true,
    this.isMiniMap = false,
    this.coverageScore = 1.0,
    this.sparseRegion,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final bool isMiniMap;
  final double coverageScore;
  final SparseRegion? sparseRegion;
  final EdgeInsets padding;

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
        final worldBounds =
            widget.isMiniMap
                ? _WorldBounds.forMiniMap(
                  points: points,
                  currentPosition: widget.currentPosition,
                )
                : _WorldBounds.fromData(
                  points: points,
                  currentPosition: widget.currentPosition,
                );
        final viewport = _Viewport.fit(size, worldBounds, widget.padding);

        return ClipRect(
          child: Stack(
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
                                MatrixUtils.transformPoint(
                                  inverse,
                                  localOffset,
                                );
                            widget.onTap!(viewport.canvasToWorld(transformed));
                          },
                  child: Stack(
                    children: [
                      // ── Static layer: grid, walls, heatmap, path, HUD overlays ──
                      // RepaintBoundary isolates this from position/heading updates.
                      RepaintBoundary(
                        child: CustomPaint(
                          painter: _StaticHeatmapPainter(
                            theme: Theme.of(context),
                            points: points,
                            viewport: viewport,
                            showPath: widget.showPath,
                            minRssi: effectiveMinRssi,
                            maxRssi: effectiveMaxRssi,
                            isMiniMap: widget.isMiniMap,
                            coverageScore: widget.coverageScore,
                            sparseRegion: widget.sparseRegion,
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
                              theme: Theme.of(context),
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

              // Premium Rotating Compass — top-right
              if (widget.showControls && !widget.isMiniMap)
                const Positioned(
                  top: 14,
                  right: 14,
                  child: HeatmapCompass(size: 64),
                ),

              // HUD Overlay (Vignette & Framing)
              if (!widget.isMiniMap)
                IgnorePointer(child: _HudOverlay(theme: Theme.of(context))),
            ],
          ),
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
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(
          Icons.fit_screen_rounded,
          color: Theme.of(context).colorScheme.primary,
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
  final ThemeData theme;
  final List<HeatmapPoint> points;
  final _Viewport viewport;
  final bool showPath;
  final int minRssi;
  final int maxRssi;
  final bool isMiniMap;
  final double coverageScore;
  final SparseRegion? sparseRegion;

  _StaticHeatmapPainter({
    required this.theme,
    required this.points,
    required this.viewport,
    required this.showPath,
    required this.minRssi,
    required this.maxRssi,
    required this.isMiniMap,
    required this.coverageScore,
    this.sparseRegion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Skip grid, scale bar, and RSSI legend in mini-map mode — they are
    // invisible at 160×160 and the blur/TextPainter allocations are costly.
    if (!isMiniMap) _drawGrid(canvas, size);

    if (showPath) {
      _drawPath(canvas, points);
    }

    if (points.isNotEmpty) {
      _drawHeatmap(canvas, points);
    }

    if (points.any((p) => p.isFlagged)) {
      _drawFlags(canvas, points.where((p) => p.isFlagged).toList());
    }

    if (!isMiniMap) {
      _drawScaleBar(canvas, size);
      if (points.isNotEmpty) {
        _drawRssiLegend(canvas, size);
      }
    }

    if (coverageScore < 0.35) {
      _drawSparseTint(canvas, size);
    }
  }

  void _drawSparseTint(Canvas canvas, Size size) {
    // Subtle darkening overlay when coverage is critically low (<35%)
    // This visually signals that the data is "under-baked"
    final paint =
        Paint()
          ..color = theme.colorScheme.surface.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill;

    final region = sparseRegion;
    if (region == null) {
      // Global vignette if no specific sparse region
      canvas.drawRect(Offset.zero & size, paint);
    } else {
      // Targeted tint for the sparse quadrant
      final halfW = size.width / 2;
      final halfH = size.height / 2;
      final Rect tintRect;
      switch (region) {
        case SparseRegion.leftWing:
          tintRect = Rect.fromLTWH(0, 0, halfW, size.height);
          break;
        case SparseRegion.rightWing:
          tintRect = Rect.fromLTWH(halfW, 0, halfW, size.height);
          break;
        case SparseRegion.topWing:
          tintRect = Rect.fromLTWH(0, 0, size.width, halfH);
          break;
        case SparseRegion.bottomWing:
          tintRect = Rect.fromLTWH(0, halfH, size.width, halfH);
          break;
      }
      canvas.drawRect(
        tintRect,
        Paint()
          ..shader = ui.Gradient.linear(
            tintRect.center,
            tintRect.bottomCenter, // Dummy start/end
            [
              theme.colorScheme.surface.withValues(alpha: 0.45),
              Colors.transparent,
            ],
          ),
      );
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
          ..color = theme.colorScheme.onSurface.withValues(alpha: 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
      );
    }
  }

  // -------------------------------------------------------------------------
  // Walk path
  // -------------------------------------------------------------------------

  void _drawPath(Canvas canvas, List<HeatmapPoint> points) {
    if (points.length < 2) return;

    // Base trail — faded polyline for all older segments.
    final basePaint =
        Paint()
          ..color = theme.colorScheme.onSurface.withValues(alpha: 0.28)
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final firstPt = viewport.worldToCanvas(
      Offset(points.first.floorX, points.first.floorY),
    );
    path.moveTo(firstPt.dx, firstPt.dy);
    for (int i = 1; i < points.length; i++) {
      final cp = viewport.worldToCanvas(
        Offset(points[i].floorX, points[i].floorY),
      );
      path.lineTo(cp.dx, cp.dy);
    }
    canvas.drawPath(path, basePaint);

    // Recent-segment emphasis — redraw the last 3 segments with a brighter,
    // thicker cyan stroke so the user can see "where I just walked" at a glance
    // on the mini-map. Applied in all modes but most visible when isMiniMap.
    if (points.length >= 2) {
      final recentPaint =
          Paint()
            ..color = theme.colorScheme.primary.withValues(alpha: 0.85)
            ..strokeWidth = isMiniMap ? 3.2 : 2.6
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round;
      final recentStart = math.max(0, points.length - 4);
      final recentPath = Path();
      final startPt = viewport.worldToCanvas(
        Offset(points[recentStart].floorX, points[recentStart].floorY),
      );
      recentPath.moveTo(startPt.dx, startPt.dy);
      for (int i = recentStart + 1; i < points.length; i++) {
        final cp = viewport.worldToCanvas(
          Offset(points[i].floorX, points[i].floorY),
        );
        recentPath.lineTo(cp.dx, cp.dy);
      }
      canvas.drawPath(recentPath, recentPaint);
    }

    canvas.drawCircle(
      firstPt,
      5.0,
      Paint()..color = theme.colorScheme.primary.withValues(alpha: 0.9),
    );

    final last = viewport.worldToCanvas(
      Offset(points.last.floorX, points.last.floorY),
    );
    canvas.drawCircle(
      last,
      6.5,
      Paint()
        ..color = theme.colorScheme.onSurface.withValues(alpha: 0.92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  // -------------------------------------------------------------------------
  // Flagged zones
  // -------------------------------------------------------------------------

  void _drawFlags(Canvas canvas, List<HeatmapPoint> points) {
    final isLight = theme.brightness == Brightness.light;
    final flagColor = isLight ? AppColors.inkRed : theme.colorScheme.error;

    final fill =
        Paint()
          ..color = flagColor
          ..style = PaintingStyle.fill;
    final stroke =
        Paint()
          ..color = theme.colorScheme.onSurface.withValues(alpha: 0.95)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;

    for (final point in points) {
      final center = viewport.worldToCanvas(Offset(point.floorX, point.floorY));
      canvas.drawCircle(
        center,
        10,
        Paint()
          ..color = flagColor.withValues(alpha: 0.22)
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
    final isLight = theme.brightness == Brightness.light;
    final gridPaint =
        Paint()
          ..color = theme.colorScheme.onSurface.withValues(alpha: 0.05)
          ..strokeWidth = 0.6;

    final techGridPaint =
        Paint()
          ..color = theme.colorScheme.primary.withValues(
            alpha: isLight ? 0.12 : 0.08,
          )
          ..strokeWidth = 1.2;

    final stepMeters = _gridStepMeters(viewport.scale);
    final startX = (viewport.bounds.minX / stepMeters).floor() * stepMeters;
    final endX = (viewport.bounds.maxX / stepMeters).ceil() * stepMeters;
    final startY = (viewport.bounds.minY / stepMeters).floor() * stepMeters;
    final endY = (viewport.bounds.maxY / stepMeters).ceil() * stepMeters;

    for (double x = startX; x <= endX; x += stepMeters) {
      final canvasX =
          viewport.worldToCanvas(Offset(x, viewport.bounds.minY)).dx;
      canvas.drawLine(
        Offset(canvasX, 0),
        Offset(canvasX, size.height),
        (x.toInt() % 10 == 0) ? techGridPaint : gridPaint,
      );
    }
    for (double y = startY; y <= endY; y += stepMeters) {
      final canvasY =
          viewport.worldToCanvas(Offset(viewport.bounds.minX, y)).dy;
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
        ..color = theme.colorScheme.onSurface.withValues(alpha: 0.12)
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
          ..color = theme.colorScheme.onSurface.withValues(alpha: 0.75)
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
        color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
      centerX: true,
    );
  }

  // -------------------------------------------------------------------------
  // RSSI Legend — glassmorphic analytic style
  // -------------------------------------------------------------------------

  void _drawRssiLegend(Canvas canvas, Size size) {
    const barW = 8.0;
    const barH = 100.0;
    const marginLeft = 16.0;
    const padding = 12.0;

    final top = (size.height - barH) / 2;

    // Glass Background Plate
    final plateRect = Rect.fromLTWH(
      marginLeft - padding,
      top - padding - 20, // room for dBm title
      barW + padding + 35, // room for labels
      barH + (padding * 2) + 20,
    );

    final isLight = theme.brightness == Brightness.light;
    final platePaint =
        Paint()
          ..color = theme.colorScheme.surface.withValues(
            alpha: isLight ? 0.75 : 0.45,
          )
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, isLight ? 1 : 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(plateRect, const Radius.circular(12)),
      platePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(plateRect, const Radius.circular(12)),
      Paint()
        ..color = theme.colorScheme.onSurface.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Color Bar
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

    // Bar outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = theme.colorScheme.onSurface.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    final labelStyle = GoogleFonts.outfit(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
      fontSize: 9,
      fontWeight: FontWeight.w500,
    );

    final tickX = marginLeft + barW + 8;
    _drawText(canvas, '$maxRssi', Offset(tickX, top - 1), labelStyle);
    _drawText(
      canvas,
      '${(minRssi + maxRssi) ~/ 2}',
      Offset(tickX, top + barH / 2 - 5),
      labelStyle.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
    _drawText(canvas, '$minRssi', Offset(tickX, top + barH - 10), labelStyle);

    _drawText(
      canvas,
      'dBm',
      Offset(marginLeft + barW / 2, top - 22),
      GoogleFonts.orbitron(
        color: theme.colorScheme.primary.withValues(alpha: 0.8),
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
      ),
      centerX: true,
    );
  }

  // -------------------------------------------------------------------------
  // Signal color (adaptive range)
  // -------------------------------------------------------------------------

  Color _signalColor(int rssi) {
    if (rssi == 0) return Colors.transparent;

    final range = (maxRssi - minRssi).abs();
    final normalized =
        range == 0 ? 0.5 : ((rssi - minRssi) / range).clamp(0.0, 1.0);

    final isLight = theme.brightness == Brightness.light;
    final stops =
        isLight
            ? const [
              AppColors.inkRed,
              AppColors.inkOrange,
              AppColors.inkYellow,
              Color(0xFF7CB342), // Deeper ink lime
              AppColors.inkGreen,
            ]
            : const [
              AppColors.neonRed,
              AppColors.neonOrange,
              AppColors.neonYellow,
              Color(0xFF7DFF60), // Neon Lime
              AppColors.neonGreen,
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

    final offset =
        centerX ? Offset(position.dx - tp.width / 2, position.dy) : position;
    tp.paint(canvas, offset);
  }

  // -------------------------------------------------------------------------

  @override
  bool shouldRepaint(_StaticHeatmapPainter old) =>
      old.points != points ||
      old.viewport != viewport ||
      old.showPath != showPath ||
      old.minRssi != minRssi ||
      old.maxRssi != maxRssi ||
      old.isMiniMap != isMiniMap ||
      old.coverageScore != coverageScore ||
      old.sparseRegion != sparseRegion;
}

// ---------------------------------------------------------------------------
// Dynamic painter — lightweight position indicator only
// ---------------------------------------------------------------------------

class _PositionPainter extends CustomPainter {
  final ThemeData theme;
  final Offset position;
  final double heading;
  final _Viewport viewport;

  const _PositionPainter({
    required this.theme,
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
        ..color = theme.colorScheme.primary.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Dynamic scan pulse marker
    canvas.drawCircle(
      center,
      6.0,
      Paint()..color = theme.colorScheme.primary.withValues(alpha: 0.95),
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
        ..shader = ui.Gradient.linear(Offset.zero, const Offset(0, -70), [
          theme.colorScheme.primary.withValues(alpha: 0.4),
          theme.colorScheme.primary.withValues(alpha: 0.05),
        ])
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
        ..color = theme.colorScheme.primary
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

  factory _Viewport.fit(
    Size size,
    _WorldBounds bounds, [
    EdgeInsets padding = EdgeInsets.zero,
  ]) {
    const outerPadding = 18.0;
    final usableWidth = math.max(
      1.0,
      size.width - (outerPadding * 2) - padding.horizontal,
    );
    final usableHeight = math.max(
      1.0,
      size.height - (outerPadding * 2) - padding.vertical,
    );
    final scale = math.min(
      usableWidth / bounds.width,
      usableHeight / bounds.height,
    );
    final contentWidth = bounds.width * scale;
    final contentHeight = bounds.height * scale;

    // Position within the padded area: left + (remaining_width / 2)
    final offsetX =
        outerPadding + padding.left + (usableWidth - contentWidth) / 2;
    // Position within the padded area: top + (remaining_height / 2)
    final offsetY =
        outerPadding + padding.top + (usableHeight - contentHeight) / 2;

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
    Offset? currentPosition,
  }) {
    final xs = <double>[0];
    final ys = <double>[0];

    for (final point in points) {
      xs.add(point.floorX);
      ys.add(point.floorY);
    }

    if (currentPosition != null) {
      xs.add(currentPosition.dx);
      ys.add(currentPosition.dy);
    }

    var minX = xs.reduce(math.min);
    var maxX = xs.reduce(math.max);
    var minY = ys.reduce(math.min);
    var maxY = ys.reduce(math.max);

    // Ensure we always have at least a 5m x 5m view even if no movement
    // was recorded, to avoid the "dots-in-one-place" over-zoom.
    if ((maxX - minX).abs() < 5) {
      final center = (minX + maxX) / 2;
      minX = center - 2.5;
      maxX = center + 2.5;
    }
    if ((maxY - minY).abs() < 5) {
      final center = (minY + maxY) / 2;
      minY = center - 2.5;
      maxY = center + 2.5;
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
      return _WorldBounds.fromData(points: points);
    }

    // Auto-zoom: padding grows with the survey area's extent, but stays within
    // reasonable bounds for a "mini-map" feel.
    final surveyX =
        points.isEmpty
            ? 0.0
            : points.map((p) => p.floorX).reduce(math.max) -
                points.map((p) => p.floorX).reduce(math.min);
    final surveyY =
        points.isEmpty
            ? 0.0
            : points.map((p) => p.floorY).reduce(math.max) -
                points.map((p) => p.floorY).reduce(math.min);
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

// ---------------------------------------------------------------------------
// Premium HUD Overlay — Vignette and Framing
// ---------------------------------------------------------------------------

class _HudOverlay extends StatelessWidget {
  const _HudOverlay({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HudPainter(theme: theme),
      child: const SizedBox.expand(),
    );
  }
}

class _HudPainter extends CustomPainter {
  const _HudPainter({required this.theme});
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    _drawVignette(canvas, size);
    _drawCornerBrackets(canvas, size);
  }

  void _drawVignette(Canvas canvas, Size size) {
    final isLight = theme.brightness == Brightness.light;
    final rect = Offset.zero & size;
    final paint =
        Paint()
          ..shader = ui.Gradient.radial(
            rect.center,
            size.longestSide * 0.8,
            [
              Colors.transparent,
              theme.colorScheme.surface.withValues(alpha: isLight ? 0.1 : 0.2),
              theme.colorScheme.surface.withValues(alpha: isLight ? 0.3 : 0.5),
            ],
            [0.4, 0.85, 1.0],
          );
    canvas.drawRect(rect, paint);
  }

  void _drawCornerBrackets(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = theme.colorScheme.primary.withValues(alpha: 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;

    const margin = 12.0;
    const len = 20.0;

    // TL
    canvas.drawPath(
      Path()
        ..moveTo(margin, margin + len)
        ..lineTo(margin, margin)
        ..lineTo(margin + len, margin),
      paint,
    );
    // TR
    canvas.drawPath(
      Path()
        ..moveTo(size.width - margin - len, margin)
        ..lineTo(size.width - margin, margin)
        ..lineTo(size.width - margin, margin + len),
      paint,
    );
    // BL
    canvas.drawPath(
      Path()
        ..moveTo(margin, size.height - margin - len)
        ..lineTo(margin, size.height - margin)
        ..lineTo(margin + len, size.height - margin),
      paint,
    );
    // BR
    canvas.drawPath(
      Path()
        ..moveTo(size.width - margin - len, size.height - margin)
        ..lineTo(size.width - margin, size.height - margin)
        ..lineTo(size.width - margin, size.height - margin - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(_HudPainter oldDelegate) => false;
}
