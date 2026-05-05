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
  final String metricLabel;
  final String thresholdLabel;
  final List<DiagnosticAction> actions;

  const DiagnosisEvidence({
    required this.category,
    required this.severity,
    required this.metricLabel,
    required this.thresholdLabel,
    this.actions = const [],
  });

  @override
  List<Object?> get props => [
    category,
    severity,
    metricLabel,
    thresholdLabel,
    actions,
  ];
}
