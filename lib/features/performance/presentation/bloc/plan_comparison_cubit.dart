import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../settings/domain/services/app_settings_store.dart';
import '../../domain/entities/isp_evidence_labels.dart';
import '../../domain/entities/plan_comparison.dart';
import '../../domain/repositories/speed_test_history_repository.dart';
import '../../domain/services/isp_evidence_composer.dart';
import '../../domain/usecases/compare_plan_speed_usecase.dart';

sealed class PlanComparisonState extends Equatable {
  const PlanComparisonState();

  @override
  List<Object?> get props => [];
}

class PlanComparisonInitial extends PlanComparisonState {
  const PlanComparisonInitial();
}

/// User has not declared a plan speed yet — show the enter-plan CTA.
class PlanComparisonNoPlan extends PlanComparisonState {
  const PlanComparisonNoPlan();
}

class PlanComparisonLoaded extends PlanComparisonState {
  final PlanComparison comparison;

  const PlanComparisonLoaded(this.comparison);

  @override
  List<Object?> get props => [comparison];
}

@injectable
class PlanComparisonCubit extends Cubit<PlanComparisonState> {
  final ComparePlanSpeedUseCase _compare;
  final AppSettingsStore _settings;
  final SpeedTestHistoryRepository _history;
  final IspEvidenceComposer _evidenceComposer;

  StreamSubscription<void>? _historySub;
  StreamSubscription<void>? _settingsSub;

  PlanComparisonCubit(
    this._compare,
    this._settings,
    this._history,
    this._evidenceComposer,
  ) : super(const PlanComparisonInitial()) {
    _historySub = _history.changes.listen((_) => load());
    _settingsSub = _settings.changes.listen((_) => load());
  }

  Future<void> load() async {
    final comparison = await _compare();
    if (isClosed) return;
    if (comparison == null) {
      emit(const PlanComparisonNoPlan());
    } else {
      emit(PlanComparisonLoaded(comparison));
    }
  }

  /// Persists the declared plan speed; the settings-change stream then
  /// triggers the reload.
  void setPlanSpeed(double mbps) {
    _settings.update(_settings.value.copyWith(planDownloadMbps: mbps));
  }

  /// Builds the shareable plain-text ISP evidence for the current
  /// comparison, or null when no comparison is loaded.
  Future<String?> composeIspEvidence(IspEvidenceLabels labels) async {
    final current = state;
    if (current is! PlanComparisonLoaded ||
        current.comparison.sampleCount == 0) {
      return null;
    }
    final samples = await _history.getRecent(limit: 10);
    return _evidenceComposer.compose(
      comparison: current.comparison,
      samples: samples,
      labels: labels,
    );
  }

  @override
  Future<void> close() {
    _historySub?.cancel();
    _settingsSub?.cancel();
    return super.close();
  }
}
