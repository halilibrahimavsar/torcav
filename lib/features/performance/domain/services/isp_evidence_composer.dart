import 'package:injectable/injectable.dart';

import '../entities/isp_evidence_labels.dart';
import '../entities/plan_comparison.dart';
import '../entities/speed_test_result.dart';

/// Composes the plain-text "ödediğin vs aldığın" evidence the user can
/// paste into an e-mail or support chat with their ISP.
///
/// Text (not PDF) on purpose: every support channel accepts it, and the
/// user can read exactly what leaves the device before sharing it. No
/// identifiers beyond the measurements are included.
@lazySingleton
class IspEvidenceComposer {
  const IspEvidenceComposer();

  String compose({
    required PlanComparison comparison,
    required List<SpeedTestResult> samples,
    required IspEvidenceLabels labels,
    DateTime? now,
  }) {
    final buffer = StringBuffer();
    final generatedAt = now ?? DateTime.now();

    buffer.writeln(labels.title);
    buffer.writeln('${labels.generatedAtLabel}: ${_stamp(generatedAt)}');
    buffer.writeln();
    buffer.writeln(
      '${labels.planLabel}: '
      '${_mbps(comparison.planMbps)} Mbps',
    );
    buffer.writeln(
      '${labels.averageLabel}: '
      '${_mbps(comparison.avgDownloadMbps)} Mbps '
      '(${labels.percentOfPlan})',
    );
    buffer.writeln(
      '${labels.bestLabel}: ${_mbps(comparison.bestDownloadMbps)} Mbps',
    );
    buffer.writeln();
    buffer.writeln('${labels.samplesHeader}:');
    for (final sample in samples) {
      // Background probes have no upload leg (uploadMbps == 0); listing a
      // zero would misread as "upload broken", so it's skipped.
      final upload =
          sample.uploadMbps > 0
              ? '↑ ${_mbps(sample.uploadMbps)} Mbps / '
              : '';
      buffer.writeln(
        '- ${_stamp(sample.recordedAt)} — '
        '↓ ${_mbps(sample.downloadMbps)} Mbps / '
        '$upload'
        '${sample.latencyMs.round()} ms',
      );
    }
    buffer.writeln();
    buffer.writeln(labels.disclaimer);
    return buffer.toString();
  }

  String _mbps(double value) => value.toStringAsFixed(value >= 100 ? 0 : 1);

  String _stamp(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}:${two(t.minute)}';
  }
}
