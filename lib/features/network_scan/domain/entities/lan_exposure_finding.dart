import 'package:equatable/equatable.dart';

import 'vulnerability_finding.dart';

class LanExposureFinding extends Equatable {
  const LanExposureFinding({
    required this.ruleId,
    required this.hostIp,
    required this.hostMac,
    required this.hostVendor,
    required this.summary,
    required this.risk,
    required this.evidence,
    required this.remediation,
    this.serviceName,
    this.port,
  });

  factory LanExposureFinding.fromJson(Map<String, dynamic> json) {
    return LanExposureFinding(
      ruleId: json['ruleId'] as String? ?? 'lan.unknown',
      hostIp: json['hostIp'] as String? ?? '',
      hostMac: json['hostMac'] as String? ?? '',
      hostVendor: json['hostVendor'] as String? ?? 'Unknown',
      summary: json['summary'] as String? ?? '',
      risk: VulnerabilityRisk.values.firstWhere(
        (value) => value.name == json['risk'],
        orElse: () => VulnerabilityRisk.info,
      ),
      evidence: json['evidence'] as String? ?? '',
      remediation: json['remediation'] as String? ?? '',
      serviceName: json['serviceName'] as String?,
      port: json['port'] as int?,
    );
  }

  final String ruleId;
  final String hostIp;
  final String hostMac;
  final String hostVendor;
  final String summary;
  final VulnerabilityRisk risk;
  final String evidence;
  final String remediation;
  final String? serviceName;
  final int? port;

  Map<String, dynamic> toJson() {
    return {
      'ruleId': ruleId,
      'hostIp': hostIp,
      'hostMac': hostMac,
      'hostVendor': hostVendor,
      'summary': summary,
      'risk': risk.name,
      'evidence': evidence,
      'remediation': remediation,
      'serviceName': serviceName,
      'port': port,
    };
  }

  VulnerabilityFinding toLegacyFinding() {
    return VulnerabilityFinding(id: ruleId, summary: summary, risk: risk);
  }

  @override
  List<Object?> get props => [
    ruleId,
    hostIp,
    hostMac,
    hostVendor,
    summary,
    risk,
    evidence,
    remediation,
    serviceName,
    port,
  ];
}
