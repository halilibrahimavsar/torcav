import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/dashboard/data/datasources/score_history_local_data_source.dart';
import 'package:torcav/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:torcav/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:torcav/features/diagnostics/domain/entities/diagnosis_inputs.dart';
import 'package:torcav/features/diagnostics/domain/entities/diagnosis_result.dart';
import 'package:torcav/features/diagnostics/domain/entities/root_cause_category.dart';
import 'package:torcav/features/diagnostics/domain/usecases/diagnose_usecase.dart';
import 'package:torcav/features/diagnostics/domain/usecases/get_network_health_score_usecase.dart';
import 'package:torcav/features/heatmap/domain/entities/connected_signal.dart';
import 'package:torcav/features/heatmap/domain/services/connected_signal_service.dart';
import 'package:torcav/features/performance/domain/repositories/speed_test_history_repository.dart';
import 'package:torcav/features/security/domain/entities/network_context_type.dart';
import 'package:torcav/features/security/domain/entities/security_event.dart';
import 'package:torcav/features/security/domain/repositories/security_repository.dart';
import 'package:torcav/features/security/domain/services/network_context_resolver.dart';
import 'package:torcav/features/security/domain/usecases/security_analyzer.dart';
import 'package:torcav/features/wifi_scan/domain/entities/channel_rating.dart';
import 'package:torcav/features/wifi_scan/domain/entities/scan_snapshot.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/features/wifi_scan/domain/services/channel_rating_engine.dart';
import 'package:torcav/features/wifi_scan/domain/services/scan_session_store.dart';

import '../../../../helpers/fixtures.dart';

class _MockNetworkInfo extends Mock implements NetworkInfo {}

class _MockScanSessionStore extends Mock implements ScanSessionStore {}

class _MockSecurityAnalyzer extends Mock implements SecurityAnalyzer {}

class _MockNetworkContextResolver extends Mock
    implements NetworkContextResolver {}

class _MockScoreHistory extends Mock implements ScoreHistoryLocalDataSource {}

class _MockChannelRatingEngine extends Mock implements ChannelRatingEngine {}

class _MockConnectedSignalService extends Mock
    implements ConnectedSignalService {}

class _MockSecurityRepository extends Mock implements SecurityRepository {}

class _MockSpeedTestHistoryRepository extends Mock
    implements SpeedTestHistoryRepository {}

class _MockDiagnoseUseCase extends Mock implements DiagnoseUseCase {}

class _MockHealthScoreUseCase extends Mock
    implements GetNetworkHealthScoreUseCase {}

