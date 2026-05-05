import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/diagnostics_repository.dart';
import '../../domain/usecases/diagnose_usecase.dart';
import 'diagnostics_event.dart';
import 'diagnostics_state.dart';

@injectable
class DiagnosticsBloc extends Bloc<DiagnosticsEvent, DiagnosticsState> {
  final DiagnosticsRepository _repository;
  final DiagnoseUseCase _diagnose;

  DiagnosticsBloc(this._repository, this._diagnose)
    : super(const DiagnosticsState()) {
    on<DiagnosticsStarted>(_onStarted);
    on<DiagnosticsReset>(
      (event, emit) => emit(const DiagnosticsState()),
    );
  }

  Future<void> _onStarted(
    DiagnosticsStarted event,
    Emitter<DiagnosticsState> emit,
  ) async {
    emit(
      const DiagnosticsState(
        status: DiagnosticsStatus.running,
        progress: 0,
        currentStep: DiagnosticsStep.signal,
      ),
    );

    try {
      await for (final progress in _repository.collectInputs()) {
        emit(
          state.copyWith(
            status: DiagnosticsStatus.running,
            progress: progress.progress,
            currentStep: progress.step,
          ),
        );
        if (progress.step == DiagnosticsStep.finalize &&
            progress.partialInputs != null) {
          final result = _diagnose(progress.partialInputs!);
          emit(
            state.copyWith(
              status: DiagnosticsStatus.ready,
              progress: 1,
              result: result,
            ),
          );
          return;
        }
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: DiagnosticsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
