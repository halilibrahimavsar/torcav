import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';

/// Celebration banner shown when survey conditions are fully met.
class ReadyBanner extends StatelessWidget {
  const ReadyBanner({super.key, required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final liveGreen = isLight ? AppColors.inkGreen : AppColors.neonGreen;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: controller.value,
          child: Transform.translate(
            offset: Offset(0, (1 - controller.value) * 20),
            child: child,
          ),
        );
      },
      child: NeonGlowBox(
        glowColor: liveGreen,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.read<HeatmapBloc>().stopScanning(),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color:
                    isLight
                        ? theme.colorScheme.surface.withValues(alpha: 0.95)
                        : Colors.black.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: liveGreen.withValues(alpha: isLight ? 0.35 : 0.6),
                  width: 1.4,
                ),
                boxShadow:
                    isLight
                        ? [
                          BoxShadow(
                            color: liveGreen.withValues(alpha: 0.15),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ]
                        : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: liveGreen,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'COVERAGE COMPLETE',
                          style: GoogleFonts.orbitron(
                            color: liveGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to finish scan',
                          style: GoogleFonts.outfit(
                            color:
                                isLight
                                    ? theme.colorScheme.onSurface
                                    : Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: liveGreen, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
