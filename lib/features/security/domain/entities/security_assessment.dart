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

  /// A plain-language explanation of the security score, suitable for
  /// users who are not familiar with networking terminology.
  String get plainSummary => switch (status) {
    SecurityStatus.secure =>
      'Your connection looks good! This network uses strong encryption '
      'and is well protected against common attacks.',
    SecurityStatus.moderate =>
      'This network has decent security but some potential weaknesses. '
      'It is safe for everyday use, but avoid sensitive transactions.',
    SecurityStatus.atRisk =>
      'This network has security issues that put your data at risk. '
      'Avoid entering passwords or personal information while connected.',
    SecurityStatus.critical =>
      'Warning: This network is not secure. Anyone nearby may be able '
      'to see your internet traffic. Use a VPN or switch networks.',
  };

  @override
  List<Object?> get props => [score, status, evidenceFindings, riskFactors];
}
