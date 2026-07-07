import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/performance/domain/entities/isp_evidence_labels.dart';
import 'package:torcav/features/performance/domain/entities/plan_comparison.dart';
import 'package:torcav/features/performance/domain/entities/speed_test_result.dart';
import 'package:torcav/features/performance/domain/services/isp_evidence_composer.dart';

const _labels = IspEvidenceLabels(
  title: 'TORCAV — EVIDENCE',
  generatedAtLabel: 'Generated',
  planLabel: 'Plan',
  averageLabel: 'Average',
  bestLabel: 'Best',
  percentOfPlan: '42% of plan',
  samplesHeader: 'Measurements',
  disclaimer: 'Note: measured over Wi-Fi.',
);

void main() {
  test('composes a readable evidence text with all sections', () {
    const composer = IspEvidenceComposer();
    final text = composer.compose(
      comparison: const PlanComparison(
        planMbps: 100,
        avgDownloadMbps: 42.3,
        bestDownloadMbps: 55.1,
        sampleCount: 2,
      ),
      samples: [
        SpeedTestResult(
          recordedAt: DateTime(2026, 7, 7, 14, 20),
          latencyMs: 32,
          jitterMs: 4,
          downloadMbps: 41.2,
          uploadMbps: 8.1,
        ),
        SpeedTestResult(
          recordedAt: DateTime(2026, 7, 6, 9, 5),
          latencyMs: 28,
          jitterMs: 3,
          downloadMbps: 43.4,
          uploadMbps: 8.4,
        ),
      ],
      labels: _labels,
      now: DateTime(2026, 7, 7, 15),
    );

    expect(text, contains('TORCAV — EVIDENCE'));
    expect(text, contains('Generated: 2026-07-07 15:00'));
    expect(text, contains('Plan: 100 Mbps'));
    expect(text, contains('Average: 42.3 Mbps (42% of plan)'));
    expect(text, contains('Best: 55.1 Mbps'));
    expect(text, contains('- 2026-07-07 14:20 — ↓ 41.2 Mbps / ↑ 8.1 Mbps / 32 ms'));
    expect(text, contains('Note: measured over Wi-Fi.'));
  });
}
