import 'package:equatable/equatable.dart';

/// Verdict buckets for the paying-vs-getting comparison.
///
/// Thresholds follow the Speed Doctor explainer's guidance that a healthy
/// link should deliver ~80% of the plan on a good day.
enum PlanVerdict { noData, delivering, acceptable, underDelivering }

/// Snapshot of "what the user pays for vs what the tests measured".
class PlanComparison extends Equatable {
  final double planMbps;
  final double avgDownloadMbps;
  final double bestDownloadMbps;
  final int sampleCount;
  final DateTime? lastSampleAt;

  /// Download speeds of the compared samples, oldest → newest, for the
  /// trend sparkline.
  final List<double> recentDownloadsMbps;

  const PlanComparison({
    required this.planMbps,
    required this.avgDownloadMbps,
    required this.bestDownloadMbps,
    required this.sampleCount,
    this.lastSampleAt,
    this.recentDownloadsMbps = const [],
  });

  /// 0..∞ share of the promised speed the average test actually reached.
  double get deliveredRatio =>
      planMbps <= 0 || sampleCount == 0 ? 0 : avgDownloadMbps / planMbps;

  PlanVerdict get verdict {
    if (sampleCount == 0) return PlanVerdict.noData;
    if (deliveredRatio >= 0.8) return PlanVerdict.delivering;
    if (deliveredRatio >= 0.5) return PlanVerdict.acceptable;
    return PlanVerdict.underDelivering;
  }

  @override
  List<Object?> get props => [
    planMbps,
    avgDownloadMbps,
    bestDownloadMbps,
    sampleCount,
    lastSampleAt,
    recentDownloadsMbps,
  ];
}
