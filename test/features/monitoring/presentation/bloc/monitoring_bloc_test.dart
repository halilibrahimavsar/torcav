import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/error/failures.dart';
import 'package:torcav/features/monitoring/domain/repositories/monitoring_repository.dart';
import 'package:torcav/features/monitoring/presentation/bloc/monitoring_bloc.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/features/wifi_scan/domain/services/channel_rating_engine.dart';
import 'package:torcav/features/wifi_scan/domain/services/scan_session_store.dart';
import 'package:torcav/features/wifi_scan/domain/repositories/channel_rating_repository.dart';
import 'package:torcav/features/wifi_scan/domain/usecases/get_historical_best_channel.dart';

class MockChannelRatingEngine extends Mock implements ChannelRatingEngine {}

class MockMonitoringRepository extends Mock implements MonitoringRepository {}

class MockScanSessionStore extends Mock implements ScanSessionStore {}

class MockChannelRatingRepository extends Mock
    implements ChannelRatingRepository {}

class MockGetBestHistoricalChannel extends Mock
    implements GetBestHistoricalChannel {}

void main() {
  late MonitoringBloc bloc;
  late MockMonitoringRepository repo;
  late MockChannelRatingEngine engine;
  late MockScanSessionStore sessionStore;
  late MockChannelRatingRepository historyRepo;
  late MockGetBestHistoricalChannel getHistory;

  setUpAll(() {
    registerFallbackValue(const Duration(seconds: 1));
  });

  setUp(() {
    repo = MockMonitoringRepository();
    engine = MockChannelRatingEngine();
    sessionStore = MockScanSessionStore();
    historyRepo = MockChannelRatingRepository();
    getHistory = MockGetBestHistoricalChannel();

    // Default mock behavior for session store stream
    when(() => sessionStore.snapshots).thenAnswer((_) => const Stream.empty());
    when(
      () => getHistory.call(limit: any(named: 'limit')),
    ).thenAnswer((_) async => {});
    when(
      () => historyRepo.saveRatings(any()),
    ).thenAnswer((_) async => const Right(null));

    bloc = MonitoringBloc(repo, engine, sessionStore, historyRepo, getHistory);
  });

  tearDown(() {
    bloc.close();
  });

  const tNetwork = WifiNetwork(
    ssid: 'TestNet',
    bssid: '00:11:22:33:44:55',
    signalStrength: -60,
    channel: 6,
    frequency: 2437,
    security: SecurityType.wpa2,
    vendor: 'TestVendor',
  );

  test('initial state is MonitoringInitial', () {
    expect(bloc.state, MonitoringInitial());
  });

  blocTest<MonitoringBloc, MonitoringState>(
    'emits [MonitoringLoading, MonitoringActive] when StartMonitoring is added and data is received',
    build: () {
      when(
        () => repo.monitorNetwork(any(), interval: any(named: 'interval')),
      ).thenAnswer((_) => Stream.fromIterable([Right(tNetwork)]));
      return bloc;
    },
    act: (bloc) => bloc.add(const StartMonitoring('00:11:22:33:44:55')),
    expect:
        () => [
          MonitoringLoading(),
          MonitoringActive(tNetwork, const [-60]),
        ],
  );

  blocTest<MonitoringBloc, MonitoringState>(
    'emits [MonitoringLoading, MonitoringFailure] when StartMonitoring fails',
    build: () {
      when(
        () => repo.monitorNetwork(any(), interval: any(named: 'interval')),
      ).thenAnswer(
        (_) => Stream.fromIterable([const Left(ScanFailure('Error'))]),
      );
      return bloc;
    },
    act: (bloc) => bloc.add(const StartMonitoring('00:11:22:33:44:55')),
    expect: () => [MonitoringLoading(), const MonitoringFailure('Error')],
  );

  blocTest<MonitoringBloc, MonitoringState>(
    'emits [ChannelAnalysisReady] when AnalyzeChannels is added',
    build: () {
      when(() => engine.calculateRatings(any())).thenReturn([]);
      return bloc;
    },
    act: (bloc) => bloc.add(const AnalyzeChannels([tNetwork])),
    expect:
        () => [
          isA<ChannelAnalysisReady>().having((s) => s.ratings, 'ratings', []),
        ],
  );
}

extension WifiNetworkCopy on WifiNetwork {
  WifiNetwork copyWith({int? signalStrength}) {
    return WifiNetwork(
      ssid: ssid,
      bssid: bssid,
      signalStrength: signalStrength ?? this.signalStrength,
      channel: channel,
      frequency: frequency,
      security: security,
      vendor: vendor,
      isHidden: isHidden,
    );
  }
}
