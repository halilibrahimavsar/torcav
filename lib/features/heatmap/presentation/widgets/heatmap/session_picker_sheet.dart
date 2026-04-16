import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap/heatmap_page_models.dart';

class SessionPickerSheet extends StatelessWidget {
  const SessionPickerSheet({
    super.key,
    required this.sessions,
    required this.copy,
    required this.onSelect,
  });

  final List<HeatmapSession> sessions;
  final HeatmapCopy copy;
  final void Function(HeatmapSession) onSelect;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HeatmapBloc>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            copy.savedSurveysTitle,
            style: GoogleFonts.orbitron(
              color: AppColors.neonCyan,
              fontSize: 12,
              letterSpacing: 1.8,
            ),
          ),
        ),
        if (sessions.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                copy.noSavedSurveys,
                style: GoogleFonts.outfit(color: AppColors.textMuted),
              ),
            ),
          )
        else
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sessions.length,
              itemBuilder: (_, index) {
                final session = sessions[index];
                final summary = HeatmapSummary.from(
                  session: session,
                  currentRssi: null,
                );

                return ListTile(
                  leading: const Icon(
                    Icons.thermostat_rounded,
                    color: AppColors.neonCyan,
                  ),
                  title: Text(
                    session.name,
                    style: GoogleFonts.outfit(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    copy.savedSurveySubtitle(
                      summary.sampleCount,
                      summary.weakZoneCount,
                      _formatTimestamp(session.createdAt),
                    ),
                    style: GoogleFonts.outfit(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () => onSelect(session),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.neonRed,
                    ),
                    tooltip: copy.deleteSurveyTooltip,
                    onPressed: () => bloc.deleteSession(session.id),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _formatTimestamp(DateTime dt) =>
      '${dt.day}.${dt.month}.${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}
