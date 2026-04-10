import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/heatmap_point.dart';
import '../../domain/services/signal_tier.dart';
import '../../domain/services/survey_guidance_service.dart';
import '../bloc/heatmap_bloc.dart';
import '../bloc/scan_phase.dart';
import 'ar_hud_overlay.dart';

/// ARCore-backed heatmap view. Renders anchored diagnostic pillars in metric
/// world space and delegates the 2D HUD to [ArHudOverlay].
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

  @override
  void dispose() {
    _arCoreController?.dispose();
    super.dispose();
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    _arCoreController = controller;
    controller.onPlaneTap = _handlePlaneTap;
    _renderedPointCount = 0;
    _renderedFlagKeys.clear();
    _originAttached = false;
    if (context.read<HeatmapBloc>().state.hasArOrigin) {
      context.read<HeatmapBloc>().resetArOrigin();
    }
  }

  Future<void> _handlePlaneTap(List<ArCoreHitTestResult> hits) async {
    if (_arCoreController == null || hits.isEmpty) return;

    if (!_originAttached) {
      await _placeOrigin(hits.first);
      return;
    }

    // Post-origin tap: manually record a measurement point at current position.
    await _recordManualPoint();
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
        ArCoreNode(
          name: 'survey_origin_pad',
          shape: ArCoreCylinder(
            radius: 0.15,
            height: 0.005,
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
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    context.read<HeatmapBloc>().markArOriginPlaced();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.gps_fixed_rounded, color: AppColors.neonCyan, size: 16),
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

  Future<void> _recordManualPoint() async {
    final bloc = context.read<HeatmapBloc>();
    final s = bloc.state;
    if (s.currentRssi == null || s.currentPosition == null) return;

    HapticFeedback.mediumImpact();
    await bloc.addPoint(
      HeatmapPoint(
        x: 0,
        y: 0,
        floorX: s.currentPosition!.dx,
        floorY: s.currentPosition!.dy,
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
  }

  Future<void> _addDiagnosticPillar(HeatmapPoint point) async {
    if (_arCoreController == null || !_originAttached) return;

    final pillarHeight = signalTierArHeight(point.rssi);
    final color = signalGradientColor(point.rssi);
    final pillarName = _pillarName(point);

    final pillarNode = ArCoreNode(
      name: '${pillarName}_body',
      shape: ArCoreCylinder(
        materials: [
          ArCoreMaterial(
            color: color.withValues(alpha: 0.5),
            metallic: 0.7,
            reflectance: 0.55,
          ),
        ],
        radius: 0.05,
        height: pillarHeight,
      ),
      position: vector.Vector3(
        point.floorX,
        point.floorZ + pillarHeight / 2,
        -point.floorY,
      ),
    );

    final glowNode = ArCoreNode(
      name: '${pillarName}_glow',
      shape: ArCoreSphere(
        radius: 0.08,
        materials: [
          ArCoreMaterial(color: color, metallic: 1.0, reflectance: 1.0),
        ],
      ),
      position: vector.Vector3(
        point.floorX,
        point.floorZ + pillarHeight,
        -point.floorY,
      ),
    );

    // Ground halo disc — gives each pillar a sci-fi landing-ring effect.
    final baseDisc = ArCoreNode(
      name: '${pillarName}_base',
      shape: ArCoreCylinder(
        radius: 0.08,
        height: 0.012,
        materials: [
          ArCoreMaterial(
            color: color.withValues(alpha: 0.18),
            metallic: 0.6,
            reflectance: 0.4,
          ),
        ],
      ),
      position: vector.Vector3(
        point.floorX,
        point.floorZ + 0.006,
        -point.floorY,
      ),
    );

    await _arCoreController!.addArCoreNode(
      pillarNode,
      parentNodeName: _originNodeName,
    );
    await _arCoreController!.addArCoreNode(
      glowNode,
      parentNodeName: _originNodeName,
    );
    await _arCoreController!.addArCoreNode(
      baseDisc,
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

  String _pillarName(HeatmapPoint point) =>
      'pillar_${point.timestamp.microsecondsSinceEpoch}';

  String _flagKey(HeatmapPoint point) =>
      '${point.timestamp.microsecondsSinceEpoch}_${point.floorX.toStringAsFixed(2)}_${point.floorY.toStringAsFixed(2)}';

  Future<void> _syncAnchoredNodes(List<HeatmapPoint> points) async {
    if (!_originAttached || _arCoreController == null) return;

    final newPoints = points.skip(_renderedPointCount).toList();
    if (newPoints.isNotEmpty) {
      // Add all new pillars in parallel — ARCore handles concurrency internally.
      await Future.wait(newPoints.map(_addDiagnosticPillar));
      _renderedPointCount = points.length;
    }

    // Sync any newly flagged points (flag may be set after pillar creation).
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
            const Icon(Icons.warning_amber_rounded, color: AppColors.neonRed, size: 16),
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
        final prevFlags = prevPoints.where((point) => point.isFlagged).length;
        final currFlags = currPoints.where((point) => point.isFlagged).length;
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
