import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';

/// Bottom-left indicator showing total points and walls detected.
class SampleBadge extends StatelessWidget {
  const SampleBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, (int, int)>(
      selector:
          (s) => (
            s.currentSession?.points.length ?? 0,
            s.currentSession?.floorPlan?.walls.length ??
                s.liveFloorPlan?.walls.length ??
                0,
          ),
      builder: (context, stats) {
        final (points, walls) = stats;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeonChip(
              icon: Icons.sensors_rounded,
              label: '$points pts',
              color: AppColors.neonCyan,
            ),
            if (walls > 0) ...[
              const SizedBox(width: 8),
              NeonChip(
                icon: Icons.architecture_rounded,
                label: '$walls walls',
                color: AppColors.neonPurple,
              ),
            ],
          ],
        );
      },
    );
  }
}
