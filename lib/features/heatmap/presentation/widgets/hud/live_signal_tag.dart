import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import '../../../domain/services/signal_tier.dart';
import '../../../domain/entities/survey_gate.dart';
import '../../bloc/heatmap_bloc.dart';
import 'hud_models.dart';

/// Floating diagnostic data centered at the bottom of the AR view.
class LiveSignalTag extends StatefulWidget {
  const LiveSignalTag({super.key, required this.estimatedMode});

  final bool estimatedMode;

  @override
  State<LiveSignalTag> createState() => _LiveSignalTagState();
}

class _LiveSignalTagState extends State<LiveSignalTag> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, SignalSlice>(
      selector:
          (s) => SignalSlice(
            rssi: s.currentRssi,
            stdDev: s.lastSignalStdDev,
            sampleCount: s.lastSignalSampleCount,
            ageSeconds: null,
            surveyGate: s.surveyGate,
          ),
      builder: (context, slice) {
        if (slice.rssi == null) return const SizedBox.shrink();

        final lastSignalAt =
            context.select<HeatmapBloc, DateTime?>((b) => b.state.lastSignalAt);
        final ageSeconds =
            lastSignalAt == null
                ? null
                : DateTime.now().difference(lastSignalAt).inSeconds;

        final tier = signalTierFor(slice.rssi);
        final color = signalTierColor(tier);

        return GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: GlassmorphicContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            borderRadius: BorderRadius.circular(24),
            borderColor: color.withValues(alpha: 0.6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SignalIcon(rssi: slice.rssi!, color: color),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${slice.rssi}',
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      signalTierLabel(tier).toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    if (_expanded) ...[
                      const SizedBox(height: 4),
                      Text(
                        'STD ${slice.stdDev.toStringAsFixed(1)} · ${slice.sampleCount} samp · ${ageSeconds ?? '-'}s',
                        style: GoogleFonts.outfit(
                          color: Colors.white60,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: 16),
                Container(width: 1, height: 30, color: Colors.white24),
                const SizedBox(width: 16),
                _ArStatusIndicator(
                  gate: slice.surveyGate,
                  estimatedMode: widget.estimatedMode,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SignalIcon extends StatelessWidget {
  const _SignalIcon({required this.rssi, required this.color});

  final int rssi;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PulsingDot(color: color, size: 36),
        Icon(Icons.wifi_rounded, color: Colors.white, size: 18),
      ],
    );
  }
}

class _ArStatusIndicator extends StatelessWidget {
  const _ArStatusIndicator({
    required this.gate,
    required this.estimatedMode,
  });

  final SurveyGate gate;
  final bool estimatedMode;

  @override
  Widget build(BuildContext context) {
    final statusColor = gate == SurveyGate.none
        ? (estimatedMode ? AppColors.neonYellow : AppColors.neonGreen)
        : AppColors.neonRed;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          estimatedMode ? Icons.auto_awesome_rounded : Icons.precision_manufacturing_rounded,
          color: statusColor,
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          estimatedMode ? 'ESTIMATED' : 'PRECISE',
          style: GoogleFonts.orbitron(
            color: statusColor,
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
