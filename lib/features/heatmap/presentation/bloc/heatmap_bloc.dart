import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/domain/entities/survey_gate.dart';

import 'package:torcav/features/heatmap/domain/entities/wall_segment.dart';
import 'package:torcav/features/heatmap/domain/entities/floor_plan.dart';
import 'package:torcav/features/heatmap/domain/repositories/heatmap_repository.dart';
import 'package:torcav/features/heatmap/domain/services/ar_capability_service.dart';
import 'package:torcav/features/heatmap/domain/services/heatmap_manager.dart';
import 'package:torcav/features/heatmap/domain/services/signal_tracker.dart';
import 'package:torcav/features/heatmap/domain/usecases/get_heatmap_sessions_usecase.dart';
import 'package:torcav/features/heatmap/data/datasources/wall_detector_datasource.dart';
import 'package:torcav/features/heatmap/presentation/bloc/scan_phase.dart';

part 'heatmap_state.dart';

@injectable
class HeatmapBloc extends Cubit<HeatmapState> {
  HeatmapBloc(
    this._getSessions,
    this._repository,
    this._wallDetector,
    this._heatmapManager,
    this._signalTracker,
    this._arCapabilityService,
  ) : super(const HeatmapState()) {
    _setupListeners();
  }

  final GetHeatmapSessionsUsecase _getSessions;
  final HeatmapRepository _repository;
  final WallDetectorDataSource _wallDetector;
  final HeatmapManager _heatmapManager;
  final SignalTracker _signalTracker;
  final ArCapabilityService _arCapabilityService;

  static const _wallProcessingCooldown = Duration(milliseconds: 250);
  static const _flagMergeDistanceMeters = 0.5;

  StreamSubscription? _managerSessionSub;
  StreamSubscription? _managerGateSub;
  StreamSubscription? _managerPositionSub;
  StreamSubscription? _signalStateSub;
  bool _isProcessingCameraFrame = false;
  DateTime? _lastWallFrameAt;

  void _setupListeners() {
    _managerSessionSub = _heatmapManager.sessionStream.listen((session) {
      emit(state.copyWith(
        currentSession: session,
        clearCurrentSession: session == null,
      ));
    });

    _managerGateSub = _heatmapManager.gateStream.listen((gate) {
      if (gate != state.surveyGate) {
        emit(state.copyWith(surveyGate: gate));
      }
    });

    _managerPositionSub = _heatmapManager.rawPositionStream.listen((pos) {
      if (!state.isRecording || state.phase != ScanPhase.scanning) return;
      emit(state.copyWith(
        currentPosition: Offset(pos.x, pos.y),
        currentHeading: pos.heading,
        lastStepTimestamp: pos.isStep ? DateTime.now() : state.lastStepTimestamp,
      ));
    });

    _signalStateSub = _signalTracker.stateStream.listen((signal) {
      emit(state.copyWith(
        currentRssi: signal.currentRssi,
        lastSignalAt: signal.lastSignalAt,
        lastSignalStdDev: signal.stdDev,
        lastSignalSampleCount: signal.sampleCount,
        targetBssid: signal.targetBssid,
        targetSsid: signal.targetSsid,
      ));
    });
  }

