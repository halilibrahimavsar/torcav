part of 'heatmap_canvas.dart';

// Everything that draws: the static layer (grid, walls, heat, path), the
// dynamic position marker, and the HUD. Split out of heatmap_canvas.dart,
// which had grown to 1.201 lines and nine classes — a size that forced any
// test of a single painter to stand up the whole canvas.
//
// A `part` rather than a separate library so these stay private to the
// canvas, matching how the blocs in this project split their states.

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

    // Tek geçişte centre + signalColor hesapla — ikinci loop'ta tekrar
    // hesaplamamak için cache'le. Paint sıralaması korunmalı: tüm bloom'lar
    // önce, center dot'lar üzerine.
    final centres = <Offset>[];
    final signalColors = <Color>[];
    for (final point in points) {
      centres.add(viewport.worldToCanvas(Offset(point.floorX, point.floorY)));
      signalColors.add(_signalColor(point.rssi));
    }

    // Thermal Bloom: We layer semi-transparent disks with different blur radii
    // to create a smooth, organic 'glow' that looks premium.
    for (var i = 0; i < points.length; i++) {
      final centre = centres[i];
      final signalColor = signalColors[i];

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

    // Center dot'lar tüm bloom'ların üstüne — ayrı geçiş bu sıralamayı garanti
    // eder (merge edilirse A'nın dot'u B'nin bloom'unun altında kalabilir).
    final dotPaint = Paint()
      ..color = theme.colorScheme.onSurface.withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    for (final centre in centres) {
      canvas.drawCircle(centre, 2.4, dotPaint);
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

    const tickX = marginLeft + barW + 8;
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
