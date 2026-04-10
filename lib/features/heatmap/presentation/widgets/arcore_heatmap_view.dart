import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    if (_arCoreController == null || hits.isEmpty || _originAttached) return;
    final hit = hits.first;
    final originNode = ArCoreNode(
      name: _originNodeName,
      position: hit.pose.translation,
      rotation: hit.pose.rotation,
      children: [
        ArCoreNode(
          name: 'survey_origin_marker',
          shape: ArCoreSphere(
            radius: 0.035,
            materials: [
              ArCoreMaterial(
                color: AppColors.neonCyan.withValues(alpha: 0.9),
                metallic: 0.8,
                reflectance: 0.8,
              ),
            ],
          ),
          position: vector.Vector3.zero(),
        ),
      ],
    );
    await _arCoreController!.addArCoreNodeWithAnchor(originNode);
    _originAttached = true;
    if (!mounted) return;
    context.read<HeatmapBloc>().markArOriginPlaced();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Survey origin anchored'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _addDiagnosticPillar(HeatmapPoint point) async {
    if (_arCoreController == null || !_originAttached) return;

    final pillarHeight = signalTierArHeight(point.rssi);
    final color = signalGradientColor(point.rssi);
    final pillarName = _pillarName(point);

    final pillarMaterial = ArCoreMaterial(
      color: color.withValues(alpha: 0.4),
      metallic: 0.5,
      reflectance: 0.2,
    );
    final cylinder = ArCoreCylinder(
      materials: [pillarMaterial],
      radius: 0.04,
      height: pillarHeight,
    );

    final pillarNode = ArCoreNode(
      name: '${pillarName}_body',
      shape: cylinder,
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

    await _arCoreController!.addArCoreNode(
      pillarNode,
      parentNodeName: _originNodeName,
    );
    await _arCoreController!.addArCoreNode(
      glowNode,
      parentNodeName: _originNodeName,
    );
  }

  Future<void> _addFlagMarker(HeatmapPoint point) async {
    if (_arCoreController == null || !_originAttached) return;
    final key = _flagKey(point);
    if (_renderedFlagKeys.contains(key)) return;

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
      position: vector.Vector3(point.floorX, point.floorZ + 0.2, -point.floorY),
    );

    await _arCoreController!.addArCoreNode(
      flagNode,
      parentNodeName: _originNodeName,
    );
    _renderedFlagKeys.add(key);
  }

  String _pillarName(HeatmapPoint point) =>
      'pillar_${point.timestamp.microsecondsSinceEpoch}';

  String _flagKey(HeatmapPoint point) =>
      '${point.timestamp.microsecondsSinceEpoch}_${point.floorX.toStringAsFixed(2)}_${point.floorY.toStringAsFixed(2)}';

  Future<void> _syncAnchoredNodes(List<HeatmapPoint> points) async {
    if (!_originAttached) return;

    for (final point in points.skip(_renderedPointCount)) {
      await _addDiagnosticPillar(point);
      if (point.isFlagged) {
        await _addFlagMarker(point);
      }
    }
    _renderedPointCount = points.length;

    for (final point in points.where((point) => point.isFlagged)) {
      await _addFlagMarker(point);
    }
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weak zone flagged'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.black87,
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
