import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/ping_stabilizer_cubit.dart';
import '../bloc/ping_stabilizer_state.dart';
import '../widgets/dns_picker_section.dart';
import '../widgets/live_jitter_chart.dart';
import '../widgets/profile_picker_section.dart';
import '../widgets/recommendation_banner.dart';
import '../widgets/stabilizer_explainer.dart';
import '../widgets/stabilizer_toggle_card.dart';

class PingStabilizerPage extends StatelessWidget {
  const PingStabilizerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PingStabilizerCubit>.value(
      value: GetIt.I<PingStabilizerCubit>()..bootstrap(),
      child: const _PingStabilizerView(),
    );
  }
}

class _PingStabilizerView extends StatelessWidget {
  const _PingStabilizerView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PING STABILIZER',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: scheme.primary,
          ),
        ),
      ),
      body: BlocBuilder<PingStabilizerCubit, PingStabilizerState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const StabilizerToggleCard(),
                const SizedBox(height: 12),
                const StabilizerExplainer(startCollapsed: true),
                const SizedBox(height: 16),
                if (state.errorMessage != null)
                  Card(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(state.errorMessage!),
                    ),
                  ),
                const RecommendationBanner(),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live latency',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        LiveJitterChart(stats: state.stats),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Stat(
                              label: 'Latency',
                              value: '${state.stats.ewmaLatencyMs.toStringAsFixed(0)} ms',
                            ),
                            _Stat(
                              label: 'Jitter',
                              value: '${state.stats.ewmaJitterMs.toStringAsFixed(1)} ms',
                            ),
                            _Stat(
                              label: 'Loss',
                              value: '${state.stats.lossPct.toStringAsFixed(1)}%',
                            ),
                          ],
                        ),
                        if (state.baselineLatencyMs != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Baseline (pre-tunnel): ${state.baselineLatencyMs} ms',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ProfilePickerSection(),
                        SizedBox(height: 16),
                        DnsPickerSection(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jitter alarm threshold: '
                          '${state.jitterThresholdMs.toStringAsFixed(0)} ms',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          min: 5,
                          max: 100,
                          value: state.jitterThresholdMs,
                          onChanged: (v) => context
                              .read<PingStabilizerCubit>()
                              .setJitterThreshold(v),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.shareTechMono(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
