import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/heatmap_bloc.dart';
import '../bloc/scan_phase.dart';

/// Screen-recording toggle used inside the AR HUD dock.
///
/// Returns an unpositioned Container so callers can place it in any layout
/// (e.g. a dock Column). Renders nothing when not in [ScanPhase.scanning].
class ScreenRecordButton extends StatelessWidget {
  const ScreenRecordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HeatmapBloc, HeatmapState>(
      buildWhen: (p, c) =>
          p.isScreenRecording != c.isScreenRecording || p.phase != c.phase,
      builder: (context, state) {
        if (state.phase != ScanPhase.scanning) {
          return const SizedBox.shrink();
        }

        final isRecording = state.isScreenRecording;

        return GestureDetector(
          onTap: () {
            if (isRecording) {
              context.read<HeatmapBloc>().stopScreenRecording();
            } else {
              context.read<HeatmapBloc>().startScreenRecording();
            }
          },
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isRecording
                  ? Colors.redAccent.withValues(alpha: 0.78)
                  : Colors.black.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: isRecording
                    ? Colors.redAccent
                    : AppColors.neonCyan.withValues(alpha: 0.55),
                width: 1.6,
              ),
              boxShadow: isRecording
                  ? [
                      BoxShadow(
                        color: Colors.redAccent.withValues(alpha: 0.42),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.neonCyan.withValues(alpha: 0.18),
                        blurRadius: 10,
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isRecording
                      ? CupertinoIcons.stop_circle_fill
                      : CupertinoIcons.videocam_circle_fill,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  isRecording ? 'STOP' : 'REC',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
