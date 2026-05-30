import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/features/performance/domain/entities/speed_test_progress.dart';
import 'package:torcav/features/performance/domain/entities/speed_test_result.dart';
import 'package:torcav/features/performance/domain/repositories/speed_test_history_repository.dart';
import 'package:torcav/features/performance/domain/usecases/run_speed_test_usecase.dart';
import 'package:torcav/features/performance/presentation/bloc/performance_bloc.dart';

class _MockRunSpeedTest extends Mock implements RunSpeedTestUseCase {}

class _MockHistory extends Mock implements SpeedTestHistoryRepository {}

class _FakeSpeedTestResult extends Fake implements SpeedTestResult {}

void main() {
  late _MockRunSpeedTest runUc;
  late _MockHistory history;

  setUpAll(() {
    registerFallbackValue(_FakeSpeedTestResult());
  });

  setUp(() {
    runUc = _MockRunSpeedTest();
    history = _MockHistory();
    when(() => history.save(any())).thenAnswer((_) async {});
  });

  PerformanceBloc build() => PerformanceBloc(runUc, history);

  group('StartSpeedTest', () {
    blocTest<PerformanceBloc, PerformanceState>(
      'emits PerformanceRunning(idle) immediately, then forwarded progress states',
      build: () {
        when(() => runUc()).thenAnswer(
          (_) => Stream.fromIterable(const [
            SpeedTestProgress(phase: SpeedTestPhase.latency, latencyMs: 10),
            SpeedTestProgress(phase: SpeedTestPhase.download, downloadMbps: 50),
          ]),
        );
        return build();
      },
      act: (bloc) => bloc.add(StartSpeedTest()),
      expect: () => [
        const PerformanceRunning(SpeedTestProgress.idle()),
        const PerformanceRunning(
          SpeedTestProgress(phase: SpeedTestPhase.latency, latencyMs: 10),
        ),
        const PerformanceRunning(
          SpeedTestProgress(phase: SpeedTestPhase.download, downloadMbps: 50),
        ),
      ],
    );

    blocTest<PerformanceBloc, PerformanceState>(
      'emits PerformanceSuccess (not Running) when phase=done',
      build: () {
        when(() => runUc()).thenAnswer(
          (_) => Stream.fromIterable(const [
            SpeedTestProgress(
              phase: SpeedTestPhase.done,
              latencyMs: 15,
              downloadMbps: 120,
              uploadMbps: 25,
            ),
          ]),
        );
        return build();
      },
      act: (bloc) => bloc.add(StartSpeedTest()),
      expect: () => [
        const PerformanceRunning(SpeedTestProgress.idle()),
        isA<PerformanceSuccess>().having(
          (s) => s.result.downloadMbps,
          'downloadMbps',
          120,
        ),
      ],
    );

    blocTest<PerformanceBloc, PerformanceState>(
      'persists a SpeedTestResult on phase=done via the history repository',
      build: () {
        when(() => runUc()).thenAnswer(
          (_) => Stream.fromIterable(const [
            SpeedTestProgress(
              phase: SpeedTestPhase.done,
              latencyMs: 18,
              jitterMs: 3,
              downloadMbps: 200,
              uploadMbps: 40,
            ),
          ]),
        );
        return build();
      },
      act: (bloc) => bloc.add(StartSpeedTest()),
      wait: const Duration(milliseconds: 10),
      verify: (_) {
        final captured = verify(() => history.save(captureAny())).captured;
        expect(captured, hasLength(1));
        final saved = captured.single as SpeedTestResult;
        expect(saved.latencyMs, 18);
        expect(saved.jitterMs, 3);
        expect(saved.downloadMbps, 200);
        expect(saved.uploadMbps, 40);
      },
    );

    blocTest<PerformanceBloc, PerformanceState>(
      'does not persist when only running phases stream (no done)',
      build: () {
        when(() => runUc()).thenAnswer(
          (_) => Stream.fromIterable(const [
            SpeedTestProgress(phase: SpeedTestPhase.latency),
            SpeedTestProgress(phase: SpeedTestPhase.download),
          ]),
        );
        return build();
      },
      act: (bloc) => bloc.add(StartSpeedTest()),
      wait: const Duration(milliseconds: 10),
      verify: (_) {
        verifyNever(() => history.save(any()));
      },
    );

    blocTest<PerformanceBloc, PerformanceState>(
      'on stream error: emits PerformanceFailure with the error message',
      build: () {
        when(() => runUc()).thenAnswer(
          (_) => Stream<SpeedTestProgress>.error(Exception('network down')),
        );
        return build();
      },
      act: (bloc) => bloc.add(StartSpeedTest()),
      expect: () => [
        const PerformanceRunning(SpeedTestProgress.idle()),
        isA<PerformanceFailure>().having(
          (f) => f.message,
          'message',
          contains('network down'),
        ),
      ],
    );

    blocTest<PerformanceBloc, PerformanceState>(
      'restarting cancels the previous subscription before reseeding',
      build: () {
        final controller = StreamController<SpeedTestProgress>();
        addTearDown(controller.close);
        // The first call returns an open stream; the second returns done immediately.
        var callCount = 0;
        when(() => runUc()).thenAnswer((_) {
          callCount++;
          if (callCount == 1) return controller.stream;
          return Stream.fromIterable(const [
            SpeedTestProgress(phase: SpeedTestPhase.done, downloadMbps: 1),
          ]);
        });
        return build();
      },
      act: (bloc) async {
        bloc.add(StartSpeedTest());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        bloc.add(StartSpeedTest());
      },
      wait: const Duration(milliseconds: 30),
      verify: (_) {
        verify(() => runUc()).called(2);
      },
    );
  });

  group('StopSpeedTest', () {
    blocTest<PerformanceBloc, PerformanceState>(
      'returns to PerformanceInitial and cancels the subscription',
      build: () {
        final controller = StreamController<SpeedTestProgress>();
        addTearDown(controller.close);
        when(() => runUc()).thenAnswer((_) => controller.stream);
        return build();
      },
      act: (bloc) async {
        bloc.add(StartSpeedTest());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        bloc.add(StopSpeedTest());
      },
      expect: () => [
        const PerformanceRunning(SpeedTestProgress.idle()),
        isA<PerformanceInitial>(),
      ],
    );
  });
}
