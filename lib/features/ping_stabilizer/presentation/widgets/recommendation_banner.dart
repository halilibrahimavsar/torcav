import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/stabilizer_recommendation.dart';
import '../bloc/ping_stabilizer_cubit.dart';
import '../bloc/ping_stabilizer_state.dart';

class RecommendationBanner extends StatelessWidget {
  const RecommendationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PingStabilizerCubit, PingStabilizerState>(
      builder: (context, state) {
        if (state.recommendations.isEmpty) return const SizedBox.shrink();
        return Column(
          children: state.recommendations.map((r) {
            final color = switch (r.severity) {
              RecommendationSeverity.info => Colors.blueAccent,
              RecommendationSeverity.warning => Colors.orangeAccent,
              RecommendationSeverity.critical => Colors.redAccent,
            };
            return Card(
              color: color.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: color.withValues(alpha: 0.4)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.message),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => context
                              .read<PingStabilizerCubit>()
                              .dismissRecommendation(r),
                          child: const Text('Dismiss'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => context
                              .read<PingStabilizerCubit>()
                              .acceptRecommendation(r),
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
