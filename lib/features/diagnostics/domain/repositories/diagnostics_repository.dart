import '../entities/diagnosis_inputs.dart';

/// Progress label emitted as the repository walks through its probes.
enum DiagnosticsStep { signal, channel, speedTest, dns, finalize }

class DiagnosticsProgress {
  final DiagnosticsStep step;
  final double progress; // 0..1
  final DiagnosisInputs? partialInputs;

  const DiagnosticsProgress({
    required this.step,
    required this.progress,
    this.partialInputs,
  });
}

abstract class DiagnosticsRepository {
  /// Runs every probe and emits progress updates. Last event always carries
  /// the fully-populated [DiagnosisInputs] (with nullable fields where a
  /// probe failed) on a `finalize` step.
  Stream<DiagnosticsProgress> collectInputs();
}
