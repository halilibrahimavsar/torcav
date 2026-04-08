import 'package:equatable/equatable.dart';

import 'vulnerability.dart';

enum SecurityFindingCategory {
  wifiConfiguration,
  trustedBaseline,
  privacy,
  lanExposure,
  heatmapCoverage,
  hardwareVulnerability,
}

enum SecurityFindingConfidence { heuristic, observed, strong }

class SecurityFinding extends Equatable {
  const SecurityFinding({
    required this.ruleId,
    required this.category,
    required this.severity,
    required this.confidence,
    required this.title,
    required this.description,
    required this.evidence,
    required this.recommendation,
    required this.timestamp,
    this.subject = '',
  });

  factory SecurityFinding.fromJson(Map<String, dynamic> json) {
    return SecurityFinding(
      ruleId: json['ruleId'] as String? ?? 'unknown',
      category: SecurityFindingCategory.values.firstWhere(
        (value) => value.name == json['category'],
        orElse: () => SecurityFindingCategory.wifiConfiguration,
      ),
      severity: VulnerabilitySeverity.values.firstWhere(
        (value) => value.name == json['severity'],
        orElse: () => VulnerabilitySeverity.info,
      ),
      confidence: SecurityFindingConfidence.values.firstWhere(
        (value) => value.name == json['confidence'],
        orElse: () => SecurityFindingConfidence.heuristic,
      ),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      evidence: json['evidence'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      subject: json['subject'] as String? ?? '',
    );
  }

  final String ruleId;
  final SecurityFindingCategory category;
  final VulnerabilitySeverity severity;
  final SecurityFindingConfidence confidence;
  final String title;
  final String description;
  final String evidence;
  final String recommendation;
  final DateTime timestamp;
  final String subject;

  Map<String, dynamic> toJson() {
    return {
      'type': 'security',
      'ruleId': ruleId,
      'category': category.name,
      'severity': severity.name,
      'confidence': confidence.name,
      'title': title,
      'description': description,
      'evidence': evidence,
      'recommendation': recommendation,
      'timestamp': timestamp.toIso8601String(),
      'subject': subject,
    };
  }

  Vulnerability toVulnerability() {
    return Vulnerability(
      title: title,
      description: description,
      severity: severity,
      recommendation: recommendation,
      ruleId: ruleId,
      category: category.name,
      confidence: confidence.name,
      evidence: evidence,
      timestamp: timestamp,
    );
  }

  @override
  List<Object?> get props => [
    ruleId,
    category,
    severity,
    confidence,
    title,
    description,
    evidence,
    recommendation,
    timestamp,
    subject,
  ];
}
