part of 'security_bloc.dart';

sealed class SecurityState extends Equatable {
  const SecurityState();

  @override
  List<Object?> get props => [];
}

class SecurityInitial extends SecurityState {}

class SecurityLoading extends SecurityState {}

class SecurityScanSummary extends Equatable {
  final int totalNetworks;
  final int openCount;
  final int wepCount;
  final int wpsCount;

  const SecurityScanSummary({
    required this.totalNetworks,
    required this.openCount,
    required this.wepCount,
    required this.wpsCount,
  });

  @override
  List<Object?> get props => [totalNetworks, openCount, wepCount, wpsCount];
}

class SecurityLoaded extends SecurityState {
  final List<KnownNetwork> knownNetworks;
  final List<TrustedNetworkProfile> trustedNetworkProfiles;
  final List<domain_event.SecurityEvent> recentEvents;
  final int overallScore;
  final SecurityScanSummary? scanSummary;
  final DnsTestResult? dnsResult;
  final bool isDnsLoading;

  const SecurityLoaded({
    required this.knownNetworks,
    required this.trustedNetworkProfiles,
    required this.recentEvents,
    this.overallScore = 100,
    this.scanSummary,
    this.dnsResult,
    this.isDnsLoading = false,
  });

  SecurityLoaded copyWith({
    List<KnownNetwork>? knownNetworks,
    List<TrustedNetworkProfile>? trustedNetworkProfiles,
    List<domain_event.SecurityEvent>? recentEvents,
    int? overallScore,
    SecurityScanSummary? scanSummary,
    DnsTestResult? dnsResult,
    bool? isDnsLoading,
  }) {
    return SecurityLoaded(
      knownNetworks: knownNetworks ?? this.knownNetworks,
      trustedNetworkProfiles:
          trustedNetworkProfiles ?? this.trustedNetworkProfiles,
      recentEvents: recentEvents ?? this.recentEvents,
      overallScore: overallScore ?? this.overallScore,
      scanSummary: scanSummary ?? this.scanSummary,
      dnsResult: dnsResult ?? this.dnsResult,
      isDnsLoading: isDnsLoading ?? this.isDnsLoading,
    );
  }

  @override
  List<Object?> get props => [
        knownNetworks,
        trustedNetworkProfiles,
        recentEvents,
        overallScore,
        scanSummary,
        dnsResult,
        isDnsLoading,
      ];
}

class SecurityError extends SecurityState {
  final String message;
  const SecurityError(this.message);

  @override
  List<Object?> get props => [message];
}
