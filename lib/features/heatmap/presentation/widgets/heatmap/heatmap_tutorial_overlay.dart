import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap/heatmap_page_models.dart';

class HeatmapTutorialOverlay extends StatelessWidget {
  const HeatmapTutorialOverlay({
    super.key,
    required this.copy,
    required this.onDismiss,
  });

  final HeatmapCopy copy;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.black.withValues(alpha: 0.82),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonCyan.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  color: AppColors.neonCyan,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              NeonText(
                copy.tutorialTitle,
                style: GoogleFonts.orbitron(
                  color: AppColors.neonCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
                glowColor: AppColors.neonCyan,
                glowRadius: 8,
              ),
              const SizedBox(height: 28),
              _TutorialStep(number: '1', text: copy.tutorialStep1),
              const SizedBox(height: 16),
              _TutorialStep(number: '2', text: copy.tutorialStep2),
              const SizedBox(height: 16),
              _TutorialStep(number: '3', text: copy.tutorialStep3),
              const SizedBox(height: 16),
              _TutorialStep(number: '4', text: copy.tutorialStep4),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan.withValues(alpha: 0.15),
                    foregroundColor: AppColors.neonCyan,
                    side: BorderSide(
                      color: AppColors.neonCyan.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.gotIt,
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialStep extends StatelessWidget {
  const _TutorialStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.neonCyan.withValues(alpha: 0.15),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.4),
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.orbitron(
                color: AppColors.neonCyan,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.rajdhani(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
