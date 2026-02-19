import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/heatmap_bloc.dart';

class TemporalHeatmapPage extends StatelessWidget {
  final String bssid;

  const TemporalHeatmapPage({super.key, required this.bssid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<HeatmapBloc>()..add(LoadHeatmap(bssid)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Temporal Heatmap')),
        body: BlocBuilder<HeatmapBloc, HeatmapState>(
          builder: (context, state) {
            if (state is HeatmapLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HeatmapLoaded) {
              final zones = state.zoneAverages;
              final onSurface = Theme.of(context).colorScheme.onSurface;
              if (zones.isEmpty) {
                return Center(
                  child: Text(
                    'No heatmap points yet for $bssid',
                    style: GoogleFonts.rajdhani(
                      color: onSurface.withValues(alpha: 0.82),
                      fontSize: 18,
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Average signal by zone',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...zones.entries.map((entry) {
                    final strength = entry.value;
                    final normalized = ((strength + 100) / 70).clamp(0.0, 1.0);
                    final color =
                        Color.lerp(
                          Colors.redAccent,
                          AppTheme.primaryColor,
                          normalized,
                        )!;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: GoogleFonts.orbitron(
                                color: onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '${strength.toStringAsFixed(1)} dBm',
                            style: GoogleFonts.rajdhani(
                              color: color,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            } else if (state is HeatmapError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
