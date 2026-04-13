import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';

/// Top bar indicator with pulsing "REC" and the current point count.
class RecordingStatus extends StatefulWidget {
  const RecordingStatus({super.key});

  @override
  State<RecordingStatus> createState() => _RecordingStatusState();
}

class _RecordingStatusState extends State<RecordingStatus>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtl;

  @override
  void initState() {
    super.initState();
    _pulseCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, int>(
      selector: (s) => s.currentSession?.points.length ?? 0,
      builder: (context, count) {
        return GlassmorphicContainer(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          borderRadius: BorderRadius.circular(18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _pulseCtl,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.neonRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonRed,
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'REC',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 12, color: Colors.white24),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: GoogleFonts.orbitron(
                  color: AppColors.neonCyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'PTS',
                style: GoogleFonts.orbitron(
                  color: Colors.white54,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
