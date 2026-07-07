import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/repositories/diagnostics_repository.dart';
import '../../../../core/extensions/context_extensions.dart';

class ProgressSteps extends StatefulWidget {
  const ProgressSteps({
    super.key,
    required this.currentStep,
    required this.progress,
  });

  final DiagnosticsStep? currentStep;
  final double progress;

  @override
  State<ProgressSteps> createState() => _ProgressStepsState();
}

class _ProgressStepsState extends State<ProgressSteps>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    // Aktif adım ikonunu sürekli döndür — çubuk yavaş ilerlerken bile
    // teşhisin çalıştığı görünür kalsın.
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (widget.progress.clamp(0, 1) * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: widget.progress.clamp(0, 1).toDouble()),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  builder:
                      (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        backgroundColor: theme
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.4),
                        color: theme.colorScheme.primary,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '%$pct',
              style: GoogleFonts.orbitron(
                color: theme.colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final step in DiagnosticsStep.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                if (_isCurrent(step))
                  RotationTransition(
                    turns: _spin,
                    child: Icon(
                      Icons.autorenew_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  )
                else
                  Icon(
                    _isComplete(step)
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color:
                        _isComplete(step)
                            ? Colors.greenAccent
                            : theme.colorScheme.onSurfaceVariant,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
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
                ),
                if (_isCurrent(step))
                  _RunningDots(color: theme.colorScheme.primary, spin: _spin),
              ],
            ),
          ),
      ],
    );
  }

  bool _isCurrent(DiagnosticsStep step) => step == widget.currentStep;

  bool _isComplete(DiagnosticsStep step) {
    if (widget.currentStep == null) return false;
    return step.index < widget.currentStep!.index;
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

/// Aktif adımın satır sonunda yumuşakça yanıp sönen üç nokta — "çalışıyor"
/// hissini metin tarafında da verir.
class _RunningDots extends StatelessWidget {
  const _RunningDots({required this.color, required this.spin});

  final Color color;
  final Animation<double> spin;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: spin,
      builder: (context, _) {
        final active = (spin.value * 3).floor() % 3;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: i == active ? 0.9 : 0.25),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
