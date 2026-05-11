import 'package:equatable/equatable.dart';

/// User-facing explainer attached to each [RootCauseCategory] finding.
///
/// Built so the UI can render a "What is this? · Why it matters · How to
/// fix it · Estimated improvement" panel without holding category-specific
/// presentation logic.
class CategoryExplanation extends Equatable {
  /// Plain-language definition. One or two sentences.
  final String whatIs;

  /// User-impact framing — answers "why should I care?".
  final String whyItMatters;

  /// Ordered, action-first instructions. Each entry is a single sentence.
  final List<String> howToFix;

  /// Best-effort projection of the gain from applying the fix. Null when
  /// no input is reliable enough to project (e.g. unknown PHY rate).
  final String? estimatedImprovement;

  final String? whatIsKey;
  final String? whyItMattersKey;
  final List<String>? howToFixKeys;
  final String? estimatedImprovementKey;
  final Map<String, dynamic>? estimatedImprovementParams;

  const CategoryExplanation({
    this.whatIs = '',
    this.whyItMatters = '',
    this.howToFix = const [],
    this.estimatedImprovement,
    this.whatIsKey,
    this.whyItMattersKey,
    this.howToFixKeys,
    this.estimatedImprovementKey,
    this.estimatedImprovementParams,
  });

  @override
  List<Object?> get props => [
    whatIs,
    whyItMatters,
    howToFix,
    estimatedImprovement,
    whatIsKey,
    whyItMattersKey,
    howToFixKeys,
    estimatedImprovementKey,
    estimatedImprovementParams,
  ];
}
