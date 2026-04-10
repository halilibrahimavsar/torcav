import 'dart:async';

import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:torcav/features/heatmap/data/datasources/barometer_datasource.dart';
import 'package:torcav/features/heatmap/data/datasources/position_datasource.dart';
import 'package:torcav/features/heatmap/data/datasources/wall_detector_datasource.dart';
import 'package:torcav/features/heatmap/domain/entities/connected_signal.dart';
import 'package:torcav/features/heatmap/domain/entities/floor_plan.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/domain/entities/wall_segment.dart';
import 'package:torcav/features/heatmap/domain/repositories/heatmap_repository.dart';
import 'package:torcav/features/heatmap/domain/services/ar_capability_service.dart';
import 'package:torcav/features/heatmap/domain/services/connected_signal_service.dart';
import 'package:torcav/features/heatmap/domain/services/connected_signal_smoother.dart';
import 'package:torcav/features/heatmap/domain/usecases/finalize_floor_plan.dart';
import 'package:torcav/features/heatmap/domain/usecases/get_heatmap_sessions_usecase.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';
import 'package:torcav/features/heatmap/presentation/bloc/scan_phase.dart';
import 'package:torcav/features/heatmap/presentation/bloc/survey_gate.dart';
import 'package:torcav/features/wifi_scan/domain/entities/scan_request.dart';
import 'package:torcav/features/wifi_scan/domain/entities/scan_snapshot.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_observation.dart';
import 'package:torcav/features/wifi_scan/domain/usecases/scan_wifi.dart';

class MockGetHeatmapSessionsUsecase extends Mock
    implements GetHeatmapSessionsUsecase {}

class MockHeatmapRepository extends Mock implements HeatmapRepository {}

class MockWallDetectorDataSource extends Mock
    implements WallDetectorDataSource {}

class MockPositionDataSource extends Mock implements PositionDataSource {}

