import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/features/diagnostics/domain/entities/diagnosis_inputs.dart';
import 'package:torcav/features/diagnostics/domain/entities/root_cause_category.dart';
import 'package:torcav/features/diagnostics/domain/repositories/diagnostics_repository.dart';
import 'package:torcav/features/diagnostics/domain/services/diagnosis_explainer.dart';
import 'package:torcav/features/diagnostics/domain/usecases/diagnose_usecase.dart';
import 'package:torcav/features/diagnostics/presentation/bloc/diagnostics_bloc.dart';
import 'package:torcav/features/diagnostics/presentation/bloc/diagnostics_event.dart';
import 'package:torcav/features/diagnostics/presentation/bloc/diagnostics_state.dart';
import 'package:torcav/features/security/domain/entities/network_context_type.dart';
import 'package:torcav/features/wifi_scan/domain/services/channel_rating_engine.dart';

class _FakeDiagnosticsRepo extends Mock implements DiagnosticsRepository {}

void main() {
  late _FakeDiagnosticsRepo repo;
  late DiagnoseUseCase diagnose;
  late DiagnosisExplainer explainer;

  setUp(() {
    repo = _FakeDiagnosticsRepo();
    diagnose = DiagnoseUseCase(ChannelRatingEngine());
    explainer = const DiagnosisExplainer();
  });

  blocTest<DiagnosticsBloc, DiagnosticsState>(
    'walks through running steps and lands on ready',
    build: () => DiagnosticsBloc(repo, diagnose, explainer),
    setUp: () {
      const finalInputs = DiagnosisInputs(
        connectedNetwork: null,
        visibleNetworks: [],
        speedTest: null,
        gatewayPingMs: null,
        dnsBenchmark: null,
        context: NetworkContextType.unknown,
      );
      when(() => repo.collectInputs()).thenAnswer(
        (_) => Stream<DiagnosticsProgress>.fromIterable([
          const DiagnosticsProgress(
            step: DiagnosticsStep.signal,
            progress: 0.05,
          ),
          const DiagnosticsProgress(
            step: DiagnosticsStep.speedTest,
            progress: 0.5,
          ),
          const DiagnosticsProgress(
            step: DiagnosticsStep.finalize,
            progress: 1,
            partialInputs: finalInputs,
          ),
        ]),
      );
    },
    act: (bloc) => bloc.add(const DiagnosticsStarted()),
    verify: (bloc) {
      expect(bloc.state.status, DiagnosticsStatus.ready);
      expect(bloc.state.progress, 1);
      expect(bloc.state.result, isNotNull);
      // No probes succeeded → primary cause is healthy fallback.
      expect(bloc.state.result!.primaryCause, RootCauseCategory.healthy);
    },
  );

  blocTest<DiagnosticsBloc, DiagnosticsState>(
    'transitions to failure when repository throws',
    build: () => DiagnosticsBloc(repo, diagnose, explainer),
    setUp: () {
      when(() => repo.collectInputs()).thenAnswer(
        (_) => Stream<DiagnosticsProgress>.error(StateError('network down')),
      );
    },
    act: (bloc) => bloc.add(const DiagnosticsStarted()),
    verify: (bloc) {
      expect(bloc.state.status, DiagnosticsStatus.failure);
      expect(bloc.state.errorMessage, contains('network down'));
    },
  );

  blocTest<DiagnosticsBloc, DiagnosticsState>(
    'reset returns the bloc to idle',
    build: () => DiagnosticsBloc(repo, diagnose, explainer),
    seed:
        () => const DiagnosticsState(
          status: DiagnosticsStatus.failure,
          errorMessage: 'boom',
        ),
    act: (bloc) => bloc.add(const DiagnosticsReset()),
    expect: () => [const DiagnosticsState()],
  );
}
