import 'package:equatable/equatable.dart';

import '../../domain/entities/diagnosis_result.dart';
import '../../domain/repositories/diagnostics_repository.dart';

enum DiagnosticsStatus { idle, running, ready, failure }

class DiagnosticsState extends Equatable {
  final DiagnosticsStatus status;
  final double progress;
  final DiagnosticsStep? currentStep;
  final DiagnosisResult? result;
  final String? errorMessage;

  const DiagnosticsState({
    this.status = DiagnosticsStatus.idle,
    this.progress = 0,
    this.currentStep,
    this.result,
    this.errorMessage,
  });

  DiagnosticsState copyWith({
    DiagnosticsStatus? status,
    double? progress,
    DiagnosticsStep? currentStep,
    DiagnosisResult? result,
    String? errorMessage,
  }) {
    return DiagnosticsState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      currentStep: currentStep ?? this.currentStep,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    progress,
    currentStep,
    result,
    errorMessage,
  ];
}
