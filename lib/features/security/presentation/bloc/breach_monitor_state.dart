import 'package:equatable/equatable.dart';

import '../../domain/entities/breach_check_result.dart';

sealed class BreachMonitorState extends Equatable {
  const BreachMonitorState();

  @override
  List<Object?> get props => [];
}

class BreachMonitorInitial extends BreachMonitorState {
  const BreachMonitorInitial();
}

class BreachMonitorLoading extends BreachMonitorState {
  const BreachMonitorLoading();
}

class BreachMonitorSuccess extends BreachMonitorState {
  final BreachCheckResult result;

  const BreachMonitorSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class BreachMonitorFailure extends BreachMonitorState {
  final String message;

  const BreachMonitorFailure(this.message);

  @override
  List<Object?> get props => [message];
}
