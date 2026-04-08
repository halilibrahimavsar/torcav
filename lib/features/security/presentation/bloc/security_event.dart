part of 'security_bloc.dart';

abstract class SecurityEvent extends Equatable {
  const SecurityEvent();

  @override
  List<Object?> get props => [];
}

class SecurityStarted extends SecurityEvent {}

class SecurityAnalyzeRequested extends SecurityEvent {
  final List<WifiNetwork> networks;
  final bool? isDeepScan;
  const SecurityAnalyzeRequested(this.networks, {this.isDeepScan});

  @override
  List<Object?> get props => [networks, isDeepScan];
}

class SecurityDeepScanToggled extends SecurityEvent {
  final bool value;
  const SecurityDeepScanToggled(this.value);

  @override
  List<Object?> get props => [value];
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
