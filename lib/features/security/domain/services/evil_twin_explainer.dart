import 'package:injectable/injectable.dart';

import '../entities/evil_twin_assessment.dart';

/// Lightweight summary returned by [EvilTwinExplainer]. The UI
/// (`evil_twin_detail_card.dart`) derives all user-facing copy directly
/// from the underlying [EvilTwinAssessment] via `l10n.*` keys and looks
/// at [confidenceLabel] only to pick a colour / icon / chip label.
class EvilTwinExplanation {
  /// One of: `Safe`, `Low`, `Medium`, `High`. Used as a discriminator
  /// in the UI for palette / icon / chip prefix.
  final String confidenceLabel;

  const EvilTwinExplanation({required this.confidenceLabel});
}

@lazySingleton
class EvilTwinExplainer {
  const EvilTwinExplainer();

  EvilTwinExplanation explain(EvilTwinAssessment assessment) {
    if (assessment.dismissedAsLegitimate) {
      return const EvilTwinExplanation(confidenceLabel: 'Safe');
    }
    if (!assessment.isCandidate) {
      return const EvilTwinExplanation(confidenceLabel: 'Low');
    }
    final c = assessment.confidence;
    return EvilTwinExplanation(
      confidenceLabel: c >= 0.75
          ? 'High'
          : c >= 0.6
              ? 'Medium'
              : 'Low',
    );
  }
}