  Future<void> loadSessions() async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final isArSupported = await _arCapabilityService.isArSupported();
    final result = await _getSessions();
    result.fold(
      (failure) => emit(
        state.copyWith(
          failure: failure,
          isLoading: false,
          isArSupported: isArSupported,
        ),
      ),
      (sessions) => emit(
        state.copyWith(
          sessions: sessions,
          isLoading: false,
          isArSupported: isArSupported,
        ),
      ),
    );
  }

  Future<void> startScanning(String name) async {
    _isProcessingCameraFrame = false;
    _lastWallFrameAt = null;

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
        liveFloorPlan: const FloorPlan(
          walls: [],
          widthMeters: 40,
          heightMeters: 40,
        ),
        hasArOrigin: false,
        surveyGate:
            state.isArSupported
                ? SurveyGate.originNotPlaced
                : SurveyGate.noConnectedBssid,
        clearTargetBssid: true,
        clearTargetSsid: true,
      ),
    );

    await _heatmapManager.startSession(name, null, null);
  }

  Future<void> processCameraImage(dynamic cameraImage) async {
    if (state.phase != ScanPhase.scanning) return;
    final now = DateTime.now();
    if (_isProcessingCameraFrame) return;
    if (_lastWallFrameAt != null &&
        now.difference(_lastWallFrameAt!) < _wallProcessingCooldown) {
      return;
    }

    _isProcessingCameraFrame = true;
    _lastWallFrameAt = now;

    try {
      final screenWalls = await _wallDetector.detectWalls(
        cameraImage as CameraImage,
      );
      emit(state.copyWith(pendingWalls: screenWalls));
    } finally {
      _isProcessingCameraFrame = false;
    }
  }

  void addWallFromAr(WallSegment wall) {
    if (state.phase != ScanPhase.scanning) return;

    final currentPlan =
        state.liveFloorPlan ??
        const FloorPlan(walls: [], widthMeters: 40, heightMeters: 40);

    final walls = _heatmapManager.addWall(currentPlan.walls, wall);

    emit(state.copyWith(liveFloorPlan: currentPlan.copyWith(walls: walls)));
  }

  void syncPositionFromAr(double x, double y) {
    _heatmapManager.syncPosition(x, y);
    emit(state.copyWith(currentPosition: Offset(x, y)));
  }

  void pauseScanning() => emit(state.copyWith(phase: ScanPhase.paused));

  void resumeScanning() {
    emit(state.copyWith(phase: ScanPhase.scanning));
  }


  void markArOriginPlaced(double currentHeading) {
    // ARCore -Z (forward) is typically 0 radians in its local frame if started
    // facing forward. Our projection math in _SignalLabelOverlay expects
    // 'Forward' to be 90 degrees (relative to local X axis).
    //
    // So we calculate the offset needed to rotate the absolute compass heading
    // so that the current heading becomes '90' in our projection space.
    final offset = currentHeading - 90.0;

    emit(
      state.copyWith(
        hasArOrigin: true,
        arOriginHeadingOffset: offset,
      ),
    );
  }

  void resetArOrigin() {
    emit(state.copyWith(hasArOrigin: false, arOriginHeadingOffset: 0.0));
  }

  void recalibrateHeading() {
    if (!state.hasArOrigin) return;
    markArOriginPlaced(state.currentHeading);
  }

  Future<void> flagCurrentWeakZone() async {
    final session = state.currentSession;
    final pos = state.currentPosition;
    final rssi = state.currentRssi;
    if (session == null || pos == null || rssi == null) return;

    final points = [...session.points];
    final existingIndex = points.indexWhere((point) {
      final dx = point.floorX - pos.dx;
      final dy = point.floorY - pos.dy;
      return math.sqrt(dx * dx + dy * dy) <= _flagMergeDistanceMeters;
    });

    if (existingIndex != -1) {
      points[existingIndex] = points[existingIndex].copyWith(isFlagged: true);
    } else {
      points.add(
        HeatmapPoint(
          x: 0,
          y: 0,
          floorX: pos.dx,
          floorY: pos.dy,
          floorZ: 0,
          heading: state.currentHeading,
          rssi: rssi,
          timestamp: state.lastSignalAt ?? DateTime.now(),
          ssid: state.targetSsid ?? '',
          bssid: state.targetBssid ?? '',
          floor: state.currentFloor,
          sampleCount: state.lastSignalSampleCount,
          rssiStdDev: state.lastSignalStdDev,
          isFlagged: true,
        ),
      );
    }

    emit(state.copyWith(currentSession: session.copyWith(points: points)));
  }

  Future<void> stopScanning() async {
    if (!state.isRecording) return;

    final walls = state.liveFloorPlan?.walls ?? [];
    await _heatmapManager.stopSession(liveWalls: walls);
    
    final savedSession = state.currentSession;

    if (savedSession != null) {
      await loadSessions();
    }

    emit(
      state.copyWith(
        isRecording: false,
        phase: ScanPhase.reviewing,
        clearCurrentSession: true,
        selectedSession: savedSession,
        liveFloorPlan: savedSession?.floorPlan,
        clearLiveFloorPlan: savedSession?.floorPlan == null,
        pendingWalls: const [],
        surveyGate: SurveyGate.none,
        hasArOrigin: false,
        clearTargetBssid: true,
        clearTargetSsid: true,
        clearCurrentRssi: true,
        clearLastSignalAt: true,
        lastSignalStdDev: 0,
        lastSignalSampleCount: 0,
      ),
    );
  }

  Future<void> _discardScanning() async {
    if (!state.isRecording) return;
    _heatmapManager.discardSession();

    emit(
      state.copyWith(
        isRecording: false,
        phase: ScanPhase.idle,
        clearCurrentSession: true,
        clearLiveFloorPlan: true,
        pendingWalls: const [],
        surveyGate: SurveyGate.none,
        hasArOrigin: false,
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
    _heatmapManager.dispose();
    return super.close();
  }

  void startSession(String name) => unawaited(startScanning(name));
  void stopSession() => unawaited(stopScanning());
  void discardSession() => unawaited(_discardScanning());

  void finishSession() => unawaited(stopScanning());
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
        liveFloorPlan: session.floorPlan,
        clearLiveFloorPlan: session.floorPlan == null,
        clearFailure: true,
        phase: ScanPhase.reviewing,
      ),
    );
  }

  void clearSelection() {
    emit(
      state.copyWith(
        clearSelectedSession: true,
        clearLiveFloorPlan: true,
        clearFailure: true,
        phase: ScanPhase.idle,
      ),
    );
  }

  void viewInAr() {
    if (state.selectedSession == null) return;
    emit(state.copyWith(
      isViewingInAr: true,
      hasArOrigin: false,
      arOriginHeadingOffset: 0.0,
      clearFailure: true,
    ));
  }

  void exitArView() {
    emit(state.copyWith(
      isViewingInAr: false,
      hasArOrigin: false,
      arOriginHeadingOffset: 0.0,
    ));
  }

  Future<void> deleteSession(String sessionId) async {
    final result = await _repository.deleteSession(sessionId);
    await result.fold(
      (failure) async => emit(state.copyWith(failure: failure)),
      (_) async {
        await loadSessions();
        if (state.selectedSession?.id == sessionId) {
          emit(
            state.copyWith(
              clearSelectedSession: true,
              clearLiveFloorPlan: true,
            ),
          );
        }
      },
    );
  }

  void toggleAutoSampling() {
    emit(state.copyWith(isAutoSampling: !state.isAutoSampling));
  }

  /// Manually triggers a Wi-Fi metadata scan to refresh SSID/BSSID resolution.
  Future<void> refreshConnectedSignal() async {
    await _signalTracker.runMetadataScan();
  }
}
