import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/hud_models.dart';

/// A compact, top-center pill that displays the current survey stage and mood.
class GuidancePill extends StatelessWidget {
  const GuidancePill({
    super.key,
    required this.stage,
    required this.tone,
    this.customInstruction,
  });

  final SurveyStage stage;
  final SurveyTone tone;
  final String? customInstruction;

  @override
  Widget build(BuildContext context) {
    final color = surveyToneColor(tone);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusDot(color),
          const SizedBox(width: 10),
          Text(
            (customInstruction ?? _getStageLabel(stage)).toUpperCase(),
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.6),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  String _getStageLabel(SurveyStage stage) {
    switch (stage) {
      case SurveyStage.idle:
        return 'Idle';
      case SurveyStage.calibration:
        return 'Calibrating Sensors';
      case SurveyStage.coverageSweep:
        return 'Mapping Signal';
      case SurveyStage.weakZoneReview:
        return 'Scanning Weak Zones';
      case SurveyStage.wrapUp:
        return 'Ready to Finish';
      case SurveyStage.review:
        return 'Reviewing';
    }
  }
}
