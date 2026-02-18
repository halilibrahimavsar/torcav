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

class SecurityNetworkTrustChanged extends SecurityEvent {
  final KnownNetwork network;
  final bool isTrusted;

  const SecurityNetworkTrustChanged({
    required this.network,
    required this.isTrusted,
  });

  @override
  List<Object?> get props => [network, isTrusted];
}

class SecurityAlertsCleared extends SecurityEvent {}
