import 'dart:async';

import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/features/heatmap/data/datasources/wall_detector_datasource.dart';
import 'package:torcav/features/heatmap/domain/entities/floor_plan.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/domain/entities/wall_segment.dart';
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

class MockWallDetectorDataSource extends Mock
    implements WallDetectorDataSource {}

class MockHeatmapManager extends Mock implements HeatmapManager {}

class MockSignalTracker extends Mock implements SignalTracker {}

class MockSurveyGuidanceService extends Mock implements SurveyGuidanceService {}

class FakeCameraImage extends Fake implements CameraImage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HeatmapBloc bloc;
  late MockGetHeatmapSessionsUsecase getSessions;
  late MockHeatmapRepository repository;
  late MockWallDetectorDataSource wallDetector;
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
    registerFallbackValue(FakeCameraImage());
    registerFallbackValue(SurveyGate.none);
    registerFallbackValue(const <HeatmapPoint>[]);
  });


  setUp(() {
    getSessions = MockGetHeatmapSessionsUsecase();
    repository = MockHeatmapRepository();
    wallDetector = MockWallDetectorDataSource();
    heatmapManager = MockHeatmapManager();
    signalTracker = MockSignalTracker();
    guidanceService = MockSurveyGuidanceService();

    sessionController = StreamController<HeatmapSession?>.broadcast();
    gateController = StreamController<SurveyGate>.broadcast();
    positionController = StreamController<PositionUpdate>.broadcast();
    signalController = StreamController<SignalState>.broadcast();

    // Reset mocks before each test
    reset(getSessions);
    reset(repository);
    reset(wallDetector);
    reset(heatmapManager);
    reset(signalTracker);
    reset(guidanceService);

    when(() => getSessions.call()).thenAnswer((_) async => const Right([]));
    when(() => heatmapManager.sessionStream).thenAnswer((_) => sessionController.stream);
    when(() => heatmapManager.gateStream).thenAnswer((_) => gateController.stream);
    when(() => heatmapManager.rawPositionStream).thenAnswer((_) => positionController.stream);
    when(() => signalTracker.stateStream).thenAnswer((_) => signalController.stream);
    when(() => signalTracker.runMetadataScan()).thenAnswer((_) async {});
    when(() => guidanceService.analyze(
          points: any(named: 'points'),
          floorPlan: any(named: 'floorPlan'),
          isRecording: any(named: 'isRecording'),
          hasArOrigin: any(named: 'hasArOrigin'),
          pendingWallCount: any(named: 'pendingWallCount'),
          currentRssi: any(named: 'currentRssi'),
          surveyGate: any(named: 'surveyGate'),
          lastSignalAt: any(named: 'lastSignalAt'),
          currentSignalStdDev: any(named: 'currentSignalStdDev'),
          currentX: any(named: 'currentX'),
          currentY: any(named: 'currentY'),
        )).thenReturn(const SurveyGuidance(
      stage: SurveyStage.idle,
      tone: SurveyTone.info,
      overallProgress: 0,
      planScore: 0,
      coverageScore: 0,
      signalScore: 0,
      sparseRegion: null,
      feeds: SurveyFeedHealth(motionLive: true, wifiLive: true, cameraLive: true, planLive: true),
      suggestAr: false,
      readyToFinish: false,
    ));

    when(() => wallDetector.detectWalls(any())).thenAnswer((_) async => []);
    when(() => heatmapManager.startSession(any(), any(), any())).thenAnswer((_) async {});
    when(() => heatmapManager.stopSession(liveWalls: any(named: 'liveWalls'))).thenAnswer((_) async {});
    when(() => heatmapManager.discardSession()).thenReturn(null);
    when(() => heatmapManager.dispose()).thenReturn(null);
    when(() => heatmapManager.setAutoSamplingEnabled(any())).thenReturn(null);

    bloc = HeatmapBloc(
      getSessions,
      repository,
      wallDetector,
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

      await bloc.addPoint(
        HeatmapPoint(
          x: 0,
          y: 0,
          floorX: 1,
          floorY: 1,
          rssi: -63,
          timestamp: DateTime(2026, 4, 7, 10),
          ssid: 'HomeNet',
          bssid: 'AA:BB:CC:DD:EE:FF',
        ),
      );

      await bloc.stopScanning();

      expect(bloc.state.isRecording, isFalse);
      expect(bloc.state.phase, ScanPhase.reviewing);
      expect(bloc.state.currentSession, isNull);
      expect(bloc.state.selectedSession, isNotNull);
      expect(bloc.state.selectedSession!.name, 'Home survey');
      expect(bloc.state.selectedSession!.points, hasLength(1));
    },
  );

  test(
    'toggleAutoSampling flips state and propagates to HeatmapManager',
    () async {
      expect(bloc.state.isAutoSampling, isTrue);

      bloc.toggleAutoSampling();
      expect(bloc.state.isAutoSampling, isFalse);
      verify(() => heatmapManager.setAutoSamplingEnabled(false)).called(1);

      bloc.toggleAutoSampling();
      expect(bloc.state.isAutoSampling, isTrue);
      verify(() => heatmapManager.setAutoSamplingEnabled(true)).called(1);
    },
  );

  test(
    'selectSession copies the saved floor plan into the visible review state',
    () {
      const plan = FloorPlan(
        walls: [WallSegment(x1: 0, y1: 0, x2: 3, y2: 0)],
        widthMeters: 3,
        heightMeters: 2,
      );
      final session = HeatmapSession(
        id: 'saved-1',
        name: 'Living room',
        points: const [],
        createdAt: DateTime(2026, 4, 7, 11),
        floorPlan: plan,
      );

      bloc.selectSession(session);

      expect(bloc.state.selectedSession, session);
      expect(bloc.state.liveFloorPlan, plan);
      expect(bloc.state.phase, ScanPhase.reviewing);

      bloc.clearSelection();

      expect(bloc.state.selectedSession, isNull);
      expect(bloc.state.liveFloorPlan, isNull);
      expect(bloc.state.phase, ScanPhase.idle);
    },
  );

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
              x: 0,
              y: 0,
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

      // Simulate connection drop via SignalTracker state
      signalController.add(const SignalState(targetBssid: 'AA:BB:CC:DD:EE:FF', currentRssi: null));
      gateController.add(SurveyGate.noConnectedBssid);
      await _flush();

      positionController.add(
        const PositionUpdate(x: 2, y: 0, heading: 0, isStep: true),
      );
      await _flush();

      expect(bloc.state.surveyGate, SurveyGate.noConnectedBssid);
      expect(bloc.state.currentSession?.points, hasLength(1));

      // Signal returns
      signalController.add(const SignalState(targetBssid: 'AA:BB:CC:DD:EE:FF', currentRssi: -66));
      gateController.add(SurveyGate.none);
      await _flush();

      positionController.add(
        const PositionUpdate(x: 2, y: 0, heading: 0, isStep: true),
      );
      sessionController.add(
        session.copyWith(
          points: [
            HeatmapPoint(
              x: 0,
              y: 0,
              floorX: 1,
              floorY: 0,
              rssi: -63,
              timestamp: DateTime.now(),
              ssid: 'HomeNet',
              bssid: 'AA:BB:CC:DD:EE:FF',
            ),
            HeatmapPoint(
              x: 0,
              y: 0,
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
