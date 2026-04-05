import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/speed_test_progress.dart';
import '../../domain/entities/speed_test_result.dart';
import '../../domain/repositories/speed_test_history_repository.dart';
import '../../domain/usecases/run_speed_test_usecase.dart';

// ── Events ──────────────────────────────────────────────────────────────────

abstract class PerformanceEvent extends Equatable {
  const PerformanceEvent();
  @override
  List<Object?> get props => [];
}

class StartSpeedTest extends PerformanceEvent {}

class _ProgressUpdated extends PerformanceEvent {
  final SpeedTestProgress progress;
  const _ProgressUpdated(this.progress);
  @override
  List<Object?> get props => [progress];
}

class _TestError extends PerformanceEvent {
  final String message;
  const _TestError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── State ───────────────────────────────────────────────────────────────────

abstract class PerformanceState extends Equatable {
  const PerformanceState();
  @override
  List<Object?> get props => [];
}

class PerformanceInitial extends PerformanceState {}

class PerformanceRunning extends PerformanceState {
  final SpeedTestProgress progress;
  const PerformanceRunning(this.progress);
  @override
  List<Object?> get props => [progress];
}

class PerformanceSuccess extends PerformanceState {
  final SpeedTestProgress result;
  const PerformanceSuccess(this.result);
  @override
  List<Object?> get props => [result];
}

class PerformanceFailure extends PerformanceState {
  final String message;
  const PerformanceFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ────────────────────────────────────────────────────────────────────

@injectable
class PerformanceBloc extends Bloc<PerformanceEvent, PerformanceState> {
  final RunSpeedTestUseCase _runSpeedTest;
  final SpeedTestHistoryRepository _history;
  StreamSubscription<SpeedTestProgress>? _subscription;

  PerformanceBloc(this._runSpeedTest, this._history)
      : super(PerformanceInitial()) {
    on<StartSpeedTest>(_onStart);
    on<_ProgressUpdated>(_onProgress);
    on<_TestError>(_onError);
  }

  Future<void> _onStart(StartSpeedTest event, Emitter<PerformanceState> emit) async {
    await _subscription?.cancel();
    emit(const PerformanceRunning(SpeedTestProgress.idle()));

    _subscription = _runSpeedTest().listen(
      (progress) => add(_ProgressUpdated(progress)),
      onError: (Object e) => add(_TestError(e.toString())),
    );
  }

  void _onProgress(_ProgressUpdated event, Emitter<PerformanceState> emit) {
    if (event.progress.phase == SpeedTestPhase.done) {
      emit(PerformanceSuccess(event.progress));
      _history.save(SpeedTestResult(
        recordedAt: DateTime.now(),
        latencyMs: event.progress.latencyMs,
        jitterMs: event.progress.jitterMs,
        downloadMbps: event.progress.downloadMbps,
        uploadMbps: event.progress.uploadMbps,
      ));
    } else {
      emit(PerformanceRunning(event.progress));
    }
  }

  void _onError(_TestError event, Emitter<PerformanceState> emit) {
    emit(PerformanceFailure(event.message));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
