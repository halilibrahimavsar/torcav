import 'package:equatable/equatable.dart';

import '../../domain/entities/category_explanation.dart';
import '../../domain/entities/diagnosis_result.dart';
import '../../domain/entities/root_cause_category.dart';
import '../../domain/repositories/diagnostics_repository.dart';

enum DiagnosticsStatus { idle, running, ready, failure }

class DiagnosticsState extends Equatable {
  final DiagnosticsStatus status;
  final double progress;
  final DiagnosticsStep? currentStep;
  final DiagnosisResult? result;
  final Map<RootCauseCategory, CategoryExplanation> explanations;
  final String? errorMessage;

  const DiagnosticsState({
    this.status = DiagnosticsStatus.idle,
    this.progress = 0,
    this.currentStep,
    this.result,
    this.explanations = const {},
    this.errorMessage,
  });

  DiagnosticsState copyWith({
    DiagnosticsStatus? status,
    double? progress,
    DiagnosticsStep? currentStep,
    DiagnosisResult? result,
    Map<RootCauseCategory, CategoryExplanation>? explanations,
    String? errorMessage,
  }) {
    return DiagnosticsState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      currentStep: currentStep ?? this.currentStep,
      result: result ?? this.result,
      explanations: explanations ?? this.explanations,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    progress,
    currentStep,
    result,
    explanations,
    errorMessage,
  ];
}
