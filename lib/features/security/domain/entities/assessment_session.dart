import 'package:equatable/equatable.dart';

import 'dns_test_result.dart';
import 'security_assessment.dart';
import 'security_drift_finding.dart';
import 'security_finding.dart';
import 'vulnerability.dart';
import 'package:torcav/features/network_scan/domain/entities/lan_exposure_finding.dart';

class AssessmentSession extends Equatable {
  const AssessmentSession({
    required this.sessionKey,
    required this.createdAt,
    required this.overallScore,
    required this.overallStatus,
    required this.wifiFindings,
    required this.lanFindings,
    required this.trustedProfileCount,
    this.dnsResult,
  });

  factory AssessmentSession.fromJson(Map<String, dynamic> json) {
    final rawWifiFindings = json['wifiFindings'] as List<dynamic>? ?? const [];
    final rawLanFindings = json['lanFindings'] as List<dynamic>? ?? const [];

    return AssessmentSession(
      sessionKey: json['sessionKey'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      overallScore: json['overallScore'] as int? ?? 100,
      overallStatus: SecurityStatus.values.firstWhere(
        (value) => value.name == json['overallStatus'],
        orElse: () => SecurityStatus.secure,
      ),
      wifiFindings:
          rawWifiFindings.map((raw) {
            final map = raw as Map<String, dynamic>;
            if (map['type'] == 'drift') {
              return SecurityDriftFinding.fromJson(map);
            }
            return SecurityFinding.fromJson(map);
          }).toList(),
      lanFindings:
          rawLanFindings
              .whereType<Map<String, dynamic>>()
              .map(LanExposureFinding.fromJson)
              .toList(),
      dnsResult:
          json['dnsResult'] is Map<String, dynamic>
              ? DnsTestResult.fromJson(
                json['dnsResult'] as Map<String, dynamic>,
              )
              : null,
      trustedProfileCount: json['trustedProfileCount'] as int? ?? 0,
    );
  }

  final String sessionKey;
  final DateTime createdAt;
  final int overallScore;
  final SecurityStatus overallStatus;
  final List<SecurityFinding> wifiFindings;
  final List<LanExposureFinding> lanFindings;
  final DnsTestResult? dnsResult;
  final int trustedProfileCount;

  List<Vulnerability> get vulnerabilities =>
      wifiFindings.map((finding) => finding.toVulnerability()).toList();

  AssessmentSession copyWith({
    String? sessionKey,
    DateTime? createdAt,
    int? overallScore,
    SecurityStatus? overallStatus,
    List<SecurityFinding>? wifiFindings,
    List<LanExposureFinding>? lanFindings,
    DnsTestResult? dnsResult,
    bool clearDnsResult = false,
    int? trustedProfileCount,
  }) {
    return AssessmentSession(
      sessionKey: sessionKey ?? this.sessionKey,
      createdAt: createdAt ?? this.createdAt,
      overallScore: overallScore ?? this.overallScore,
      overallStatus: overallStatus ?? this.overallStatus,
      wifiFindings: wifiFindings ?? this.wifiFindings,
      lanFindings: lanFindings ?? this.lanFindings,
      dnsResult: clearDnsResult ? null : (dnsResult ?? this.dnsResult),
      trustedProfileCount: trustedProfileCount ?? this.trustedProfileCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionKey': sessionKey,
      'createdAt': createdAt.toIso8601String(),
      'overallScore': overallScore,
      'overallStatus': overallStatus.name,
      'wifiFindings': wifiFindings.map((finding) => finding.toJson()).toList(),
      'lanFindings': lanFindings.map((finding) => finding.toJson()).toList(),
      'dnsResult': dnsResult?.toJson(),
      'trustedProfileCount': trustedProfileCount,
    };
  }

  @override
  List<Object?> get props => [
    sessionKey,
    createdAt,
    overallScore,
    overallStatus,
    wifiFindings,
    lanFindings,
    dnsResult,
    trustedProfileCount,
  ];
}
