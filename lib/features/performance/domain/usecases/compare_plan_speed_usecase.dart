import 'package:injectable/injectable.dart';

import '../../../settings/domain/services/app_settings_store.dart';
import '../entities/plan_comparison.dart';
import '../repositories/speed_test_history_repository.dart';

/// Builds the paying-vs-getting snapshot from the declared plan speed and
/// the most recent speed test results.
///
/// Returns null when the user has not declared a plan speed yet — the UI
/// then shows the "enter your plan" call to action instead of a comparison.
@lazySingleton
class ComparePlanSpeedUseCase {
  final SpeedTestHistoryRepository _history;
  final AppSettingsStore _settings;

  ComparePlanSpeedUseCase(this._history, this._settings);

  Future<PlanComparison?> call({int sampleLimit = 10}) async {
    final plan = _settings.value.planDownloadMbps;
    if (plan == null || plan <= 0) return null;

    final recent = await _history.getRecent(limit: sampleLimit);
    if (recent.isEmpty) {
      return PlanComparison(
        planMbps: plan,
        avgDownloadMbps: 0,
        bestDownloadMbps: 0,
        sampleCount: 0,
      );
    }

    var sum = 0.0;
    var best = 0.0;
    for (final result in recent) {
      sum += result.downloadMbps;
      if (result.downloadMbps > best) best = result.downloadMbps;
    }

    return PlanComparison(
      planMbps: plan,
      avgDownloadMbps: sum / recent.length,
      bestDownloadMbps: best,
      sampleCount: recent.length,
      lastSampleAt: recent.first.recordedAt,
      // getRecent returns newest-first; the sparkline wants oldest → newest.
      recentDownloadsMbps: [
        for (final result in recent.reversed) result.downloadMbps,
      ],
    );
  }
}
