import 'package:equatable/equatable.dart';

import 'security_finding.dart';
import 'vulnerability.dart';

enum SecurityStatus { secure, moderate, atRisk, critical }

/// One reason this network scored the way it did.
///
/// A key rather than a sentence. The sentences used to be built here and
/// matched back by English prefix in the UI — which had already silently
/// broken for two of the thirteen factors, because the producer's wording and
/// the matcher's expected prefix had drifted apart.
class RiskFactor extends Equatable {
  const RiskFactor(this.key, {this.detail});

  /// Localization key; resolved by `RiskFactorLabels`.
  final String key;

  /// The variable part — a channel number, a router model, a drift list —
  /// appended after the localized sentence.
  final String? detail;

  @override
  List<Object?> get props => [key, detail];
}

class SecurityAssessment extends Equatable {
  final int score;
  final SecurityStatus status;
  final List<SecurityFinding> evidenceFindings;
  final List<RiskFactor> riskFactors;

  const SecurityAssessment({
    required this.score,
    required this.status,
    required this.evidenceFindings,
    required this.riskFactors,
  });

  List<Vulnerability> get findings =>
      evidenceFindings.map((finding) => finding.toVulnerability()).toList();

  @override
  List<Object?> get props => [score, status, evidenceFindings, riskFactors];
}
