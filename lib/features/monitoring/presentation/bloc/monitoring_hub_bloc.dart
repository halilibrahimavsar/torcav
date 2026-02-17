import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/speed_test_progress.dart';
import '../../domain/usecases/run_speed_test_usecase.dart';

// Events
abstract class MonitoringHubEvent extends Equatable {
  const MonitoringHubEvent();
  @override
  List<Object?> get props => [];
}

class RunSpeedTest extends MonitoringHubEvent {}

class _SpeedTestProgressUpdate extends MonitoringHubEvent {
  final SpeedTestProgress progress;
  const _SpeedTestProgressUpdate(this.progress);
  @override
  List<Object?> get props => [progress];
}

class _SpeedTestError extends MonitoringHubEvent {
  final String message;
  const _SpeedTestError(this.message);
  @override
  List<Object?> get props => [message];
}

// State
abstract class MonitoringHubState extends Equatable {
  const MonitoringHubState();
  @override
  List<Object?> get props => [];
}

class MonitoringHubInitial extends MonitoringHubState {}

class SpeedTestRunning extends MonitoringHubState {
  final SpeedTestProgress progress;
  const SpeedTestRunning(this.progress);
  @override
  List<Object?> get props => [progress];
}

class SpeedTestSuccess extends MonitoringHubState {
  final SpeedTestProgress progress;
  const SpeedTestSuccess(this.progress);
  @override
  List<Object?> get props => [progress];
}

class SpeedTestFailure extends MonitoringHubState {
  final String message;
  const SpeedTestFailure(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class MonitoringHubBloc extends Bloc<MonitoringHubEvent, MonitoringHubState> {
  final RunSpeedTestUseCase _runSpeedTest;
  StreamSubscription<SpeedTestProgress>? _subscription;

  MonitoringHubBloc(this._runSpeedTest) : super(MonitoringHubInitial()) {
    on<RunSpeedTest>(_onRunSpeedTest);
    on<_SpeedTestProgressUpdate>(_onProgress);
    on<_SpeedTestError>(_onError);
  }

  Future<void> _onRunSpeedTest(
    RunSpeedTest event,
    Emitter<MonitoringHubState> emit,
  ) async {
    await _subscription?.cancel();
    emit(const SpeedTestRunning(SpeedTestProgress.idle()));

    _subscription = _runSpeedTest().listen(
      (progress) => add(_SpeedTestProgressUpdate(progress)),
      onError: (Object e) => add(_SpeedTestError(e.toString())),
    );
  }

  void _onProgress(
    _SpeedTestProgressUpdate event,
    Emitter<MonitoringHubState> emit,
  ) {
    if (event.progress.phase == SpeedTestPhase.done) {
      emit(SpeedTestSuccess(event.progress));
    } else {
      emit(SpeedTestRunning(event.progress));
    }
  }

  void _onError(_SpeedTestError event, Emitter<MonitoringHubState> emit) {
    emit(SpeedTestFailure(event.message));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
