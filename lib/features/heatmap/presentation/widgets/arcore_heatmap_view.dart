import 'dart:async';
import 'dart:math' as math;

import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/heatmap_point.dart';
import '../../domain/entities/wall_segment.dart';
import '../../domain/services/signal_tier.dart';
import '../../domain/services/survey_guidance_service.dart';
import '../bloc/heatmap_bloc.dart';
import '../bloc/scan_phase.dart';
import 'ar_hud_overlay.dart';

/// ARCore-backed heatmap view. Renders anchored floor-disc markers in metric
/// world space and delegates the 2D HUD + dBm label overlay to screen-space
/// Flutter widgets.
class ArCoreHeatmapView extends StatefulWidget {
  const ArCoreHeatmapView({super.key, this.onFinish, this.onDiscard});

  final VoidCallback? onFinish;
  final VoidCallback? onDiscard;

  @override
  State<ArCoreHeatmapView> createState() => _ArCoreHeatmapViewState();
}

class _ArCoreHeatmapViewState extends State<ArCoreHeatmapView> {
  static const _guidanceService = SurveyGuidanceService();
  static const _originNodeName = 'survey_origin';

  ArCoreController? _arCoreController;
  int _renderedPointCount = 0;
  final Set<String> _renderedFlagKeys = <String>{};

  /// Set of AR node name suffixes for wall detection dot markers already placed.
  final Set<String> _renderedWallDotKeys = <String>{};
  bool _originAttached = false;
  vector.Vector3? _originWorldPos;

  /// Max visual markers to render in the AR scene to avoid mapping degradation.
  /// Scanned data continues to be recorded in the background.
  static const _maxRenderedMarkers = 80;

  @override
  void dispose() {
    _isDisposed = true;
    _arCoreController?.onPlaneTap = null;
    _arCoreController?.onPlaneDetected = null;
    _arCoreController?.dispose();
    _arCoreController = null;
    super.dispose();
  }

  bool _isDisposed = false;

  void _onArCoreViewCreated(ArCoreController controller) {
    if (_isDisposed) return;
    _arCoreController = controller;
    controller.onPlaneTap = _handlePlaneTap;
    controller.onPlaneDetected = _handlePlaneDetected;
    _renderedPointCount = 0;
    _renderedFlagKeys.clear();
    _renderedWallDotKeys.clear();
    _originAttached = false;
    _originWorldPos = null;
    if (mounted) {
      final state = context.read<HeatmapBloc>().state;
      if (state.hasArOrigin) {
        context.read<HeatmapBloc>().resetArOrigin();
      }
    }
  }

  Future<void> _handlePlaneTap(List<ArCoreHitTestResult> hits) async {
    if (_arCoreController == null || hits.isEmpty) return;

    if (!_originAttached) {
      await _placeOrigin(hits.first);
    } else {
      await _recordManualPoint(hits.first);
    }
  }

