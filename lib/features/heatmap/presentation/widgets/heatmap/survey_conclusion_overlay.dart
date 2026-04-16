import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap/heatmap_page_models.dart';

class SurveyConclusionOverlay extends StatelessWidget {
  const SurveyConclusionOverlay({
    super.key,
    required this.summary,
    required this.copy,
    required this.onRestart,
    required this.onDone,
    required this.onRename,
    required this.onShare,
  });

  /// Chrome height reserved by the overlay (excluding bottom safe area).
  static const double reservedHeight = 300;

  final HeatmapSummary summary;
  final HeatmapCopy copy;
  final VoidCallback onRestart;
  final VoidCallback onDone;
  final VoidCallback onRename;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.72),
                Colors.black.withValues(alpha: 0.94),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: AppColors.neonCyan.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.12),
                blurRadius: 32,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.neonCyan.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.neonCyan,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          copy.surveyCompleteTitle.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.orbitron(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${summary.coveragePercent} · ${summary.sampleCount} ${copy.samplesShort}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _IconAction(
                    icon: Icons.edit_rounded,
                    onTap: onRename,
                    tooltip: copy.renameSurvey,
                  ),
                  const SizedBox(width: 6),
                  _IconAction(
                    icon: Icons.ios_share_rounded,
                    onTap: onShare,
                    tooltip: copy.shareHeatmap,
                  ),
                  const SizedBox(width: 6),
                  _IconAction(
                    icon: Icons.refresh_rounded,
                    onTap: onRestart,
                    tooltip: copy.restartSurvey,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: copy.coverageLabel,
                      value: summary.coveragePercent,
                      color: summary.coverageColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStat(
                      label: copy.samplesLabel,
                      value: summary.sampleCount.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStat(
                      label: copy.blindSpotsLabel,
                      value: summary.weakZoneCount.toString(),
                      color: summary.weakZoneCount > 0
                          ? AppColors.neonRed
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              NeonButton(
                onPressed: onDone,
                label: copy.finishAndSave,
                icon: Icons.check_circle_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.orbitron(
              color: AppColors.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              color: accent,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ),
            child: Icon(icon, size: 16, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
