import 'package:equatable/equatable.dart';

import 'vulnerability.dart';

enum SecurityStatus { secure, moderate, atRisk, critical }

class SecurityAssessment extends Equatable {
  final int score;
  final SecurityStatus status;
  final List<Vulnerability> findings;
  final List<String> riskFactors;

  const SecurityAssessment({
    required this.score,
    required this.status,
    required this.findings,
    required this.riskFactors,
  });

  String get statusLabel => switch (status) {
    SecurityStatus.secure => 'Secure',
    SecurityStatus.moderate => 'Moderate',
    SecurityStatus.atRisk => 'At Risk',
    SecurityStatus.critical => 'Critical',
  };

  @override
  List<Object?> get props => [score, status, findings, riskFactors];
}
