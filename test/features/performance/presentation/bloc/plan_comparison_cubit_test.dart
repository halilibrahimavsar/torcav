import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/performance/domain/entities/speed_test_result.dart';
import 'package:torcav/features/performance/domain/repositories/speed_test_history_repository.dart';
import 'package:torcav/features/performance/domain/services/isp_evidence_composer.dart';
import 'package:torcav/features/performance/domain/usecases/compare_plan_speed_usecase.dart';
import 'package:torcav/features/performance/presentation/bloc/plan_comparison_cubit.dart';
import 'package:torcav/core/settings/app_settings.dart';
import 'package:torcav/core/settings/app_settings_store.dart';

class _FakeHistory extends Fake implements SpeedTestHistoryRepository {
  List<SpeedTestResult> results = [];
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<List<SpeedTestResult>> getRecent({int limit = 20}) async =>
      results.take(limit).toList();

  void emitChange() => _changes.add(null);

  void dispose() => _changes.close();
}

class _FakeSettingsStore extends Fake implements AppSettingsStore {
  AppSettings settings = const AppSettings();
  final StreamController<AppSettings> _changes =
      StreamController<AppSettings>.broadcast();

  @override
  AppSettings get value => settings;

  @override
  Stream<AppSettings> get changes => _changes.stream;

  @override
  void update(AppSettings next) {
    settings = next;
    _changes.add(next);
  }

  @override
  void dispose() => _changes.close();
}

SpeedTestResult _result(double downloadMbps) => SpeedTestResult(
  recordedAt: DateTime(2026, 7, 7),
  latencyMs: 20,
  jitterMs: 3,
  downloadMbps: downloadMbps,
  uploadMbps: 10,
);

void main() {
  late _FakeHistory history;
  late _FakeSettingsStore settings;
  late PlanComparisonCubit cubit;

  setUp(() {
    history = _FakeHistory();
    settings = _FakeSettingsStore();
    cubit = PlanComparisonCubit(
      ComparePlanSpeedUseCase(history, settings),
      settings,
      history,
      const IspEvidenceComposer(),
    );
  });

  tearDown(() async {
    await cubit.close();
    history.dispose();
    settings.dispose();
  });

  test('load emits NoPlan when the user has not declared a plan', () async {
    await cubit.load();
    expect(cubit.state, isA<PlanComparisonNoPlan>());
  });

  test('load emits Loaded with the comparison when a plan exists', () async {
    settings.settings = const AppSettings(planDownloadMbps: 100);
    history.results = [_result(80)];

    await cubit.load();
    final state = cubit.state;
    expect(state, isA<PlanComparisonLoaded>());
    expect(
      (state as PlanComparisonLoaded).comparison.avgDownloadMbps,
      closeTo(80, 0.001),
    );
  });

  test('setPlanSpeed persists and the settings stream triggers a reload',
      () async {
    history.results = [_result(45)];
    await cubit.load();
    expect(cubit.state, isA<PlanComparisonNoPlan>());

    cubit.setPlanSpeed(100);
    await Future<void>.delayed(Duration.zero);

    expect(settings.settings.planDownloadMbps, 100);
    expect(cubit.state, isA<PlanComparisonLoaded>());
  });

  test('a new speed test in history triggers a reload', () async {
    settings.settings = const AppSettings(planDownloadMbps: 100);
    await cubit.load();
    final before = (cubit.state as PlanComparisonLoaded).comparison;
    expect(before.sampleCount, 0);

    history.results = [_result(90)];
    history.emitChange();
    await Future<void>.delayed(Duration.zero);

    final after = (cubit.state as PlanComparisonLoaded).comparison;
    expect(after.sampleCount, 1);
  });
}
