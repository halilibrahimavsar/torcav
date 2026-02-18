part of 'security_bloc.dart';

abstract class SecurityState extends Equatable {
  const SecurityState();

  @override
  List<Object?> get props => [];
}

class SecurityInitial extends SecurityState {}

class SecurityLoading extends SecurityState {}

class SecurityLoaded extends SecurityState {
  final List<KnownNetwork> knownNetworks;
  final List<domain_event.SecurityEvent> recentEvents;

  const SecurityLoaded({
    required this.knownNetworks,
    required this.recentEvents,
  });

  @override
  List<Object?> get props => [knownNetworks, recentEvents];
}

class SecurityError extends SecurityState {
  final String message;
  const SecurityError(this.message);

  @override
  List<Object?> get props => [message];
}
