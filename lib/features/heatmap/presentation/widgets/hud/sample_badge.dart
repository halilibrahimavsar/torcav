import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';

/// Bottom-left indicator showing total points recorded.
class SampleBadge extends StatelessWidget {
  const SampleBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, int>(
      selector: (s) => s.currentSession?.points.length ?? 0,
      builder: (context, points) {
        return NeonChip(
          icon: Icons.sensors_rounded,
          label: '$points pts',
          color: AppColors.neonCyan,
        );
      },
    );
  }
}
