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
  final List<domain_event.SecurityEvent> recentEvents;
  final int overallScore;
  final SecurityScanSummary? scanSummary;

  const SecurityLoaded({
    required this.knownNetworks,
    required this.recentEvents,
    this.overallScore = 100,
    this.scanSummary,
  });

  @override
  List<Object?> get props => [
        knownNetworks,
        recentEvents,
        overallScore,
        scanSummary,
      ];
}

class SecurityError extends SecurityState {
  final String message;
  const SecurityError(this.message);

  @override
  List<Object?> get props => [message];
}
