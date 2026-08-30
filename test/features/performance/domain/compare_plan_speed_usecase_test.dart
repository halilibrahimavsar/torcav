import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/performance/domain/entities/plan_comparison.dart';
import 'package:torcav/features/performance/domain/entities/speed_test_result.dart';
import 'package:torcav/features/performance/domain/repositories/speed_test_history_repository.dart';
import 'package:torcav/features/performance/domain/usecases/compare_plan_speed_usecase.dart';
import 'package:torcav/core/settings/app_settings.dart';
import 'package:torcav/core/settings/app_settings_store.dart';

class _FakeHistory extends Fake implements SpeedTestHistoryRepository {
  List<SpeedTestResult> results = [];

  @override
  Future<List<SpeedTestResult>> getRecent({int limit = 20}) async =>
      results.take(limit).toList();
}

class _FakeSettingsStore extends Fake implements AppSettingsStore {
  AppSettings settings = const AppSettings();

  @override
  AppSettings get value => settings;

  @override
  Stream<AppSettings> get changes => const Stream.empty();
}

SpeedTestResult _result(double downloadMbps, {DateTime? at}) =>
    SpeedTestResult(
      recordedAt: at ?? DateTime(2026, 7, 7),
      latencyMs: 20,
      jitterMs: 3,
      downloadMbps: downloadMbps,
      uploadMbps: 10,
    );

void main() {
  late _FakeHistory history;
  late _FakeSettingsStore settings;
  late ComparePlanSpeedUseCase usecase;

  setUp(() {
    history = _FakeHistory();
    settings = _FakeSettingsStore();
    usecase = ComparePlanSpeedUseCase(history, settings);
  });

  test('returns null when no plan speed is declared', () async {
    history.results = [_result(50)];
    expect(await usecase(), isNull);
  });

  test('plan set but no tests → noData verdict', () async {
    settings.settings = const AppSettings(planDownloadMbps: 100);
    final comparison = await usecase();
    expect(comparison, isNotNull);
    expect(comparison!.sampleCount, 0);
    expect(comparison.verdict, PlanVerdict.noData);
    expect(comparison.deliveredRatio, 0);
  });

  test('averages recent tests and keeps the best sample', () async {
    settings.settings = const AppSettings(planDownloadMbps: 100);
    history.results = [
      _result(90, at: DateTime(2026, 7, 7, 12)),
      _result(70, at: DateTime(2026, 7, 6, 12)),
    ];

    final comparison = await usecase();
    expect(comparison!.avgDownloadMbps, closeTo(80, 0.001));
    expect(comparison.bestDownloadMbps, 90);
    expect(comparison.sampleCount, 2);
    expect(comparison.lastSampleAt, DateTime(2026, 7, 7, 12));
    expect(comparison.verdict, PlanVerdict.delivering);
  });

  test('verdict thresholds: 80% delivering, 50% acceptable, below under',
      () async {
    settings.settings = const AppSettings(planDownloadMbps: 100);

    history.results = [_result(80)];
    expect((await usecase())!.verdict, PlanVerdict.delivering);

    history.results = [_result(79.9)];
    expect((await usecase())!.verdict, PlanVerdict.acceptable);

    history.results = [_result(50)];
    expect((await usecase())!.verdict, PlanVerdict.acceptable);

    history.results = [_result(49.9)];
    expect((await usecase())!.verdict, PlanVerdict.underDelivering);
  });

  test('respects the sample limit', () async {
    settings.settings = const AppSettings(planDownloadMbps: 100);
    history.results = List.generate(20, (i) => _result(100 - i.toDouble()));

    final comparison = await usecase(sampleLimit: 5);
    expect(comparison!.sampleCount, 5);
    // Average of 100, 99, 98, 97, 96.
    expect(comparison.avgDownloadMbps, closeTo(98, 0.001));
  });
}