void main() {
  late _MockNetworkInfo networkInfo;
  late _MockScanSessionStore scanStore;
  late _MockSecurityAnalyzer securityAnalyzer;
  late _MockNetworkContextResolver contextResolver;
  late _MockScoreHistory scoreStore;
  late _MockChannelRatingEngine ratingEngine;
  late _MockConnectedSignalService signalService;
  late _MockSecurityRepository securityRepository;
  late _MockSpeedTestHistoryRepository speedRepository;
  late _MockDiagnoseUseCase diagnoseUseCase;
  late _MockHealthScoreUseCase healthScoreUseCase;
  late StreamController<ScanSnapshot> snapshotsController;

  setUpAll(() {
    registerFallbackValue(buildWifiNetwork());
    registerFallbackValue(<WifiNetwork>[]);
    registerFallbackValue(NetworkContextType.unknown);
    registerFallbackValue(
      const DiagnosisInputs(
        connectedNetwork: null,
        visibleNetworks: [],
        speedTest: null,
        gatewayPingMs: null,
        dnsBenchmark: null,
        context: NetworkContextType.unknown,
      ),
    );
    registerFallbackValue(buildSecurityAssessment());
    registerFallbackValue(
      DiagnosisResult(
        timestamp: DateTime(2026, 5, 25),
        primaryCause: RootCauseCategory.healthy,
        allEvidence: const [],
        inputs: const DiagnosisInputs(
          connectedNetwork: null,
          visibleNetworks: [],
          speedTest: null,
          gatewayPingMs: null,
          dnsBenchmark: null,
          context: NetworkContextType.unknown,
        ),
      ),
    );
  });

  setUp(() {
    networkInfo = _MockNetworkInfo();
    scanStore = _MockScanSessionStore();
    securityAnalyzer = _MockSecurityAnalyzer();
    contextResolver = _MockNetworkContextResolver();
    scoreStore = _MockScoreHistory();
    ratingEngine = _MockChannelRatingEngine();
    signalService = _MockConnectedSignalService();
    securityRepository = _MockSecurityRepository();
    speedRepository = _MockSpeedTestHistoryRepository();
    diagnoseUseCase = _MockDiagnoseUseCase();
    healthScoreUseCase = _MockHealthScoreUseCase();
    snapshotsController = StreamController<ScanSnapshot>.broadcast();

    // ---- Default stubs (each test overrides only what matters) ---------
    when(() => networkInfo.getWifiName()).thenAnswer((_) async => '"Lab AP"');
    when(() => networkInfo.getWifiIP()).thenAnswer((_) async => '192.168.1.10');
    when(
      () => networkInfo.getWifiGatewayIP(),
    ).thenAnswer((_) async => '192.168.1.1');

    when(() => scanStore.snapshots).thenAnswer((_) => snapshotsController.stream);
    when(() => scanStore.latest).thenReturn(null);
    when(() => scanStore.all).thenReturn(const []);

    when(() => speedRepository.getRecent(limit: any(named: 'limit')))
        .thenAnswer((_) async => const []);

    when(() => scoreStore.saveScore(any())).thenAnswer((_) async {});
    when(() => scoreStore.getRecentScores(limit: any(named: 'limit')))
        .thenAnswer((_) async => const []);

    when(() => ratingEngine.calculateRatings(any()))
        .thenReturn(const <ChannelRating>[]);

    when(() => signalService.getConnectedSignal()).thenAnswer((_) async => null);

    when(() => securityRepository.getSecurityEvents())
        .thenAnswer((_) async => const Right<Failure, List<SecurityEvent>>([]));

    when(() => contextResolver.resolve(any()))
        .thenAnswer((_) async => NetworkContextType.unknown);

    when(
      () => securityAnalyzer.assess(
        any(),
        localBaseline: any(named: 'localBaseline'),
        context: any(named: 'context'),
      ),
    ).thenReturn(buildSecurityAssessment());

    when(
      () => healthScoreUseCase(
        securityAssessment: any(named: 'securityAssessment'),
        diagnosisResult: any(named: 'diagnosisResult'),
      ),
    ).thenReturn(buildNetworkHealthScore());

    when(() => diagnoseUseCase(any())).thenReturn(
      DiagnosisResult(
        timestamp: DateTime(2026, 5, 25),
        primaryCause: RootCauseCategory.healthy,
        allEvidence: const [],
        inputs: const DiagnosisInputs(
          connectedNetwork: null,
          visibleNetworks: [],
          speedTest: null,
          gatewayPingMs: null,
          dnsBenchmark: null,
          context: NetworkContextType.unknown,
        ),
      ),
    );
  });

  tearDown(() async {
    await snapshotsController.close();
  });

  DashboardCubit buildCubit() => DashboardCubit(
        networkInfo,
        scanStore,
        securityAnalyzer,
        contextResolver,
        scoreStore,
        ratingEngine,
        signalService,
        securityRepository,
        speedRepository,
        diagnoseUseCase,
        healthScoreUseCase,
      );

  group('DashboardCubit.load() — empty network state', () {
    blocTest<DashboardCubit, DashboardState>(
      'emits Loading then Success with zeroed metrics when no snapshot',
      build: buildCubit,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        final state = cubit.state as DashboardSuccess;
        expect(state.networkCount, 0);
        expect(state.securityScore, 100);
        expect(state.bestChannel, isNull);
        expect(state.connectedBssid, isNull);
        expect(state.worstAssessment, isNull);
        expect(state.scoreHistory, isEmpty);
      },
    );

    test('does not call saveScore when there are no networks', () async {
      final cubit = buildCubit();
      await cubit.load();
      verifyNever(() => scoreStore.saveScore(any()));
      await cubit.close();
    });
  });

  group('DashboardCubit.load() — populated networks', () {
    final connected = buildWifiNetwork(
      
    );
    final neighbor = buildWifiNetwork(
      ssid: 'NeighborWiFi',
      bssid: '11:22:33:44:55:66',
      channel: 11,
      frequency: 2462,
    );
    final snapshot = buildScanSnapshot(networks: [connected, neighbor]);

    blocTest<DashboardCubit, DashboardState>(
      'computes worstAssessment, connectedBssid, and currentChannel',
      build: buildCubit,
      setUp: () {
        when(() => scanStore.latest).thenReturn(snapshot);
        when(() => scanStore.all).thenReturn([snapshot]);
        when(
          () => securityAnalyzer.assess(
            any(),
            localBaseline: any(named: 'localBaseline'),
            context: any(named: 'context'),
          ),
        ).thenAnswer((invocation) {
          final net = invocation.positionalArguments.first as WifiNetwork;
          return buildSecurityAssessment(score: net.ssid == 'Lab AP' ? 70 : 90);
        });
      },
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        final state = cubit.state as DashboardSuccess;
        expect(state.networkCount, 2);
        expect(state.securityScore, 70);
        expect(state.worstAssessment, isNotNull);
        expect(state.connectedBssid, 'AA:BB:CC:DD:EE:FF');
        expect(state.currentChannel, 6);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'recommends bestChannel only when rating > 7.0 and differs from current',
      build: buildCubit,
      setUp: () {
        when(() => scanStore.latest).thenReturn(snapshot);
        when(() => scanStore.all).thenReturn([snapshot]);
        when(() => ratingEngine.calculateRatings(any())).thenReturn([
          buildChannelRating(rating: 4.0),
          buildChannelRating(channel: 1),
        ]);
      },
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        final state = cubit.state as DashboardSuccess;
        expect(state.bestChannel?.channel, 1);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'bestChannel is null when top-rated channel ≤ 7.0',
      build: buildCubit,
      setUp: () {
        when(() => scanStore.latest).thenReturn(snapshot);
        when(() => scanStore.all).thenReturn([snapshot]);
        when(() => ratingEngine.calculateRatings(any())).thenReturn([
          buildChannelRating(channel: 1, rating: 6.0),
          buildChannelRating(rating: 5.0),
        ]);
      },
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        final state = cubit.state as DashboardSuccess;
        expect(state.bestChannel, isNull);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'bestChannel is null when top-rated channel is the current channel',
      build: buildCubit,
      setUp: () {
        when(() => scanStore.latest).thenReturn(snapshot);
        when(() => scanStore.all).thenReturn([snapshot]);
        when(() => ratingEngine.calculateRatings(any())).thenReturn([
          buildChannelRating(rating: 9.5),
        ]);
      },
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        final state = cubit.state as DashboardSuccess;
        expect(state.bestChannel, isNull);
      },
    );

    test('saves computed score when networks present', () async {
      when(() => scanStore.latest).thenReturn(snapshot);
      when(() => scanStore.all).thenReturn([snapshot]);
      when(
        () => securityAnalyzer.assess(
          any(),
          localBaseline: any(named: 'localBaseline'),
          context: any(named: 'context'),
        ),
      ).thenReturn(buildSecurityAssessment(score: 65));

      final cubit = buildCubit();
      await cubit.load();

      verify(() => scoreStore.saveScore(65)).called(1);
      await cubit.close();
    });
  });

  group('DashboardCubit.load() — snapshot diff', () {
    final prev = buildScanSnapshot(networks: [
      buildWifiNetwork(bssid: 'AA:AA:AA:AA:AA:AA'),
    ],);
    final latest = buildScanSnapshot(networks: [
      buildWifiNetwork(bssid: 'AA:AA:AA:AA:AA:AA'),
      buildWifiNetwork(bssid: 'BB:BB:BB:BB:BB:BB'),
      buildWifiNetwork(bssid: 'CC:CC:CC:CC:CC:CC'),
    ],);

    blocTest<DashboardCubit, DashboardState>(
      'newDeviceCount equals BSSIDs new since previous snapshot',
      build: buildCubit,
      setUp: () {
        when(() => scanStore.latest).thenReturn(latest);
        when(() => scanStore.all).thenReturn([prev, latest]);
      },
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        final state = cubit.state as DashboardSuccess;
        expect(state.newDeviceCount, 2);
      },
    );
  });

  group('DashboardCubit.load() — signal & rssi history', () {
    final snapshot = buildScanSnapshot(networks: [buildWifiNetwork()]);

    test('rssiHistory accumulates across loads and caps at 20 samples',
        () async {
      when(() => scanStore.latest).thenReturn(snapshot);
      when(() => scanStore.all).thenReturn([snapshot]);

      var rssi = -40;
      when(() => signalService.getConnectedSignal()).thenAnswer(
        (_) async => buildConnectedSignal(rssi: rssi),
      );

      final cubit = buildCubit();
      for (var i = 0; i < 25; i++) {
        rssi = -40 - i;
        when(() => signalService.getConnectedSignal()).thenAnswer(
          (_) async => buildConnectedSignal(rssi: rssi),
        );
        await cubit.load();
      }

      final state = cubit.state as DashboardSuccess;
      expect(state.rssiHistory.length, 20);
      expect(state.rssiHistory.last, rssi);
      await cubit.close();
    });

    blocTest<DashboardCubit, DashboardState>(
      'signal service errors are swallowed — signalQualityPct stays null',
      build: buildCubit,
      setUp: () {
        when(() => scanStore.latest).thenReturn(snapshot);
        when(() => scanStore.all).thenReturn([snapshot]);
        when(() => signalService.getConnectedSignal()).thenAnswer(
          (_) => Future<ConnectedSignal?>.error(StateError('platform down')),
        );
      },
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        final state = cubit.state as DashboardSuccess;
        expect(state.signalQualityPct, isNull);
      },
    );
  });

  group('DashboardCubit.load() — security events', () {
    blocTest<DashboardCubit, DashboardState>(
      'threatCount equals unread events; recentEvents capped at 20',
      build: buildCubit,
      setUp: () {
        final events = <SecurityEvent>[
          for (var i = 0; i < 25; i++)
            buildSecurityEvent(id: i, isRead: i.isEven),
        ];
        when(() => securityRepository.getSecurityEvents()).thenAnswer(
          (_) async => Right<Failure, List<SecurityEvent>>(events),
        );
      },
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        final state = cubit.state as DashboardSuccess;
        expect(state.threatCount, 12); // ids 1,3,5,...,23 are unread
        expect(state.recentEvents.length, 20);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'Left from repository yields empty events without crash',
      build: buildCubit,
      setUp: () {
        when(() => securityRepository.getSecurityEvents()).thenAnswer(
          (_) async =>
              const Left<Failure, List<SecurityEvent>>(ServerFailure('boom')),
        );
      },
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        final state = cubit.state as DashboardSuccess;
        expect(state.threatCount, 0);
        expect(state.recentEvents, isEmpty);
      },
    );
  });

  group('DashboardCubit.load() — speed & health score', () {
    final snapshot = buildScanSnapshot(networks: [buildWifiNetwork()]);

    blocTest<DashboardCubit, DashboardState>(
      'lastSpeedTest null and healthScore present when assessment exists',
      build: buildCubit,
      setUp: () {
        when(() => scanStore.latest).thenReturn(snapshot);
        when(() => scanStore.all).thenReturn([snapshot]);
        when(() => speedRepository.getRecent(limit: any(named: 'limit')))
            .thenAnswer((_) async => const []);
      },
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        final state = cubit.state as DashboardSuccess;
        expect(state.lastSpeedTest, isNull);
        expect(state.networkHealthScore, isNotNull);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'networkHealthScore null when no networks (no assessment)',
      build: buildCubit,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        final state = cubit.state as DashboardSuccess;
        expect(state.networkHealthScore, isNull);
      },
    );
  });

  group('DashboardCubit.load() — failure path', () {
    blocTest<DashboardCubit, DashboardState>(
      'emits DashboardFailure when NetworkInfo throws',
      build: buildCubit,
      setUp: () {
        when(() => networkInfo.getWifiName())
            .thenAnswer((_) async => throw StateError('permission denied'));
      },
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state, isA<DashboardFailure>());
        final failure = (cubit.state as DashboardFailure).failure;
        expect(failure, isA<ServerFailure>());
      },
    );
  });

  group('DashboardCubit — stream-driven reload & ssid hygiene', () {
    test('snapshot emission triggers another load()', () async {
      final snapshot = buildScanSnapshot(networks: [buildWifiNetwork()]);
      when(() => scanStore.latest).thenReturn(snapshot);
      when(() => scanStore.all).thenReturn([snapshot]);

      final cubit = buildCubit();
      // First load (triggered by listener) needs a tick; trigger explicitly.
      await cubit.load();
      expect(cubit.state, isA<DashboardSuccess>());

      snapshotsController.add(snapshot);
      // Allow the listener to schedule load() and await its completion.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      verify(() => networkInfo.getWifiName()).called(greaterThanOrEqualTo(2));
      await cubit.close();
    });

    blocTest<DashboardCubit, DashboardState>(
      'strips surrounding double quotes from SSID',
      build: buildCubit,
      setUp: () {
        when(() => networkInfo.getWifiName())
            .thenAnswer((_) async => '"Quoted SSID"');
      },
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        final state = cubit.state as DashboardSuccess;
        expect(state.ssid, 'Quoted SSID');
      },
    );
  });
}
