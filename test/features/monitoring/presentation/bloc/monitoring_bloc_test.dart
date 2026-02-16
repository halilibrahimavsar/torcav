import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/error/failures.dart';
import 'package:torcav/features/monitoring/domain/repositories/monitoring_repository.dart';
import 'package:torcav/features/monitoring/presentation/bloc/monitoring_bloc.dart';
import 'package:torcav/features/monitoring/domain/usecases/channel_analyzer.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

class MockChannelAnalyzer extends Mock implements ChannelAnalyzer {}

class MockMonitoringRepository extends Mock implements MonitoringRepository {}

void main() {
  late MonitoringBloc bloc;
  late MockMonitoringRepository repo;
  late MockChannelAnalyzer analyzer;

  setUpAll(() {
    registerFallbackValue(const Duration(seconds: 1));
  });

  setUp(() {
    repo = MockMonitoringRepository();
    analyzer = MockChannelAnalyzer();
    bloc = MonitoringBloc(repo, analyzer);
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
    'maintains history of signal strength',
    build: () {
      // Simulate stream of 3 updates
      when(
        () => repo.monitorNetwork(any(), interval: any(named: 'interval')),
      ).thenAnswer(
        (_) => Stream.fromIterable([
          Right(tNetwork.copyWith(signalStrength: -60)),
          Right(tNetwork.copyWith(signalStrength: -55)),
          Right(tNetwork.copyWith(signalStrength: -50)),
        ]),
      );
      return bloc;
    },
    act: (bloc) => bloc.add(const StartMonitoring('00:11:22:33:44:55')),
    expect:
        () => [
          MonitoringLoading(),
          isA<MonitoringActive>().having((s) => s.signalHistory, 'history 1', [
            -60,
          ]),
          isA<MonitoringActive>().having((s) => s.signalHistory, 'history 2', [
            -60,
            -55,
          ]),
          isA<MonitoringActive>().having((s) => s.signalHistory, 'history 3', [
            -60,
            -55,
            -50,
          ]),
        ],
  );

  blocTest<MonitoringBloc, MonitoringState>(
    'emits [MonitoringLoading, ChannelAnalysisReady] when AnalyzeChannels is added',
    build: () {
      when(() => analyzer.analyzeChannels(any())).thenReturn([]);
      return bloc;
    },
    act: (bloc) => bloc.add(const AnalyzeChannels([tNetwork])),
    expect: () => [MonitoringLoading(), const ChannelAnalysisReady([])],
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
