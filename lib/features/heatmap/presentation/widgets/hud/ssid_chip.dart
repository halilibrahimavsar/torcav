import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/core/theme/neon_widgets.dart';
import 'package:torcav/features/heatmap/domain/entities/survey_gate.dart';
import 'package:torcav/features/heatmap/domain/services/signal_tier.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';
import 'hud_models.dart';

/// Top-left SSID/BSSID indicator with signal tier coloring.
class SsidChip extends StatelessWidget {
  const SsidChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, SsidSlice>(
      selector: (s) {
        return SsidSlice(
          ssid: s.targetSsid ?? '',
          bssid: s.targetBssid ?? '',
          rssi: s.currentRssi,
          locked: s.surveyGate == SurveyGate.none,
        );
      },
      builder: (context, slice) {
        final tier = signalTierFor(slice.rssi);
        final color = signalTierColor(tier);
        return GlassmorphicContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: BorderRadius.circular(18),
          borderColor: color,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_rounded, color: color, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slice.ssid.isEmpty
                          ? 'LIVE WI-FI'
                          : slice.ssid.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      slice.bssid.isEmpty
                          ? signalTierLabel(tier)
                          : '${slice.locked ? 'LOCK' : 'HOLD'} ${compactBssid(slice.bssid)}',
                      style: GoogleFonts.outfit(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
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
