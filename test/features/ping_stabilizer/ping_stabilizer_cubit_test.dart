import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/monitoring/domain/repositories/topology_repository.dart';
import 'package:torcav/features/monitoring/domain/usecases/ping_node_usecase.dart';
import 'package:torcav/features/ping_stabilizer/data/datasources/ping_stabilizer_settings_store.dart';
import 'package:torcav/features/ping_stabilizer/domain/entities/dns_candidate.dart';
import 'package:torcav/features/ping_stabilizer/domain/entities/jitter_sample.dart';
import 'package:torcav/features/ping_stabilizer/domain/entities/stabilization_profile.dart';
import 'package:torcav/features/ping_stabilizer/domain/entities/stabilization_session.dart';
import 'package:torcav/features/ping_stabilizer/domain/repositories/ping_stabilizer_repository.dart';
import 'package:torcav/features/ping_stabilizer/domain/usecases/apply_dns_usecase.dart';
import 'package:torcav/features/ping_stabilizer/domain/usecases/baseline_ping_usecase.dart';
import 'package:torcav/features/ping_stabilizer/domain/usecases/benchmark_dns_usecase.dart';
import 'package:torcav/features/ping_stabilizer/domain/usecases/list_profiles_usecase.dart';
import 'package:torcav/features/ping_stabilizer/domain/usecases/observe_live_stats_usecase.dart';
import 'package:torcav/features/ping_stabilizer/domain/usecases/start_stabilization_usecase.dart';
import 'package:torcav/features/ping_stabilizer/domain/usecases/stop_stabilization_usecase.dart';
import 'package:torcav/features/ping_stabilizer/presentation/bloc/ping_stabilizer_cubit.dart';
import 'package:torcav/features/ping_stabilizer/presentation/bloc/ping_stabilizer_state.dart';

class _FakeRepo extends Fake implements PingStabilizerRepository {
  bool startSucceeds = true;
  final _samplesCtrl = StreamController<JitterSample>.broadcast();
  final _stoppedCtrl = StreamController<void>.broadcast();
  int startCount = 0;
  int stopCount = 0;
  int pushConfigCount = 0;
  double? lastPushedJitterThreshold;
  bool? lastPushedAutoSwitch;

  @override
  Future<Either<Failure, bool>> isVpnPrepared() async => const Right(true);

  @override
  Future<Either<Failure, bool>> requestVpnPermission() async =>
      const Right(true);

