import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/repositories/diagnostics_repository.dart';

class ProgressSteps extends StatelessWidget {
  const ProgressSteps({
    super.key,
    required this.currentStep,
    required this.progress,
  });

  final DiagnosticsStep? currentStep;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1).toDouble(),
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.4),
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        for (final step in DiagnosticsStep.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(
                  _isComplete(step) ? Icons.check_circle_rounded
                      : _isCurrent(step) ? Icons.timelapse_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: _isComplete(step)
                      ? Colors.greenAccent
                      : _isCurrent(step)
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  _label(step),
                  style: GoogleFonts.rajdhani(
                    color: _isCurrent(step) || _isComplete(step)
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: _isCurrent(step)
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  bool _isCurrent(DiagnosticsStep step) => step == currentStep;

  bool _isComplete(DiagnosticsStep step) {
    if (currentStep == null) return false;
    return step.index < currentStep!.index;
  }

  String _label(DiagnosticsStep step) => switch (step) {
    DiagnosticsStep.signal => 'Reading signal',
    DiagnosticsStep.channel => 'Analysing channels',
    DiagnosticsStep.speedTest => 'Measuring speed',
    DiagnosticsStep.dns => 'Benchmarking DNS',
    DiagnosticsStep.finalize => 'Finalising diagnosis',
  };
}
