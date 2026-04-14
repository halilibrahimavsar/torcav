import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap/heatmap_page_models.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap/heatmap_utility_widgets.dart';

class SurveyConclusionOverlay extends StatelessWidget {
  const SurveyConclusionOverlay({
    super.key,
    required this.summary,
    required this.copy,
    required this.onRestart,
    required this.onDone,
  });

  final HeatmapSummary summary;
  final HeatmapCopy copy;
  final VoidCallback onRestart;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.15),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.neonCyan,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            copy.surveyCompleteTitle.toUpperCase(),
            style: GoogleFonts.orbitron(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            copy.surveyCompleteBody,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: StatBrick(
                  label: copy.coverageLabel,
                  value: summary.coveragePercent,
                  color: summary.coverageColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatBrick(
                  label: copy.samplesLabel,
                  value: summary.sampleCount.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatBrick(
                  label: copy.wallsLabel,
                  value: summary.wallCount.toString(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatBrick(
                  label: copy.blindSpotsLabel,
                  value: summary.weakZoneCount.toString(),
                  color: AppColors.neonRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              NeonButton(
                onPressed: onDone,
                label: copy.finishAndSave,
                icon: Icons.save_rounded,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.refresh_rounded, color: AppColors.textMuted),
                label: Text(
                  copy.restartSurvey,
                  style: GoogleFonts.orbitron(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
