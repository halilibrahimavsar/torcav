import 'package:equatable/equatable.dart';

/// Localized strings for the ISP evidence text, passed in from the
/// presentation layer so the composer stays l10n-free (same pattern as
/// [ReportLabels] in the reports feature).
class IspEvidenceLabels extends Equatable {
  final String title;
  final String generatedAtLabel;
  final String planLabel;
  final String averageLabel;
  final String bestLabel;

  /// Fully formatted "X% of plan" text — the caller formats the percentage
  /// so this entity stays free of template tokens.
  final String percentOfPlan;
  final String samplesHeader;
  final String disclaimer;

  const IspEvidenceLabels({
    required this.title,
    required this.generatedAtLabel,
    required this.planLabel,
    required this.averageLabel,
    required this.bestLabel,
    required this.percentOfPlan,
    required this.samplesHeader,
    required this.disclaimer,
  });

  @override
  List<Object?> get props => [
    title,
    generatedAtLabel,
    planLabel,
    averageLabel,
    bestLabel,
    percentOfPlan,
    samplesHeader,
    disclaimer,
  ];
}
