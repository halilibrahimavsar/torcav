import 'package:equatable/equatable.dart';

import 'diagnosis_evidence.dart';
import 'diagnosis_inputs.dart';
import 'root_cause_category.dart';

class DiagnosisResult extends Equatable {
  final DateTime timestamp;
  final RootCauseCategory primaryCause;
  final List<DiagnosisEvidence> allEvidence;
  final DiagnosisInputs inputs;

  const DiagnosisResult({
    required this.timestamp,
    required this.primaryCause,
    required this.allEvidence,
    required this.inputs,
  });

  @override
  List<Object?> get props => [timestamp, primaryCause, allEvidence, inputs];
}