class MockScanWifi extends Mock implements ScanWifi {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockBarometerDataSource extends Mock implements BarometerDataSource {}

class MockArCapabilityService extends Mock implements ArCapabilityService {}

class MockConnectedSignalService extends Mock
    implements ConnectedSignalService {}

class FakeCameraImage extends Fake implements CameraImage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HeatmapBloc bloc;
  late MockGetHeatmapSessionsUsecase getSessions;
  late MockHeatmapRepository repository;
  late MockWallDetectorDataSource wallDetector;
  late MockPositionDataSource positionDataSource;
  late MockScanWifi scanWifi;
  late MockNetworkInfo networkInfo;
  late MockBarometerDataSource barometerDataSource;
  late MockArCapabilityService arCapabilityService;
  late MockConnectedSignalService connectedSignalService;
  late StreamController<PositionUpdate> positionController;
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
    registerFallbackValue(const ScanRequest());
  });

  setUp(() {
    positionController = StreamController<PositionUpdate>.broadcast();
    getSessions = MockGetHeatmapSessionsUsecase();
    repository = MockHeatmapRepository();
    wallDetector = MockWallDetectorDataSource();
    positionDataSource = MockPositionDataSource();
    scanWifi = MockScanWifi();
    networkInfo = MockNetworkInfo();
    barometerDataSource = MockBarometerDataSource();
    arCapabilityService = MockArCapabilityService();
    connectedSignalService = MockConnectedSignalService();

    when(() => getSessions.call()).thenAnswer((_) async => const Right([]));
    when(
      () => repository.saveSession(any()),
    ).thenAnswer((_) async => const Right(unit));
    when(
      () => positionDataSource.positionStream,
    ).thenAnswer((_) => positionController.stream);
    when(() => positionDataSource.startTracking()).thenReturn(null);
    when(() => positionDataSource.stopTracking()).thenReturn(null);
    when(() => positionDataSource.setStepLength(any())).thenReturn(null);
    when(
      () => barometerDataSource.floorStream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => barometerDataSource.startTracking(any())).thenReturn(null);
    when(() => barometerDataSource.stopTracking()).thenReturn(null);
    when(() => networkInfo.getWifiBSSID()).thenAnswer((_) async => null);
    when(() => networkInfo.getWifiName()).thenAnswer((_) async => 'HomeNet');
    when(() => wallDetector.detectWalls(any())).thenAnswer((_) async => []);
    when(
      () => arCapabilityService.isArSupported(),
    ).thenAnswer((_) async => true);
    when(
      () => connectedSignalService.getConnectedSignal(),
    ).thenAnswer((_) async => _connectedSignal(rssi: -63));
    when(
      () => scanWifi.call(request: any(named: 'request')),
    ).thenAnswer((_) async => fp.Right(_snapshot()));

    bloc = HeatmapBloc(
      getSessions,
      repository,
      wallDetector,
      positionDataSource,
      scanWifi,
      networkInfo,
      barometerDataSource,
      FinalizeFloorPlan(),
      arCapabilityService,
      connectedSignalService,
      const ConnectedSignalSmoother(),
    );
  });

  tearDown(() async {
    await bloc.close();
    await positionController.close();
  });

  test(
    'stopScanning selects the saved session for review and clears live session',
    () async {
      await bloc.loadSessions();
      await bloc.startScanning('Home survey');
      bloc.markArOriginPlaced();

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

  test('does not record step samples before AR origin is placed', () async {
    await bloc.loadSessions();
    await bloc.startScanning('Home survey');
    await _flush();

    positionController.add(
      const PositionUpdate(x: 1, y: 0, heading: 0, isStep: true),
    );
    await _flush();

    expect(bloc.state.surveyGate, SurveyGate.originNotPlaced);
    expect(bloc.state.currentSession?.points, isEmpty);

    bloc.markArOriginPlaced();
    await bloc.refreshConnectedSignal();
    positionController.add(
      const PositionUpdate(x: 1, y: 0, heading: 0, isStep: true),
    );
    await _flush();

    expect(bloc.state.surveyGate, SurveyGate.none);
    expect(bloc.state.currentSession?.points, hasLength(1));
    expect(bloc.state.currentSession?.points.single.bssid, 'AA:BB:CC:DD:EE:FF');
  });

  test(
    'locks measurement when connection drops and resumes after relock',
    () async {
      await bloc.loadSessions();
      await bloc.startScanning('Home survey');
      bloc.markArOriginPlaced();
      await bloc.refreshConnectedSignal();

      positionController.add(
        const PositionUpdate(x: 1, y: 0, heading: 0, isStep: true),
      );
      await _flush();
      expect(bloc.state.currentSession?.points, hasLength(1));

      when(
        () => connectedSignalService.getConnectedSignal(),
      ).thenAnswer((_) async => null);
      await bloc.refreshConnectedSignal();
      positionController.add(
        const PositionUpdate(x: 2, y: 0, heading: 0, isStep: true),
      );
      await _flush();

      expect(bloc.state.surveyGate, SurveyGate.noConnectedBssid);
      expect(bloc.state.currentSession?.points, hasLength(1));

      when(
        () => connectedSignalService.getConnectedSignal(),
      ).thenAnswer((_) async => _connectedSignal(rssi: -66));
      await bloc.refreshConnectedSignal();
      positionController.add(
        const PositionUpdate(x: 2, y: 0, heading: 0, isStep: true),
      );
      await _flush();

      expect(bloc.state.surveyGate, SurveyGate.none);
      expect(bloc.state.currentSession?.points, hasLength(2));
    },
  );
}

ConnectedSignal _connectedSignal({required int rssi}) {
  return ConnectedSignal(
    ssid: 'HomeNet',
    bssid: 'AA:BB:CC:DD:EE:FF',
    rssi: rssi,
    frequency: 5180,
    linkSpeedMbps: 866,
    timestamp: DateTime.now(),
  );
}

ScanSnapshot _snapshot() {
  final network = WifiNetwork(
    ssid: 'HomeNet',
    bssid: 'AA:BB:CC:DD:EE:FF',
    signalStrength: -63,
    channel: 36,
    frequency: 5180,
    security: SecurityType.wpa2,
  );

  return ScanSnapshot(
    timestamp: DateTime.now(),
    backendUsed: 'android',
    interfaceName: 'wlan0',
    networks: [WifiObservation.fromSingleNetwork(network)],
    channelStats: const [],
    bandStats: const [],
  );
}

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
}
