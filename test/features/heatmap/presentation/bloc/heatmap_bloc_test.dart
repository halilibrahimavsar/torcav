import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/features/heatmap/data/datasources/ar_camera_pose_datasource.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/domain/repositories/heatmap_repository.dart';
import 'package:torcav/features/heatmap/domain/usecases/get_heatmap_sessions_usecase.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';
import 'package:torcav/features/heatmap/presentation/bloc/scan_phase.dart';
import 'package:torcav/features/heatmap/domain/entities/survey_gate.dart';
import 'package:torcav/features/heatmap/domain/entities/position_update.dart';
import 'package:torcav/features/heatmap/domain/services/heatmap_manager.dart';
import 'package:torcav/features/heatmap/domain/services/signal_tracker.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';

class MockGetHeatmapSessionsUsecase extends Mock
    implements GetHeatmapSessionsUsecase {}

class MockHeatmapRepository extends Mock implements HeatmapRepository {}

class MockArCameraPoseDataSource extends Mock
    implements ArCameraPoseDataSource {}

class MockHeatmapManager extends Mock implements HeatmapManager {}

class MockSignalTracker extends Mock implements SignalTracker {}

class MockSurveyGuidanceService extends Mock implements SurveyGuidanceService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HeatmapBloc bloc;
  late MockGetHeatmapSessionsUsecase getSessions;
  late MockHeatmapRepository repository;
  late MockArCameraPoseDataSource arCameraPose;
  late MockHeatmapManager heatmapManager;
  late MockSignalTracker signalTracker;
  late MockSurveyGuidanceService guidanceService;

  late StreamController<HeatmapSession?> sessionController;
  late StreamController<SurveyGate> gateController;
  late StreamController<PositionUpdate> positionController;
  late StreamController<SignalState> signalController;

  late HeatmapSession fallbackSession;

  setUpAll(() {
    fallbackSession = HeatmapSession(
      id: 'fallback',
      name: 'fallback',
      points: const [],
      createdAt: DateTime(2024),
    );
    registerFallbackValue(fallbackSession);
    registerFallbackValue(SurveyGate.none);
    registerFallbackValue(const <HeatmapPoint>[]);
  });

  setUp(() {
    getSessions = MockGetHeatmapSessionsUsecase();
    repository = MockHeatmapRepository();
    arCameraPose = MockArCameraPoseDataSource();
    heatmapManager = MockHeatmapManager();
    signalTracker = MockSignalTracker();
    guidanceService = MockSurveyGuidanceService();

    sessionController = StreamController<HeatmapSession?>.broadcast();
    gateController = StreamController<SurveyGate>.broadcast();
    positionController = StreamController<PositionUpdate>.broadcast();
    signalController = StreamController<SignalState>.broadcast();

    reset(getSessions);
    reset(repository);
    reset(arCameraPose);
    reset(heatmapManager);
    reset(signalTracker);
    reset(guidanceService);

    when(() => getSessions.call()).thenAnswer((_) async => const Right([]));
    when(
      () => heatmapManager.sessionStream,
    ).thenAnswer((_) => sessionController.stream);
    when(
      () => heatmapManager.gateStream,
    ).thenAnswer((_) => gateController.stream);
    when(
      () => heatmapManager.rawPositionStream,
    ).thenAnswer((_) => positionController.stream);
    when(
      () => signalTracker.stateStream,
    ).thenAnswer((_) => signalController.stream);
    when(() => signalTracker.runMetadataScan()).thenAnswer((_) async {});
    when(
      () => guidanceService.analyze(
        points: any(named: 'points'),
        isRecording: any(named: 'isRecording'),
        currentRssi: any(named: 'currentRssi'),
        surveyGate: any(named: 'surveyGate'),
        lastSignalAt: any(named: 'lastSignalAt'),
        currentSignalStdDev: any(named: 'currentSignalStdDev'),
        currentX: any(named: 'currentX'),
        currentY: any(named: 'currentY'),
      ),
    ).thenReturn(
      const SurveyGuidance(
        stage: SurveyStage.idle,
        tone: SurveyTone.info,
        overallProgress: 0,
        coverageScore: 0,
        signalScore: 0,
        sparseRegion: null,
        feeds: SurveyFeedHealth(
          motionLive: true,
          wifiLive: true,
          cameraLive: true,
        ),
        readyToFinish: false,
      ),
    );

    when(
      () => arCameraPose.cameraPoseStream,
    ).thenAnswer((_) => const Stream<Offset>.empty());
    when(() => arCameraPose.start()).thenAnswer((_) {});
    when(() => arCameraPose.stop()).thenAnswer((_) async {});
    when(() => arCameraPose.clearMarkers()).thenAnswer((_) async {});
    when(
      () => arCameraPose.placeMarkerAtCamera(
        rssi: any(named: 'rssi'),
        colorArgb: any(named: 'colorArgb'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => heatmapManager.startSession(any(), any(), any()),
    ).thenAnswer((_) async {});
    when(() => heatmapManager.stopSession()).thenAnswer((_) async => null);
    when(() => heatmapManager.discardSession()).thenReturn(null);
    when(() => heatmapManager.dispose()).thenReturn(null);
    when(() => heatmapManager.setAutoSamplingEnabled(any())).thenReturn(null);

    bloc = HeatmapBloc(
      getSessions,
      repository,
      arCameraPose,
      heatmapManager,
      signalTracker,
      guidanceService,
    );
  });

  tearDown(() async {
    try {
      await bloc.close();
    } catch (_) {}
    await positionController.close();
  });

  test(
    'stopScanning selects the saved session for review and clears live session',
    () async {
      await bloc.loadSessions();
      await bloc.startScanning('Home survey');
      final session = HeatmapSession(
        id: 'live-1',
        name: 'Home survey',
        points: const [],
        createdAt: DateTime.now(),
      );
      sessionController.add(session);
      await _flush();

      gateController.add(SurveyGate.none);
      await _flush();

      final point = HeatmapPoint(
        floorX: 1,
        floorY: 1,
        rssi: -63,
        timestamp: DateTime(2026, 4, 7, 10),
        ssid: 'HomeNet',
        bssid: 'AA:BB:CC:DD:EE:FF',
      );
      await bloc.addPoint(point);

      final savedSession = session.copyWith(points: [point]);
      when(
        () => heatmapManager.stopSession(),
      ).thenAnswer((_) async => savedSession);

      await bloc.stopScanning();

      expect(bloc.state.isRecording, isFalse);
      expect(bloc.state.phase, ScanPhase.reviewing);
      expect(bloc.state.currentSession, isNull);
      expect(bloc.state.selectedSession, isNotNull);
      expect(bloc.state.selectedSession!.name, 'Home survey');
      expect(bloc.state.selectedSession!.points, hasLength(1));
    },
  );

  test('selectSession sets the review state correctly', () {
    final session = HeatmapSession(
      id: 'saved-1',
      name: 'Living room',
      points: const [],
      createdAt: DateTime(2026, 4, 7, 11),
    );

    bloc.selectSession(session);

    expect(bloc.state.selectedSession, session);
    expect(bloc.state.phase, ScanPhase.reviewing);

    bloc.clearSelection();

    expect(bloc.state.selectedSession, isNull);
    expect(bloc.state.phase, ScanPhase.idle);
  });

  test(
    'locks measurement when connection drops and resumes after relock',
    () async {
      await bloc.loadSessions();
      await bloc.startScanning('Home survey');
      final session = HeatmapSession(
        id: 'live-1',
        name: 'Home survey',
        points: const [],
        createdAt: DateTime.now(),
      );
      sessionController.add(session);
      await _flush();

      gateController.add(SurveyGate.none);
      await _flush();
      await bloc.refreshConnectedSignal();

      positionController.add(
        const PositionUpdate(x: 1, y: 0, heading: 0, isStep: true),
      );
      sessionController.add(
        session.copyWith(
          points: [
            HeatmapPoint(
              floorX: 1,
              floorY: 0,
              rssi: -63,
              timestamp: DateTime.now(),
              ssid: 'HomeNet',
              bssid: 'AA:BB:CC:DD:EE:FF',
            ),
          ],
        ),
      );
      await _flush();
      expect(bloc.state.currentSession?.points, hasLength(1));

      signalController.add(
        const SignalState(targetBssid: 'AA:BB:CC:DD:EE:FF', currentRssi: null),
      );
      gateController.add(SurveyGate.noConnectedBssid);
      await _flush();

      positionController.add(
        const PositionUpdate(x: 2, y: 0, heading: 0, isStep: true),
      );
      await _flush();

      expect(bloc.state.surveyGate, SurveyGate.noConnectedBssid);
      expect(bloc.state.currentSession?.points, hasLength(1));

      signalController.add(
        const SignalState(targetBssid: 'AA:BB:CC:DD:EE:FF', currentRssi: -66),
      );
      gateController.add(SurveyGate.none);
      await _flush();

      positionController.add(
        const PositionUpdate(x: 2, y: 0, heading: 0, isStep: true),
      );
      sessionController.add(
        session.copyWith(
          points: [
            HeatmapPoint(
              floorX: 1,
              floorY: 0,
              rssi: -63,
              timestamp: DateTime.now(),
              ssid: 'HomeNet',
              bssid: 'AA:BB:CC:DD:EE:FF',
            ),
            HeatmapPoint(
              floorX: 2,
              floorY: 0,
              rssi: -66,
              timestamp: DateTime.now(),
              ssid: 'HomeNet',
              bssid: 'AA:BB:CC:DD:EE:FF',
            ),
          ],
        ),
      );
      await _flush();

      expect(bloc.state.surveyGate, SurveyGate.none);
      expect(bloc.state.currentSession?.points, hasLength(2));
    },
  );
}

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
}
