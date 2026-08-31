import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/theme/app_theme.dart';

import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';
import 'heatmap_compass.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Renders signal-strength data as a 2D heatmap.
part 'heatmap_canvas_painters.dart';
part 'heatmap_canvas_viewport.dart';

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
                            if (!mounted) return;
                            final renderObject = context.findRenderObject();
                            if (renderObject is! RenderBox) return;

                            final Offset localOffset = renderObject.globalToLocal(
                              details.globalPosition,
                            );
                            final Matrix4 matrix =
                                _transformationController.value;

                            // Guard against singular matrix (scale 0 etc)
                            final determinant = matrix.determinant();
                            if (determinant == 0) return;

                            final Matrix4 inverse = Matrix4.inverted(matrix);
                            final Offset transformed =
                                MatrixUtils.transformPoint(
                                  inverse,
                                  localOffset,
                                );
                            widget.onTap?.call(viewport.canvasToWorld(transformed));
                          },
                  child: Semantics(
                    // The map itself cannot be read aloud; its census can, and
                    // the placement advice below the survey says what to do
                    // about it.
                    label: context.l10n.a11yCoverageMap(
                      points.length,
                      points.where((p) => p.rssi <= -75).length,
                    ),
                    child: ExcludeSemantics(
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
