import 'dart:async';
import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/heatmap/data/datasources/ar_camera_pose_datasource.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/domain/entities/survey_gate.dart';
import 'package:torcav/features/heatmap/domain/repositories/heatmap_repository.dart';
import 'package:torcav/features/heatmap/domain/services/heatmap_manager.dart';
import 'package:torcav/features/heatmap/domain/services/signal_tier.dart';
import 'package:torcav/features/heatmap/domain/services/signal_tracker.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';
import 'package:torcav/features/heatmap/domain/usecases/get_heatmap_sessions_usecase.dart';
import 'package:torcav/features/heatmap/presentation/bloc/scan_phase.dart';

part 'heatmap_state.dart';

@injectable
class HeatmapBloc extends Cubit<HeatmapState> {
  HeatmapBloc(
    this._getSessions,
    this._repository,
    this._arCameraPose,
    this._heatmapManager,
    this._signalTracker,
    this._guidanceService,
  ) : super(const HeatmapState()) {
    _setupListeners();
  }

  final GetHeatmapSessionsUsecase _getSessions;
  final HeatmapRepository _repository;
  final ArCameraPoseDataSource _arCameraPose;
  final HeatmapManager _heatmapManager;
  final SignalTracker _signalTracker;
  final SurveyGuidanceService _guidanceService;

  StreamSubscription? _managerSessionSub;
  StreamSubscription? _managerGateSub;
  StreamSubscription? _managerPositionSub;
  StreamSubscription? _signalStateSub;
  StreamSubscription? _cameraPoseSub;
  Offset? _arOrigin;

  void _setupListeners() {
    _managerSessionSub = _heatmapManager.sessionStream.listen((session) {
      final guidance = session == null
          ? null
          : _guidanceService.analyze(
              points: session.points,
              isRecording: state.isRecording,
              currentRssi: state.currentRssi,
              surveyGate: state.surveyGate,
              lastSignalAt: state.lastSignalAt,
              currentSignalStdDev: state.lastSignalStdDev,
              currentX: state.currentPosition?.dx,
              currentY: state.currentPosition?.dy,
            );

      emit(
        state.copyWith(
          currentSession: session,
          clearCurrentSession: session == null,
          coverageScore: guidance?.coverageScore ?? 0.0,
          sparseRegion: guidance?.sparseRegion,
          clearSparseRegion: guidance?.sparseRegion == null,
        ),
      );
    });

    _managerGateSub = _heatmapManager.gateStream.listen((gate) {
      if (gate != state.surveyGate) {
        emit(state.copyWith(surveyGate: gate));
      }
    });

    _managerPositionSub = _heatmapManager.rawPositionStream.listen((pos) {
      if (!state.isRecording || state.phase != ScanPhase.scanning) return;

      final currentPos = Offset(pos.x, pos.y);
      emit(
        state.copyWith(
          currentPosition: currentPos,
          currentHeading: pos.heading,
          lastStepTimestamp:
              pos.isStep ? DateTime.now() : state.lastStepTimestamp,
        ),
      );

      _maybeAutoSample(currentPos, pos.heading);
    });

    _cameraPoseSub = _arCameraPose.cameraPoseStream.listen((rawPose) {
      if (state.phase != ScanPhase.scanning) return;
      _arOrigin ??= rawPose;
      final origin = _arOrigin!;
      final pos = Offset(rawPose.dx - origin.dx, rawPose.dy - origin.dy);

      _heatmapManager.syncPosition(pos.dx, pos.dy);
      emit(state.copyWith(currentPosition: pos));

      _maybeAutoSample(pos, state.currentHeading);
    });

    _signalStateSub = _signalTracker.stateStream.listen((signal) {
      emit(
        state.copyWith(
          currentRssi: signal.currentRssi,
          lastSignalAt: signal.lastSignalAt,
          lastSignalStdDev: signal.stdDev,
          lastSignalSampleCount: signal.sampleCount,
          targetBssid: signal.targetBssid,
          targetSsid: signal.targetSsid,
        ),
      );
    });
  }

