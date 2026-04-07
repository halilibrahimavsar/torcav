part of 'security_bloc.dart';

abstract class SecurityEvent extends Equatable {
  const SecurityEvent();

  @override
  List<Object?> get props => [];
}

class SecurityStarted extends SecurityEvent {}

class SecurityAnalyzeRequested extends SecurityEvent {
  final List<WifiNetwork> networks;
  const SecurityAnalyzeRequested(this.networks);

  @override
  List<Object?> get props => [networks];
}

class SecurityUntrustRequested extends SecurityEvent {
  final String bssid;

  const SecurityUntrustRequested(this.bssid);

  @override
  List<Object?> get props => [bssid];
}

class SecurityDnsTestRequested extends SecurityEvent {
  const SecurityDnsTestRequested();
}

class SecurityAlertsCleared extends SecurityEvent {}
