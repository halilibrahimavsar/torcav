import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';
import 'package:torcav/features/heatmap/presentation/widgets/mini_heatmap_map.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/hud_models.dart';

/// Mini-map overlay layer showing the current heatmap progress.
class MiniMapLayer extends StatelessWidget {
  const MiniMapLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, MiniMapSlice>(
      selector:
          (state) => MiniMapSlice(
            session: state.currentSession,
            currentPosition: state.currentPosition,
            currentHeading: state.currentHeading,
          ),
      builder: (context, slice) {
        if (slice.session == null) return const SizedBox.shrink();

        return MiniHeatmapMap(
          session: slice.session!,
          currentPosition: slice.currentPosition,
          currentHeading: slice.currentHeading,
          onTap: () {
            // Optional: Toggle full-screen map or expand
          },
        );
      },
    );
  }
}
