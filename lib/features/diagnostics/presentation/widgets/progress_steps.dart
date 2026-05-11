import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/repositories/diagnostics_repository.dart';
import '../../../../core/extensions/context_extensions.dart';

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
                  _isComplete(step)
                      ? Icons.check_circle_rounded
                      : _isCurrent(step)
                      ? Icons.timelapse_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color:
                      _isComplete(step)
                          ? Colors.greenAccent
                          : _isCurrent(step)
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  _label(context, step),
                  style: GoogleFonts.rajdhani(
                    color:
                        _isCurrent(step) || _isComplete(step)
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight:
                        _isCurrent(step) ? FontWeight.w700 : FontWeight.w500,
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

  String _label(BuildContext context, DiagnosticsStep step) {
    final l10n = context.l10n;
    return switch (step) {
      DiagnosticsStep.signal => l10n.diagStepReadingSignal,
      DiagnosticsStep.channel => l10n.diagStepAnalysingChannels,
      DiagnosticsStep.speedTest => l10n.diagStepMeasuringSpeed,
      DiagnosticsStep.dns => l10n.diagStepBenchmarkingDns,
      DiagnosticsStep.finalize => l10n.diagStepFinalizing,
    };
  }
}
