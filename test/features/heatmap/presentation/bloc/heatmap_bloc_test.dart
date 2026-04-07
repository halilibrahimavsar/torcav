import 'package:dartz/dartz.dart';
import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:torcav/features/heatmap/data/datasources/barometer_datasource.dart';
import 'package:torcav/features/heatmap/data/datasources/position_datasource.dart';
import 'package:torcav/features/heatmap/data/datasources/wall_detector_datasource.dart';
import 'package:torcav/features/heatmap/domain/entities/floor_plan.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/domain/entities/wall_segment.dart';
import 'package:torcav/features/heatmap/domain/repositories/heatmap_repository.dart';
import 'package:torcav/features/heatmap/domain/usecases/finalize_floor_plan.dart';
import 'package:torcav/features/heatmap/domain/usecases/get_heatmap_sessions_usecase.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';
import 'package:torcav/features/heatmap/presentation/bloc/scan_phase.dart';
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

class FakeCameraImage extends Fake implements CameraImage {}

void main() {
  late HeatmapBloc bloc;
  late MockGetHeatmapSessionsUsecase getSessions;
  late MockHeatmapRepository repository;
  late MockWallDetectorDataSource wallDetector;
  late MockPositionDataSource positionDataSource;
  late MockScanWifi scanWifi;
  late MockNetworkInfo networkInfo;
  late MockBarometerDataSource barometerDataSource;
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
  });

  setUp(() {
    getSessions = MockGetHeatmapSessionsUsecase();
    repository = MockHeatmapRepository();
    wallDetector = MockWallDetectorDataSource();
    positionDataSource = MockPositionDataSource();
    scanWifi = MockScanWifi();
    networkInfo = MockNetworkInfo();
    barometerDataSource = MockBarometerDataSource();

    when(() => getSessions.call()).thenAnswer((_) async => const Right([]));
    when(
      () => repository.saveSession(any()),
    ).thenAnswer((_) async => const Right(unit));
    when(
      () => positionDataSource.positionStream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => positionDataSource.startTracking()).thenReturn(null);
    when(() => positionDataSource.stopTracking()).thenReturn(null);
    when(
      () => barometerDataSource.floorStream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => barometerDataSource.startTracking(any())).thenReturn(null);
    when(() => barometerDataSource.stopTracking()).thenReturn(null);
    when(() => networkInfo.getWifiBSSID()).thenAnswer((_) async => null);
    when(() => wallDetector.detectWalls(any())).thenAnswer((_) async => []);

    bloc = HeatmapBloc(
      getSessions,
      repository,
      wallDetector,
      positionDataSource,
      scanWifi,
      networkInfo,
      barometerDataSource,
      FinalizeFloorPlan(),
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  test(
    'stopScanning selects the saved session for review and clears live session',
    () async {
      await bloc.startScanning('Home survey');

      await bloc.addPoint(
        HeatmapPoint(
          x: 0,
          y: 0,
          floorX: 1,
          floorY: 1,
          rssi: -63,
          timestamp: DateTime(2026, 4, 7, 10),
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
}
