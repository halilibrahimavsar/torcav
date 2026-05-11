import 'package:equatable/equatable.dart';

import 'diagnostic_action.dart';
import 'root_cause_category.dart';

/// One per-category numeric finding.
///
/// [severity] is a normalised 0..1 value used to rank evidence; the highest
/// severity defines [DiagnosisResult.primaryCause].
class DiagnosisEvidence extends Equatable {
  final RootCauseCategory category;
  final double severity;

  /// Fallback label for display if [metricKey] is null.
  final String metricLabel;

  /// Fallback label for display if [thresholdKey] is null.
  final String thresholdLabel;

  final String? metricKey;
  final Map<String, dynamic>? metricParams;
  final String? thresholdKey;
  final Map<String, dynamic>? thresholdParams;

  final List<DiagnosticAction> actions;

  const DiagnosisEvidence({
    required this.category,
    required this.severity,
    this.metricLabel = '',
    this.thresholdLabel = '',
    this.metricKey,
    this.metricParams,
    this.thresholdKey,
    this.thresholdParams,
    this.actions = const [],
  });

  @override
  List<Object?> get props => [
        category,
        severity,
        metricLabel,
        thresholdLabel,
        metricKey,
        metricParams,
        thresholdKey,
        thresholdParams,
        actions,
      ];
}