  Future<void> _placeOrigin(ArCoreHitTestResult hit) async {
    final originNode = ArCoreNode(
      name: _originNodeName,
      position: hit.pose.translation,
      rotation: hit.pose.rotation,
      children: [
        // Central anchor sphere.
        ArCoreNode(
          name: 'survey_origin_marker',
          shape: ArCoreSphere(
            radius: 0.05,
            materials: [
              ArCoreMaterial(
                color: AppColors.neonCyan.withValues(alpha: 0.95),
                metallic: 0.9,
                reflectance: 0.85,
              ),
            ],
          ),
          position: vector.Vector3.zero(),
        ),
        // Sci-fi landing-pad ring at ground level.
        // ArCoreCylinder bug: toMap() swaps radius ↔ height.
        // Desired native: radius=0.15m, height=0.005m → pass swapped.
        ArCoreNode(
          name: 'survey_origin_pad',
          shape: ArCoreCylinder(
            radius: 0.005,
            height: 0.15,
            materials: [
              ArCoreMaterial(
                color: AppColors.neonCyan.withValues(alpha: 0.25),
                metallic: 0.9,
                reflectance: 0.8,
              ),
            ],
          ),
          position: vector.Vector3(0, 0.0025, 0),
        ),
      ],
    );
    await _arCoreController!.addArCoreNodeWithAnchor(originNode);
    _originAttached = true;
    _originWorldPos = hit.pose.translation.clone();
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    final bloc = context.read<HeatmapBloc>();
    bloc.markArOriginPlaced(bloc.state.currentHeading);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.gps_fixed_rounded,
              color: AppColors.neonCyan,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              bloc.state.isViewingInAr
                  ? 'Origin anchored — historical session active'
                  : 'Origin anchored — tap to record points',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.5)),
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    // Immediately sync nodes for pre-existing points (crucial for 3D Replay).
    final points =
        bloc.state.isViewingInAr
            ? (bloc.state.selectedSession?.points ?? const [])
            : (bloc.state.currentSession?.points ?? const []);
    await _syncAnchoredNodes(points);
  }

  Future<void> _recordManualPoint(ArCoreHitTestResult hit) async {
    if (_originWorldPos == null) return;
    final bloc = context.read<HeatmapBloc>();
    final s = bloc.state;
    if (s.currentRssi == null) return;

    // AR world displacement from origin → floor coordinates.
    // Convention (used throughout _addFloorMarker):
    //   AR node position = Vector3(floorX, y, -floorY)
    // So: floorX = AR dx, floorY = -(AR dz)
    final dx = hit.pose.translation.x - _originWorldPos!.x;
    final dz = hit.pose.translation.z - _originWorldPos!.z;
    final floorX = dx;
    final floorY = -dz;

    HapticFeedback.mediumImpact();
    await bloc.addPoint(
      HeatmapPoint(
        x: 0,
        y: 0,
        floorX: floorX,
        floorY: floorY,
        floorZ: 0,
        heading: s.currentHeading,
        rssi: s.currentRssi!,
        timestamp: DateTime.now(),
        ssid: s.targetSsid ?? '',
        bssid: s.targetBssid ?? '',
        floor: s.currentFloor,
        sampleCount: s.lastSignalSampleCount,
        rssiStdDev: s.lastSignalStdDev,
      ),
    );

    // Resync PDR to the verified AR position to prevent drift accumulation.
    bloc.syncPositionFromAr(floorX, floorY);
  }

  void _handlePlaneDetected(ArCorePlane plane) {
    if (plane.type != ArCorePlaneType.VERTICAL) return;
    if (!_originAttached || _originWorldPos == null) return;
    final centerPose = plane.centerPose;
    if (centerPose == null) return;

    // Rotate the plane's local X axis (wall length direction) into world space.
    final q = centerPose.rotation; // (x,y,z,w)
    final quat = vector.Quaternion(q.x, q.y, q.z, q.w);
    final wallDir = vector.Vector3(1, 0, 0);
    quat.rotate(wallDir); // world-space direction

    final halfLen = (plane.extendX ?? 0.5) / 2;

    // Require a minimum wall length to filter out noise.
    if (halfLen * 2 < 0.3) return;

    final cx = centerPose.translation.x;
    final cz = centerPose.translation.z;

    // Sample multiple evenly-spaced points along the plane for a stable
    // wall representation. More dots = better coverage of long walls.
    const sampleCount = 5;
    for (int i = 0; i < sampleCount; i++) {
      // t goes from -1 to +1 across the full plane extent.
      final t = sampleCount == 1 ? 0.0 : -1.0 + (2.0 * i / (sampleCount - 1));
      final wx = cx + wallDir.x * (halfLen * t);
      final wz = cz + wallDir.z * (halfLen * t);

      // Floor coordinates relative to origin.
      final floorX = wx - _originWorldPos!.x;
      final floorY = -((wz) - _originWorldPos!.z);

      // Place a visual detection dot in the AR scene for user feedback.
      // Use a stable key so we do not duplicate the same sample point.
      final dotKey = '${(floorX * 4).round()}_${(floorY * 4).round()}';
      if (!_renderedWallDotKeys.contains(dotKey)) {
        _renderedWallDotKeys.add(dotKey);
        unawaited(_addWallDetectionDot(floorX, floorY, dotKey));
      }
    }

    // Convert endpoints to floor coordinates.
    final floorSegment = WallSegment(
      x1: (cx - wallDir.x * halfLen) - _originWorldPos!.x,
      y1: -((cz - wallDir.z * halfLen) - _originWorldPos!.z),
      x2: (cx + wallDir.x * halfLen) - _originWorldPos!.x,
      y2: -((cz + wallDir.z * halfLen) - _originWorldPos!.z),
    );

    context.read<HeatmapBloc>().addWallFromAr(floorSegment);
  }

  /// Places a glowing cyan sphere at [floorX, floorY] in the AR scene
  /// to give the user visual feedback that a wall surface was detected.
  Future<void> _addWallDetectionDot(
    double floorX,
    double floorY,
    String key,
  ) async {
    if (_isDisposed || _arCoreController == null || !_originAttached) return;

    // Wall dots sit at ~1m height on the detected vertical plane.
    const dotHeight = 1.0;
    const dotRadius = 0.016; // 1.6 cm — compact, readable at arm's length
    const wiredRadius = 0.028; // outer aura ring

    // --- Core dot ---
    final coreNode = ArCoreNode(
      name: 'wdot_core_$key',
      shape: ArCoreSphere(
        radius: dotRadius,
        materials: [
          ArCoreMaterial(
            color: AppColors.neonCyan.withValues(alpha: 0.9),
            metallic: 0.1,
            reflectance: 0.95,
          ),
        ],
      ),
      position: vector.Vector3(floorX, dotHeight, -floorY),
    );

    // --- Aura halo (slightly larger, translucent) ---
    final haloNode = ArCoreNode(
      name: 'wdot_halo_$key',
      shape: ArCoreSphere(
        radius: wiredRadius,
        materials: [
          ArCoreMaterial(
            color: AppColors.neonCyan.withValues(alpha: 0.18),
            metallic: 0.0,
            reflectance: 0.0,
          ),
        ],
      ),
      position: vector.Vector3(floorX, dotHeight, -floorY),
    );

    await _arCoreController!.addArCoreNode(
      coreNode,
      parentNodeName: _originNodeName,
    );
    await _arCoreController!.addArCoreNode(
      haloNode,
      parentNodeName: _originNodeName,
    );
  }

  /// Adds a single flat disc marker on the AR floor for [point].
  ///
  /// ArCoreCylinder bug: `toMap()` swaps `radius` and `height` before sending
  /// to native. To get native radius=R and height=H, pass `radius: H, height: R`.
  Future<void> _addFloorMarker(HeatmapPoint point) async {
    if (_isDisposed || _arCoreController == null || !_originAttached) return;

    final color = signalGradientColor(point.rssi);
    final discRadius = signalDiscRadius(point.rssi); // 0.06–0.22m native radius
    const discNativeHeight = 0.015; // 1.5cm tall flat disc

    final disc = ArCoreNode(
      name: '${_markerName(point)}_disc',
      shape: ArCoreCylinder(
        // Swapped for plugin bug: native radius = height arg, native height = radius arg.
        radius: discNativeHeight,
        height: discRadius,
        materials: [
          ArCoreMaterial(
            color: color.withValues(alpha: 0.75),
            metallic: 0.5,
            reflectance: 0.65,
          ),
        ],
      ),
      position: vector.Vector3(
        point.floorX,
        point.floorZ + discNativeHeight / 2, // sit flush on floor
        -point.floorY,
      ),
    );

    await _arCoreController!.addArCoreNode(
      disc,
      parentNodeName: _originNodeName,
    );
  }

  Future<void> _addFlagMarker(HeatmapPoint point) async {
    if (_isDisposed || _arCoreController == null || !_originAttached) return;
    final key = _flagKey(point);
    if (_renderedFlagKeys.contains(key)) return;

    final pos = vector.Vector3(point.floorX, point.floorZ + 0.2, -point.floorY);

    final flagNode = ArCoreNode(
      name: 'flag_$key',
      shape: ArCoreSphere(
        radius: 0.11,
        materials: [
          ArCoreMaterial(
            color: AppColors.neonRed,
            metallic: 0.9,
            reflectance: 1.0,
          ),
        ],
      ),
      position: pos,
    );

    // Warning halo — translucent outer shell to draw attention.
    final haloNode = ArCoreNode(
      name: 'flag_halo_$key',
      shape: ArCoreSphere(
        radius: 0.17,
        materials: [
          ArCoreMaterial(
            color: AppColors.neonRed.withValues(alpha: 0.12),
            metallic: 0.3,
            reflectance: 0.2,
          ),
        ],
      ),
      position: pos,
    );

    await _arCoreController!.addArCoreNode(
      flagNode,
      parentNodeName: _originNodeName,
    );
    await _arCoreController!.addArCoreNode(
      haloNode,
      parentNodeName: _originNodeName,
    );
    _renderedFlagKeys.add(key);
  }

  String _markerName(HeatmapPoint point) =>
      'marker_${point.timestamp.microsecondsSinceEpoch}';

  String _flagKey(HeatmapPoint point) =>
      '${point.timestamp.microsecondsSinceEpoch}_${point.floorX.toStringAsFixed(2)}_${point.floorY.toStringAsFixed(2)}';

  Future<void> _syncAnchoredNodes(List<HeatmapPoint> points) async {
    if (!_originAttached || _arCoreController == null) return;
    if (_isDisposed) return;
    final newPoints = points.skip(_renderedPointCount).toList();
    if (newPoints.isNotEmpty && _renderedPointCount < _maxRenderedMarkers) {
      // Add all new floor markers in parallel — ARCore handles concurrency internally.
      // Cap the visual rendering to keep native RAM usage manageable.
      final pointsToAdd = newPoints.take(
        _maxRenderedMarkers - _renderedPointCount,
      );
      await Future.wait(pointsToAdd.map(_addFloorMarker));
      if (!_isDisposed) {
        _renderedPointCount += pointsToAdd.length;
      }
    }

    // Sync any newly flagged points.
    await Future.wait(points.where((p) => p.isFlagged).map(_addFlagMarker));
  }

  Future<void> _flagCurrentPosition() async {
    await context.read<HeatmapBloc>().flagCurrentWeakZone();
    if (!mounted) return;
    final session = context.read<HeatmapBloc>().state.currentSession;
    final point = session?.points.lastOrNull;
    if (point?.isFlagged == true) {
      await _addFlagMarker(point!);
    }
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.neonRed,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Weak zone flagged',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.neonRed.withValues(alpha: 0.5)),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HeatmapBloc, HeatmapState>(
      listenWhen: (previous, current) {
        final prevPoints =
            previous.currentSession?.points ?? const <HeatmapPoint>[];
        final currPoints =
            current.currentSession?.points ?? const <HeatmapPoint>[];
        final prevFlags = prevPoints.where((p) => p.isFlagged).length;
        final currFlags = currPoints.where((p) => p.isFlagged).length;
        return currPoints.length != prevPoints.length || currFlags != prevFlags;
      },
      listener: (context, state) async {
        if (_isDisposed) return;
        final points =
            state.isViewingInAr
                ? (state.selectedSession?.points ?? const [])
                : (state.currentSession?.points ?? const []);
        await _syncAnchoredNodes(points);
      },
      // Using the underlying Stack as a stable base, preventing ArCoreView
      // from being recreated on every sensor update.
      builder: (context, state) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Stable PlatformView child.
            _ArCoreNativeView(onCreated: _onArCoreViewCreated),

            // Performance-isolated overlays.
            if (state.phase == ScanPhase.scanning)
              const RepaintBoundary(child: _SignalLabelOverlay()),

            if (state.phase == ScanPhase.scanning)
              ArHudOverlay(
                guidance: _guidanceService.analyze(
                  points:
                      (state.isViewingInAr
                          ? state.selectedSession?.points
                          : state.currentSession?.points) ??
                      const [],
                  floorPlan:
                      state.isViewingInAr
                          ? state.selectedSession?.floorPlan
                          : state.liveFloorPlan,
                  isRecording: state.isRecording,
                  hasArOrigin: state.hasArOrigin,
                  pendingWallCount: state.pendingWalls.length,
                  currentRssi: state.currentRssi,
                  surveyGate: state.surveyGate,
                  lastSignalAt: state.lastSignalAt,
                  currentSignalStdDev: state.lastSignalStdDev,
                  currentX: state.currentPosition?.dx,
                  currentY: state.currentPosition?.dy,
                ),
                onFinish: widget.onFinish,
                onDiscard: widget.onDiscard,
                onFlagWeakZone: _flagCurrentPosition,
              ),
          ],
        );
      },
    );
  }
}