  Future<void> loadSessions() async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final result = await _getSessions();
    result.fold(
      (failure) => emit(state.copyWith(failure: failure, isLoading: false)),
      (sessions) => emit(state.copyWith(sessions: sessions, isLoading: false)),
    );
  }

  Future<void> startScanning(String name) async {
    _arOrigin = null;
    _arCameraPose.start();
    unawaited(_arCameraPose.clearMarkers());

    emit(
      state.copyWith(
        isRecording: true,
        phase: ScanPhase.scanning,
        clearFailure: true,
        clearSelectedSession: true,
        clearCurrentRssi: true,
        clearLastSignalAt: true,
        lastSignalStdDev: 0,
        lastSignalSampleCount: 0,
        clearLastStepTimestamp: true,
        currentPosition: Offset.zero,
        currentFloor: 0,
        surveyGate: SurveyGate.none,
        clearTargetBssid: true,
        clearTargetSsid: true,
        clearLastRecordedPosition: true,
      ),
    );

    await _heatmapManager.startSession(name, null, null);
  }

  void syncPositionFromAr(double x, double y) {
    _heatmapManager.syncPosition(x, y);
    emit(state.copyWith(currentPosition: Offset(x, y)));
  }

  void pauseScanning() => emit(state.copyWith(phase: ScanPhase.paused));

  void resumeScanning() {
    emit(state.copyWith(phase: ScanPhase.scanning));
  }

  Future<void> stopScanning() async {
    if (!state.isRecording) return;
    await _arCameraPose.stop();

    final savedSession = await _heatmapManager.stopSession();

    if (savedSession != null) {
      await loadSessions();
    }

    emit(
      state.copyWith(
        isRecording: false,
        phase: ScanPhase.reviewing,
        clearCurrentSession: true,
        selectedSession: savedSession,
        surveyGate: SurveyGate.none,
        clearTargetBssid: true,
        clearTargetSsid: true,
        clearCurrentRssi: true,
        clearLastSignalAt: true,
        lastSignalStdDev: 0,
        lastSignalSampleCount: 0,
      ),
    );
  }

  Future<void> renameSession(String newName) async {
    final session = state.selectedSession;
    if (session == null) return;

    final updated = session.copyWith(name: newName);
    final result = await _repository.saveSession(updated);

    result.fold((failure) => emit(state.copyWith(failure: failure)), (_) {
      emit(state.copyWith(selectedSession: updated));
      loadSessions();
    });
  }

  Future<void> deleteSession(String sessionId) async {
    final result = await _repository.deleteSession(sessionId);

    result.fold((failure) => emit(state.copyWith(failure: failure)), (_) {
      if (state.selectedSession?.id == sessionId) {
        emit(
          state.copyWith(
            clearSelectedSession: true,
            phase: ScanPhase.idle,
          ),
        );
      }
      loadSessions();
    });
  }

  void finishSession() {
    emit(state.copyWith(phase: ScanPhase.idle, clearSelectedSession: true));
  }

  Future<void> _discardScanning() async {
    if (!state.isRecording) return;
    await _arCameraPose.stop();
    _heatmapManager.discardSession();

    emit(
      state.copyWith(
        isRecording: false,
        phase: ScanPhase.idle,
        clearCurrentSession: true,
        surveyGate: SurveyGate.none,
        clearTargetBssid: true,
        clearTargetSsid: true,
        clearCurrentRssi: true,
        clearLastSignalAt: true,
        lastSignalStdDev: 0,
        lastSignalSampleCount: 0,
      ),
    );
  }

  @override
  Future<void> close() {
    _managerSessionSub?.cancel();
    _managerGateSub?.cancel();
    _managerPositionSub?.cancel();
    _signalStateSub?.cancel();
    _cameraPoseSub?.cancel();
    return super.close();
  }

  void startSession(String name) => unawaited(startScanning(name));
  void stopSession() => unawaited(stopScanning());
  void discardSession() => unawaited(_discardScanning());

  void abortSession() => unawaited(_discardScanning());

  void restartSurvey() {
    final oldName = state.currentSession?.name ?? 'Survey';
    unawaited(() async {
      await _discardScanning();
      await startScanning(oldName);
    }());
  }

  Future<void> addPoint(HeatmapPoint point) async {
    final session = state.currentSession;
    if (session == null) return;
    emit(
      state.copyWith(
        currentSession: session.copyWith(points: [...session.points, point]),
      ),
    );
  }

  void selectSession(HeatmapSession session) {
    emit(
      state.copyWith(
        selectedSession: session,
        clearFailure: true,
        phase: ScanPhase.reviewing,
      ),
    );
  }

  void clearSelection() {
    emit(
      state.copyWith(
        clearSelectedSession: true,
        clearFailure: true,
        phase: ScanPhase.idle,
      ),
    );
  }

  /// Manually triggers a realign of the fusion heading to absolute North.
  void realignHeading() {
    _heatmapManager.realignHeading();
  }

  /// Updates the distance threshold for automatic point sampling.
  void updateAutoSamplingDistance(double distance) {
    emit(state.copyWith(autoSamplingDistance: distance));
  }

  /// Manually triggers a Wi-Fi metadata scan to refresh SSID/BSSID resolution.
  Future<void> refreshConnectedSignal() async {
    await _signalTracker.runMetadataScan();
  }

  void _maybeAutoSample(Offset currentPos, double heading) {
    if (state.currentRssi == null) return;

    final lastSignal = state.lastSignalAt;
    if (lastSignal != null &&
        DateTime.now().difference(lastSignal).inSeconds > 2) {
      return;
    }

    final lastPos = state.lastRecordedPosition;
    if (lastPos != null) {
      final dx = currentPos.dx - lastPos.dx;
      final dy = currentPos.dy - lastPos.dy;
      final distance = math.sqrt(dx * dx + dy * dy);

      if (distance < state.autoSamplingDistance) return;
    }

    _heatmapManager.recordPoint(
      floorX: currentPos.dx,
      floorY: currentPos.dy,
      heading: heading,
      rssi: state.currentRssi!,
      timestamp: DateTime.now(),
      ssid: state.targetSsid ?? '',
      bssid: state.targetBssid ?? '',
      floor: state.currentFloor,
      sampleCount: state.lastSignalSampleCount,
      rssiStdDev: state.lastSignalStdDev,
    );

    emit(state.copyWith(lastRecordedPosition: currentPos));

    final rssi = state.currentRssi!;
    final tierColor = signalGradientColor(rssi);
    unawaited(
      _arCameraPose.placeMarkerAtCamera(
        rssi: rssi,
        colorArgb: tierColor.toARGB32(),
      ),
    );
  }
}
