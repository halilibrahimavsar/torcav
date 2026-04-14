import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/core/theme/app_theme.dart';
import '../../../domain/entities/survey_gate.dart';
import '../../bloc/heatmap_bloc.dart';
import 'hud_models.dart';

/// Critical status banner shown at the bottom when recording is blocked by a gate.
class MeasurementLockBanner extends StatelessWidget {
  const MeasurementLockBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, GateSlice>(
      selector:
          (s) => GateSlice(
            gate: s.surveyGate,
            targetBssid: s.targetBssid,
            targetSsid: s.targetSsid,
          ),
      builder: (context, slice) {
        if (slice.gate == SurveyGate.none) {
          return const SizedBox.shrink();
        }

        final (title, body, color, icon) = switch (slice.gate) {
          SurveyGate.noConnectedBssid => (
            'MEASUREMENT LOCKED',
            slice.targetBssid == null
                ? 'Connect to a Wi-Fi network to lock the survey target.'
                : 'Reconnect to ${compactBssid(slice.targetBssid!)} to resume sampling.',
            AppColors.neonRed,
            Icons.link_off_rounded,
          ),
          SurveyGate.staleSignal => (
            'WAITING FOR FRESH SIGNAL',
            'RSSI is older than 3 seconds. Walk briefly or hold position for a new scan.',
            AppColors.neonOrange,
            Icons.hourglass_top_rounded,
          ),
          SurveyGate.weakSignal => (
            'SIGNAL DROPPED',
            'Wi-Fi signal is below -85dBm. Move closer to the Access Point.',
            AppColors.neonRed,
            Icons.signal_wifi_bad_rounded,
          ),
          SurveyGate.pdrDrift => (
            'COMPASS DRIFT DETECTED',
            'Magnetic interference found. Walk in a figure-8 or tap Realign.',
            AppColors.neonYellow,
            Icons.compass_calibration_rounded,
          ),
          SurveyGate.originNotPlaced => (
            'PLACE SURVEY ORIGIN',
            'Tap a detected plane to anchor the AR survey before recording points.',
            AppColors.neonCyan,
            Icons.gps_fixed_rounded,
          ),
          SurveyGate.trackingLost => (
            'TRACKING LOST',
            'Motion tracking is unavailable. Move slowly until tracking returns.',
            AppColors.neonOrange,
            Icons.route_rounded,
          ),
          SurveyGate.none => (
            '',
            '',
            AppColors.neonGreen,
            Icons.check_circle_outline_rounded,
          ),
        };

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.orbitron(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