/// A stable hosting widget for ArCoreView that doesn't rebuild when its parent does.
class _ArCoreNativeView extends StatelessWidget {
  const _ArCoreNativeView({required this.onCreated});
  final void Function(ArCoreController) onCreated;

  @override
  Widget build(BuildContext context) {
    return ArCoreView(
      onArCoreViewCreated: onCreated,
      enableTapRecognizer: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen-space dBm label overlay.
//
// Since arcore_flutter_plugin has no 3D text support, we project each floor
// marker's world position into screen space using the current device heading
// and PDR position from HeatmapBloc, then render Flutter Text pills at those
// positions on top of the ArCoreView.
// ─────────────────────────────────────────────────────────────────────────────

class _SignalLabelOverlay extends StatelessWidget {
  const _SignalLabelOverlay();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, _LabelOverlaySlice>(
      selector: (s) {
        final points =
            s.isViewingInAr
                ? (s.selectedSession?.points ?? const [])
                : (s.currentSession?.points ?? const []);
        return _LabelOverlaySlice(
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
  static _ProjectionResult? _projectToScreen(
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

    return _ProjectionResult(Offset(screenX, 0), depth);
  }
}

class _ProjectionResult {
  const _ProjectionResult(this.offset, this.depth);
  final Offset offset;
  final double depth;
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

class _LabelOverlaySlice {
  const _LabelOverlaySlice({
    required this.points,
    required this.camX,
    required this.camY,
    required this.heading,
    required this.headingOffset,
    required this.hasOrigin,
  });

  final List<HeatmapPoint> points;
  final double camX;
  final double camY;
  final double heading;
  final double headingOffset;
  final bool hasOrigin;

  @override
  bool operator ==(Object other) =>
      other is _LabelOverlaySlice &&
      other.points == points &&
      other.camX == camX &&
      other.camY == camY &&
      other.heading == heading &&
      other.headingOffset == headingOffset &&
      other.hasOrigin == hasOrigin;

  @override
  int get hashCode =>
      Object.hash(points, camX, camY, heading, headingOffset, hasOrigin);
}
