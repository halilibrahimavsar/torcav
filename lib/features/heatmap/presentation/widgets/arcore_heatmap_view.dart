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
  const ArCoreHeatmapView({
    super.key,
    this.onExpand,
    this.onCollapse,
    this.immersive = false,
  });

  final VoidCallback? onExpand;
  final VoidCallback? onCollapse;
  final bool immersive;

  @override
  State<ArCoreHeatmapView> createState() => _ArCoreHeatmapViewState();
}

class _ArCoreHeatmapViewState extends State<ArCoreHeatmapView> {
  static const _guidanceService = SurveyGuidanceService();
  static const _originNodeName = 'survey_origin';

  ArCoreController? _arCoreController;
  int _renderedPointCount = 0;
  final Set<String> _renderedFlagKeys = <String>{};
  bool _originAttached = false;
  vector.Vector3? _originWorldPos;

  @override
  void dispose() {
    _arCoreController?.dispose();
    super.dispose();
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    _arCoreController = controller;
    controller.onPlaneTap = _handlePlaneTap;
    controller.onPlaneDetected = _handlePlaneDetected;
    _renderedPointCount = 0;
    _renderedFlagKeys.clear();
    _originAttached = false;
    _originWorldPos = null;
    if (context.read<HeatmapBloc>().state.hasArOrigin) {
      context.read<HeatmapBloc>().resetArOrigin();
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
              'Origin anchored — tap to record points',
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
    final cx = centerPose.translation.x;
    final cz = centerPose.translation.z;

    // Convert world endpoints to floor coordinates relative to origin.
    final floorSegment = WallSegment(
      x1: (cx - wallDir.x * halfLen) - _originWorldPos!.x,
      y1: -((cz - wallDir.z * halfLen) - _originWorldPos!.z),
      x2: (cx + wallDir.x * halfLen) - _originWorldPos!.x,
      y2: -((cz + wallDir.z * halfLen) - _originWorldPos!.z),
    );

    context.read<HeatmapBloc>().addWallFromAr(floorSegment);
  }

  /// Adds a single flat disc marker on the AR floor for [point].
  ///
  /// ArCoreCylinder bug: `toMap()` swaps `radius` and `height` before sending
  /// to native. To get native radius=R and height=H, pass `radius: H, height: R`.
  Future<void> _addFloorMarker(HeatmapPoint point) async {
    if (_arCoreController == null || !_originAttached) return;

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
    if (_arCoreController == null || !_originAttached) return;
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

    final newPoints = points.skip(_renderedPointCount).toList();
    if (newPoints.isNotEmpty) {
      // Add all new floor markers in parallel — ARCore handles concurrency internally.
      await Future.wait(newPoints.map(_addFloorMarker));
      _renderedPointCount = points.length;
    }

    // Sync any newly flagged points (flag may be set after marker creation).
    await Future.wait(
      points.where((p) => p.isFlagged).map(_addFlagMarker),
    );
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
        await _syncAnchoredNodes(state.currentSession?.points ?? const []);
      },
      builder: (context, state) {
        final guidance = _guidanceService.analyze(
          points: state.currentSession?.points ?? const [],
          floorPlan: state.liveFloorPlan,
          isRecording: state.isRecording,
          isArViewEnabled: state.isArViewEnabled,
          hasArOrigin: state.hasArOrigin,
          pendingWallCount: state.pendingWalls.length,
          currentRssi: state.currentRssi,
          surveyGate: state.surveyGate,
          lastSignalAt: state.lastSignalAt,
          currentSignalStdDev: state.lastSignalStdDev,
          currentX: state.currentPosition?.dx,
          currentY: state.currentPosition?.dy,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            ArCoreView(
              onArCoreViewCreated: _onArCoreViewCreated,
              enableTapRecognizer: true,
            ),
            // dBm label overlay — screen-space projections of floor markers.
            if (state.phase == ScanPhase.scanning)
              const IgnorePointer(child: _SignalLabelOverlay()),
            if (state.phase == ScanPhase.scanning)
              ArHudOverlay(
                guidance: guidance,
                immersive: widget.immersive,
                onExpand: widget.onExpand,
                onCollapse: widget.onCollapse,
                onFlagWeakZone: _flagCurrentPosition,
              ),
          ],
        );
      },
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
      selector: (s) => _LabelOverlaySlice(
        points: s.currentSession?.points ?? const [],
        camX: s.currentPosition?.dx ?? 0,
        camY: s.currentPosition?.dy ?? 0,
        heading: s.currentHeading,
        headingOffset: s.arOriginHeadingOffset,
        hasOrigin: s.hasArOrigin,
      ),
      builder: (context, slice) {
        if (!slice.hasOrigin || slice.points.isEmpty) {
          return const SizedBox.shrink();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final labels = <Widget>[];

            for (final point in slice.points) {
              final screen = _projectToScreen(
                point,
                slice.camX,
                slice.camY,
                slice.heading - slice.headingOffset,
                size,
              );
              if (screen == null) continue;

              final color = signalGradientColor(point.rssi);
              labels.add(
                Positioned(
                  left: screen.dx,
                  top: screen.dy,
                  child: FractionalTranslation(
                    // Anchor the bottom-center of the label to the projected point.
                    translation: const Offset(-0.5, -1.0),
                    child: _DbmPill(rssi: point.rssi, color: color),
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
  ///
  /// PDR coordinate system: heading=0° → camera faces +X axis.
  /// Camera forward vector = (cos θ, sin θ).
  /// Camera right vector  = (−sin θ, cos θ).
  ///
  /// Returns null if the point is behind the camera, too close, too far, or
  /// outside the horizontal field of view.
  static Offset? _projectToScreen(
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
    final depth =
        dx * math.cos(headingRad) + dy * math.sin(headingRad);
    // Lateral: how far the point is to the right of the camera.
    final lateral =
        -dx * math.sin(headingRad) + dy * math.cos(headingRad);

    if (depth < 0.4 || depth > 7.0) return null;

    const hFovRad = 60.0 * math.pi / 180.0;
    final focalPx = screenSize.width / (2 * math.tan(hFovRad / 2));

    final screenX = screenSize.width / 2 + (lateral / depth) * focalPx;
    if (screenX < -40 || screenX > screenSize.width + 40) return null;

    // Vertical position: farther points appear closer to horizon (higher).
    final t = ((depth - 0.4) / 6.6).clamp(0.0, 1.0);
    final screenY = screenSize.height * (0.82 - t * 0.38);

    return Offset(screenX, screenY);
  }
}

class _DbmPill extends StatelessWidget {
  const _DbmPill({required this.rssi, required this.color});

  final int rssi;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.waves_rounded, color: color, size: 10),
          const SizedBox(width: 4),
          Text(
            '$rssi dBm',
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
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
