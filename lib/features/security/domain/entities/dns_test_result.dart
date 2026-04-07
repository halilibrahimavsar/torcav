import 'package:equatable/equatable.dart';

enum DnsSecurityStatus { secure, warning, dangerous }

class DnsTestResult extends Equatable {
  final String currentDns;
  final String ispName;
  final bool isHijacked;
  final bool isLeaking;
  final DnsSecurityStatus status;
  final List<String> detectedServers;
  final bool encryptedDnsActive;
  final String encryptedDnsStatus;
  final bool resolverDriftDetected;
  final String evidence;

  const DnsTestResult({
    required this.currentDns,
    required this.ispName,
    required this.isHijacked,
    required this.isLeaking,
    required this.status,
    required this.detectedServers,
    this.encryptedDnsActive = false,
    this.encryptedDnsStatus = 'unknown',
    this.resolverDriftDetected = false,
    this.evidence = '',
  });

  DnsTestResult copyWith({
    String? currentDns,
    String? ispName,
    bool? isHijacked,
    bool? isLeaking,
    DnsSecurityStatus? status,
    List<String>? detectedServers,
    bool? encryptedDnsActive,
    String? encryptedDnsStatus,
    bool? resolverDriftDetected,
    String? evidence,
  }) {
    return DnsTestResult(
      currentDns: currentDns ?? this.currentDns,
      ispName: ispName ?? this.ispName,
      isHijacked: isHijacked ?? this.isHijacked,
      isLeaking: isLeaking ?? this.isLeaking,
      status: status ?? this.status,
      detectedServers: detectedServers ?? this.detectedServers,
      encryptedDnsActive: encryptedDnsActive ?? this.encryptedDnsActive,
      encryptedDnsStatus: encryptedDnsStatus ?? this.encryptedDnsStatus,
      resolverDriftDetected:
          resolverDriftDetected ?? this.resolverDriftDetected,
      evidence: evidence ?? this.evidence,
    );
  }

  factory DnsTestResult.fromJson(Map<String, dynamic> json) {
    return DnsTestResult(
      currentDns: json['currentDns'] as String? ?? 'Unknown',
      ispName: json['ispName'] as String? ?? 'Unknown ISP',
      isHijacked: json['isHijacked'] as bool? ?? false,
      isLeaking: json['isLeaking'] as bool? ?? false,
      status: DnsSecurityStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => DnsSecurityStatus.warning,
      ),
      detectedServers:
          (json['detectedServers'] as List<dynamic>? ?? const [])
              .whereType<String>()
              .toList(),
      encryptedDnsActive: json['encryptedDnsActive'] as bool? ?? false,
      encryptedDnsStatus: json['encryptedDnsStatus'] as String? ?? 'unknown',
      resolverDriftDetected: json['resolverDriftDetected'] as bool? ?? false,
      evidence: json['evidence'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentDns': currentDns,
      'ispName': ispName,
      'isHijacked': isHijacked,
      'isLeaking': isLeaking,
      'status': status.name,
      'detectedServers': detectedServers,
      'encryptedDnsActive': encryptedDnsActive,
      'encryptedDnsStatus': encryptedDnsStatus,
      'resolverDriftDetected': resolverDriftDetected,
      'evidence': evidence,
    };
  }

  @override
  List<Object?> get props => [
    currentDns,
    ispName,
    isHijacked,
    isLeaking,
    status,
    detectedServers,
    encryptedDnsActive,
    encryptedDnsStatus,
    resolverDriftDetected,
    evidence,
  ];
}
