import 'package:equatable/equatable.dart';

enum DnsSecurityStatus { secure, warning, dangerous }

class DnsBenchmarkResult extends Equatable {
  final String name;
  final String primaryIp;
  final int latencyMs;
  final List<String> features;
  final bool isRecommended;

  const DnsBenchmarkResult({
    required this.name,
    required this.primaryIp,
    required this.latencyMs,
    required this.features,
    this.isRecommended = false,
  });

  DnsBenchmarkResult copyWith({
    String? name,
    String? primaryIp,
    int? latencyMs,
    List<String>? features,
    bool? isRecommended,
  }) {
    return DnsBenchmarkResult(
      name: name ?? this.name,
      primaryIp: primaryIp ?? this.primaryIp,
      latencyMs: latencyMs ?? this.latencyMs,
      features: features ?? this.features,
      isRecommended: isRecommended ?? this.isRecommended,
    );
  }

  factory DnsBenchmarkResult.fromJson(Map<String, dynamic> json) {
    return DnsBenchmarkResult(
      name: json['name'] as String? ?? 'Unknown',
      primaryIp: json['primaryIp'] as String? ?? '',
      latencyMs: json['latencyMs'] as int? ?? 0,
      features:
          (json['features'] as List<dynamic>? ?? const [])
              .whereType<String>()
              .toList(),
      isRecommended: json['isRecommended'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'primaryIp': primaryIp,
      'latencyMs': latencyMs,
      'features': features,
      'isRecommended': isRecommended,
    };
  }

  @override
  List<Object?> get props => [
    name,
    primaryIp,
    latencyMs,
    features,
    isRecommended,
  ];
}

class DnsTestResult extends Equatable {
  final String currentDns;
  final String ispName;
  final bool isHijacked;
  final bool isLeaking;
  final DnsSecurityStatus status;
  final List<String> detectedServers;
  final bool encryptedDnsActive;
  final String encryptedProtocol;

  /// True if a live RFC 8484 DoH query succeeded on the current network.
  final bool dohReachable;

  /// True if a live TLS handshake on TCP 853 (DoT) succeeded on the
  /// current network.
  final bool dotReachable;
  final bool resolverDriftDetected;
  final bool dnssecSupported;
  final String evidence;
  final List<DnsBenchmarkResult> benchmarks;

  const DnsTestResult({
    required this.currentDns,
    required this.ispName,
    required this.isHijacked,
    required this.isLeaking,
    required this.status,
    required this.detectedServers,
    this.encryptedDnsActive = false,
    this.encryptedProtocol = 'unknown',
    this.dohReachable = false,
    this.dotReachable = false,
    this.resolverDriftDetected = false,
    this.dnssecSupported = false,
    this.evidence = '',
    this.benchmarks = const [],
  });

  DnsTestResult copyWith({
    String? currentDns,
    String? ispName,
    bool? isHijacked,
    bool? isLeaking,
    DnsSecurityStatus? status,
    List<String>? detectedServers,
    bool? encryptedDnsActive,
    String? encryptedProtocol,
    bool? dohReachable,
    bool? dotReachable,
    bool? resolverDriftDetected,
    bool? dnssecSupported,
    String? evidence,
    List<DnsBenchmarkResult>? benchmarks,
  }) {
    return DnsTestResult(
      currentDns: currentDns ?? this.currentDns,
      ispName: ispName ?? this.ispName,
      isHijacked: isHijacked ?? this.isHijacked,
      isLeaking: isLeaking ?? this.isLeaking,
      status: status ?? this.status,
      detectedServers: detectedServers ?? this.detectedServers,
      encryptedDnsActive: encryptedDnsActive ?? this.encryptedDnsActive,
      encryptedProtocol: encryptedProtocol ?? this.encryptedProtocol,
      dohReachable: dohReachable ?? this.dohReachable,
      dotReachable: dotReachable ?? this.dotReachable,
      resolverDriftDetected:
          resolverDriftDetected ?? this.resolverDriftDetected,
      dnssecSupported: dnssecSupported ?? this.dnssecSupported,
      evidence: evidence ?? this.evidence,
      benchmarks: benchmarks ?? this.benchmarks,
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
      encryptedProtocol: json['encryptedProtocol'] as String? ?? 'unknown',
      dohReachable: json['dohReachable'] as bool? ?? false,
      dotReachable: json['dotReachable'] as bool? ?? false,
      resolverDriftDetected: json['resolverDriftDetected'] as bool? ?? false,
      dnssecSupported: json['dnssecSupported'] as bool? ?? false,
      evidence: json['evidence'] as String? ?? '',
      benchmarks:
          (json['benchmarks'] as List<dynamic>? ?? const [])
              .map(
                (e) => DnsBenchmarkResult.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
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
      'encryptedProtocol': encryptedProtocol,
      'dohReachable': dohReachable,
      'dotReachable': dotReachable,
      'resolverDriftDetected': resolverDriftDetected,
      'dnssecSupported': dnssecSupported,
      'evidence': evidence,
      'benchmarks': benchmarks.map((e) => e.toJson()).toList(),
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
    encryptedProtocol,
    dohReachable,
    dotReachable,
    resolverDriftDetected,
    dnssecSupported,
    evidence,
    benchmarks,
  ];
}
