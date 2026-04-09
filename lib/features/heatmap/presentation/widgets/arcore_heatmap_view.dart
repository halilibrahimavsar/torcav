import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import '../../../../core/theme/app_theme.dart';
import '../../domain/services/signal_tier.dart';
import '../../domain/services/survey_guidance_service.dart';
import '../bloc/heatmap_bloc.dart';
import '../bloc/scan_phase.dart';
import 'ar_hud_overlay.dart';

/// ARCore-backed heatmap view. Renders 3D RSSI spheres in metric world space
/// and delegates all 2D HUD information to [ArHudOverlay].
class ArCoreHeatmapView extends StatefulWidget {
  const ArCoreHeatmapView({
    super.key,
    this.onExpand,
    this.onCollapse,
    this.immersive = false,
  });

  /// Called when the user taps the dock's expand button (embedded mode only).
  final VoidCallback? onExpand;

  /// Called when the user taps the dock's collapse button (immersive mode only).
  final VoidCallback? onCollapse;

  /// True when hosted inside the expanded (pseudo-fullscreen) mode in [HeatmapPage].
  final bool immersive;

  @override
  State<ArCoreHeatmapView> createState() => _ArCoreHeatmapViewState();
}

class _ArCoreHeatmapViewState extends State<ArCoreHeatmapView> {
  static const _guidanceService = SurveyGuidanceService();

  ArCoreController? _arCoreController;

  @override
  void dispose() {
    _arCoreController?.dispose();
    super.dispose();
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    _arCoreController = controller;
  }

  void _addRssiSphere(double x, double y, double z, int rssi) {
    if (_arCoreController == null) return;

    final color = signalGradientColor(rssi);
    final material = ArCoreMaterial(
      color: color.withValues(alpha: 0.78),
      metallic: 0.8,
      reflectance: 1.0,
    );
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.15,
    );

    // ARCore axes: Y up, X right, Z toward camera.
    // HeatmapBloc provides floorX, floorY (walk plane) and floorZ (height).
    // Map: floorX → X, floorZ → Y, floorY → -Z.
    final node = ArCoreNode(
      shape: sphere,
      position: vector.Vector3(x, z, -y),
    );

    _arCoreController!.addArCoreNode(node);
  }

  /// Places a bright red flag sphere at the user's current metric position.
  /// v1 is visual-only — the HeatmapSession schema is not mutated.
  /// TODO(v2): persist flagged zones to HeatmapPoint.isFlagged + session DB.
  void _flagCurrentPosition() {
    if (_arCoreController == null) return;
    final state = context.read<HeatmapBloc>().state;
    final pos = state.currentPosition;
    if (pos == null) return;

    final material = ArCoreMaterial(
      color: AppColors.neonRed,
      metallic: 0.9,
      reflectance: 1.0,
    );
    final flag = ArCoreSphere(
      materials: [material],
      radius: 0.22,
    );
    _arCoreController!.addArCoreNode(
      ArCoreNode(
        shape: flag,
        position: vector.Vector3(pos.dx, 0.4, -pos.dy),
      ),
    );

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
        final prevSamples = previous.currentSession?.points.length ?? 0;
        final currSamples = current.currentSession?.points.length ?? 0;
        return currSamples > prevSamples &&
            current.currentSession!.points.isNotEmpty;
      },
      listener: (context, state) {
        final p = state.currentSession!.points.last;
        _addRssiSphere(p.floorX, p.floorY, p.floorZ, p.rssi);
      },
      builder: (context, state) {
        final guidance = _guidanceService.analyze(
          points: state.currentSession?.points ?? const [],
          floorPlan: state.liveFloorPlan,
          isRecording: state.isRecording,
          isArViewEnabled: state.isArViewEnabled,
          pendingWallCount: state.pendingWalls.length,
          currentRssi: state.currentRssi,
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
