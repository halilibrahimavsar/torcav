import 'package:torcav/features/security/domain/entities/security_finding.dart';
import 'package:torcav/features/security/domain/entities/vulnerability.dart';

class SecurityDriftFinding extends SecurityFinding {
  const SecurityDriftFinding({
    required super.ruleId,
    required super.severity,
    required super.confidence,
    required super.title,
    required super.description,
    required super.evidence,
    required super.recommendation,
    required super.timestamp,
    required this.baselineBssid,
    required this.observedBssid,
    required this.changedAttributes,
    super.subject,
  }) : super(category: SecurityFindingCategory.trustedBaseline);

  factory SecurityDriftFinding.fromJson(Map<String, dynamic> json) {
    return SecurityDriftFinding(
      ruleId: json['ruleId'] as String? ?? 'trusted.drift',
      severity: VulnerabilitySeverity.values.firstWhere(
        (value) => value.name == json['severity'],
        orElse: () => VulnerabilitySeverity.medium,
      ),
      confidence: SecurityFindingConfidence.values.firstWhere(
        (value) => value.name == json['confidence'],
        orElse: () => SecurityFindingConfidence.observed,
      ),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      evidence: json['evidence'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      baselineBssid: json['baselineBssid'] as String? ?? '',
      observedBssid: json['observedBssid'] as String? ?? '',
      changedAttributes:
          (json['changedAttributes'] as List<dynamic>? ?? const [])
              .whereType<String>()
              .toList(),
      subject: json['subject'] as String? ?? '',
    );
  }

  final String baselineBssid;
  final String observedBssid;
  final List<String> changedAttributes;

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'type': 'drift',
      'baselineBssid': baselineBssid,
      'observedBssid': observedBssid,
      'changedAttributes': changedAttributes,
    };
  }

  @override
  List<Object?> get props => [
    ...super.props,
    baselineBssid,
    observedBssid,
    changedAttributes,
  ];
}
