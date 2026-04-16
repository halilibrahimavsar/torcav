import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';
import 'package:torcav/features/heatmap/presentation/bloc/scan_phase.dart';

import 'package:torcav/features/heatmap/presentation/widgets/ar_hud_overlay.dart';
import 'package:torcav/features/heatmap/presentation/widgets/ar_scene_view.dart';

/// Hosts the native ARCore SceneView and layers the shared survey HUD on top.
class ArCameraView extends StatelessWidget {
  const ArCameraView({
    super.key,
    this.onFinish,
    this.onDiscard,
  });

  final VoidCallback? onFinish;
  final VoidCallback? onDiscard;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, ScanPhase>(
      selector: (s) => s.phase,
      builder: (context, phase) {
        return Stack(
          fit: StackFit.expand,
          children: [
            const ArSceneView(),
            const IgnorePointer(child: _CameraVignette()),
            if (phase == ScanPhase.scanning)
              ArHudOverlay(
                onFinish: onFinish,
                onDiscard: onDiscard,
              ),
          ],
        );
      },
    );
  }
}

class _CameraVignette extends StatelessWidget {
  const _CameraVignette();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.darkSurface.withValues(alpha: 0.28),
            Colors.transparent,
            Colors.transparent,
            AppColors.darkSurface.withValues(alpha: 0.36),
          ],
        ),
      ),
    );
  }
}