  @override
  Future<Either<Failure, StabilizationSession>> start(
    StabilizationProfile profile,
  ) async {
    startCount++;
    if (!startSucceeds) {
      return const Left(ServerFailure('boom'));
    }
    return Right(
      StabilizationSession(
        id: 'sess-$startCount',
        startedAt: DateTime.now(),
        profile: profile,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> stop() async {
    stopCount++;
    return const Right(null);
  }

  @override
  Stream<JitterSample> observeSamples() => _samplesCtrl.stream;

  @override
  Stream<void> observeTunnelStopped() => _stoppedCtrl.stream;

  @override
  Future<Either<Failure, List<DnsCandidate>>> benchmarkDns(
    List<DnsCandidate> candidates,
  ) async => Right(candidates.map((c) => c.copyWith(lastRttMs: 10)).toList());

  @override
  Future<Either<Failure, void>> setActiveDns(DnsCandidate c) async =>
      const Right(null);

  @override
  Future<void> pushNativeConfig({
    required double jitterThresholdMs,
    required bool autoSwitchDns,
    required List<DnsCandidate> candidates,
    required Map<String, String> notificationStrings,
  }) async {
    pushConfigCount++;
    lastPushedJitterThreshold = jitterThresholdMs;
    lastPushedAutoSwitch = autoSwitchDns;
  }

  @override
  Future<Either<Failure, List<StabilizationProfile>>> listProfiles() async =>
      Right(StabilizationProfile.builtIns());

  void emitStopped() => _stoppedCtrl.add(null);

  Future<void> dispose() async {
    await _samplesCtrl.close();
    await _stoppedCtrl.close();
  }
}

class _FakeTopology extends Mock implements TopologyRepository {}

class _InMemorySettings extends Fake implements PingStabilizerSettingsStore {
  bool _autoDns = false;
  double _threshold = 30;
  String? _selectedId;
  List<StabilizationProfile> _custom = const [];

  @override
  bool get autoSwitchDns => _autoDns;
  @override
  Future<void> setAutoSwitchDns(bool v) async => _autoDns = v;

  @override
  double get jitterThresholdMs => _threshold;
  @override
  Future<void> setJitterThresholdMs(double v) async => _threshold = v;

  @override
  String? get selectedProfileId => _selectedId;
  @override
  Future<void> setSelectedProfileId(String id) async => _selectedId = id;

  @override
  List<StabilizationProfile> loadCustomProfiles() => _custom;
  @override
  Future<void> saveCustomProfiles(List<StabilizationProfile> profiles) async =>
      _custom = List.of(profiles);
}

PingStabilizerCubit _build(_FakeRepo repo, {_InMemorySettings? settings}) {
  final s = settings ?? _InMemorySettings();
  final topo = _FakeTopology();
  // BaselinePingUseCase delegates to PingNodeUseCase → TopologyRepository.
  // We don't care about the baseline value in cubit tests, but the chain
  // must construct without nulls.
  when(() => topo.pingNode(any())).thenAnswer((_) async => const Right(0));
  return PingStabilizerCubit(
    StartStabilizationUseCase(repo),
    StopStabilizationUseCase(repo),
    ObserveLiveStatsUseCase(repo),
    BenchmarkDnsUseCase(repo),
    ApplyDnsUseCase(repo),
    ListProfilesUseCase(repo),
    BaselinePingUseCase(PingNodeUseCase(topo)),
    repo,
    s,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue('1.1.1.1');
  });

  group('PingStabilizerCubit', () {
    test('initial state mirrors persisted settings', () async {
      final settings =
          _InMemorySettings()
            .._autoDns = true
            .._threshold = 55;
      final repo = _FakeRepo();
      final cubit = _build(repo, settings: settings);
      expect(cubit.state.autoSwitchDns, isTrue);
      expect(cubit.state.jitterThresholdMs, 55);
      await cubit.close();
      await repo.dispose();
    });

    test('startStabilizer transitions idle → starting → active', () async {
      final repo = _FakeRepo();
      final cubit = _build(repo);
      await cubit.bootstrap();
      await cubit.startStabilizer();

      expect(cubit.state.status, StabilizerStatus.active);
      expect(cubit.state.session, isNotNull);
      expect(repo.startCount, 1);

      await cubit.close();
      await repo.dispose();
    });

    test('startStabilizer arms the native alert engine with config', () async {
      final repo = _FakeRepo();
      final cubit = _build(repo);
      await cubit.bootstrap();
      await cubit.startStabilizer();
      await Future<void>.delayed(Duration.zero);

      expect(repo.pushConfigCount, 1);
      expect(repo.lastPushedJitterThreshold, cubit.state.jitterThresholdMs);

      await cubit.close();
      await repo.dispose();
    });

    test('setAutoSwitchDns re-pushes native config', () async {
      final repo = _FakeRepo();
      final cubit = _build(repo);
      cubit.setAutoSwitchDns(true);
      await Future<void>.delayed(Duration.zero);

      expect(repo.pushConfigCount, 1);
      expect(repo.lastPushedAutoSwitch, isTrue);

      await cubit.close();
      await repo.dispose();
    });

    test(
      'native stop event resets cubit to idle without calling repo.stop()',
      () async {
        final repo = _FakeRepo();
        final cubit = _build(repo);
        await cubit.bootstrap();
        await cubit.startStabilizer();
        expect(cubit.state.status, StabilizerStatus.active);

        repo.emitStopped();
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(cubit.state.status, StabilizerStatus.idle);
        expect(cubit.state.session, isNull);
        expect(
          repo.stopCount,
          0,
          reason: 'native side already tore down — cubit must not double-stop',
        );

        await cubit.close();
        await repo.dispose();
      },
    );

    test('failure path surfaces error and lands in failure state', () async {
      final repo = _FakeRepo()..startSucceeds = false;
      final cubit = _build(repo);
      await cubit.bootstrap();
      await cubit.startStabilizer();

      expect(cubit.state.status, StabilizerStatus.failure);
      expect(cubit.state.errorMessage, isNotNull);

      await cubit.close();
      await repo.dispose();
    });

    test('setAutoSwitchDns persists', () async {
      final settings = _InMemorySettings();
      final repo = _FakeRepo();
      final cubit = _build(repo, settings: settings);
      cubit.setAutoSwitchDns(true);
      await Future<void>.delayed(Duration.zero);
      expect(settings.autoSwitchDns, isTrue);
      await cubit.close();
      await repo.dispose();
    });

    test('setJitterThreshold persists', () async {
      final settings = _InMemorySettings();
      final repo = _FakeRepo();
      final cubit = _build(repo, settings: settings);
      cubit.setJitterThreshold(80);
      await Future<void>.delayed(Duration.zero);
      expect(settings.jitterThresholdMs, 80);
      await cubit.close();
      await repo.dispose();
    });

    test('selectProfile persists selection id', () async {
      final settings = _InMemorySettings();
      final repo = _FakeRepo();
      final cubit = _build(repo, settings: settings);
      await cubit.bootstrap();
      final cs2 = StabilizationProfile.builtIns().firstWhere(
        (p) => p.id == 'cs2',
      );
      cubit.selectProfile(cs2);
      await Future<void>.delayed(Duration.zero);
      expect(settings.selectedProfileId, 'cs2');
      await cubit.close();
      await repo.dispose();
    });

    test('bootstrap restores last selected profile from settings', () async {
      final settings = _InMemorySettings().._selectedId = 'pubg_mobile';
      final repo = _FakeRepo();
      final cubit = _build(repo, settings: settings);
      await cubit.bootstrap();
      expect(cubit.state.profile?.id, 'pubg_mobile');
      await cubit.close();
      await repo.dispose();
    });
  });
}
