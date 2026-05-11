import 'package:equatable/equatable.dart';

import 'security_finding.dart';
import 'vulnerability.dart';

enum SecurityStatus { secure, moderate, atRisk, critical }

class SecurityAssessment extends Equatable {
  final int score;
  final SecurityStatus status;
  final List<SecurityFinding> evidenceFindings;
  final List<String> riskFactors;

  const SecurityAssessment({
    required this.score,
    required this.status,
    required this.evidenceFindings,
    required this.riskFactors,
  });

  List<Vulnerability> get findings =>
      evidenceFindings.map((finding) => finding.toVulnerability()).toList();

  String get statusLabel => switch (status) {
    SecurityStatus.secure => 'Secure',
    SecurityStatus.moderate => 'Moderate',
    SecurityStatus.atRisk => 'At Risk',
    SecurityStatus.critical => 'Critical',
  };

  @override
  List<Object?> get props => [score, status, evidenceFindings, riskFactors];
}
