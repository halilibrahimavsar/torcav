part of 'heatmap_canvas.dart';

// Coordinate maths: metres ↔ canvas pixels, and the bounds that decide the
// initial fit. Pure geometry, no painting and no widgets.

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
