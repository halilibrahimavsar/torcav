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
import 'package:torcav/features/heatmap/domain/services/heatmap_manager.dart';
import 'package:torcav/features/heatmap/domain/services/signal_tracker.dart';
import 'package:torcav/features/heatmap/domain/usecases/get_heatmap_sessions_usecase.dart';
import 'package:torcav/features/heatmap/data/datasources/wall_detector_datasource.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';
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
    this._guidanceService,
  ) : super(const HeatmapState()) {
    _setupListeners();
  }

  final GetHeatmapSessionsUsecase _getSessions;
  final HeatmapRepository _repository;
  final WallDetectorDataSource _wallDetector;
  final HeatmapManager _heatmapManager;
  final SignalTracker _signalTracker;
  final SurveyGuidanceService _guidanceService;

  static const _wallProcessingCooldown = Duration(milliseconds: 250);
  static const _flagMergeDistanceMeters = 0.5;

  StreamSubscription? _managerSessionSub;
  StreamSubscription? _managerGateSub;
  StreamSubscription? _managerPositionSub;
  StreamSubscription? _signalStateSub;
  Timer? _autoWallTimer;
  WallSegment? _stableWallCandidate;
  bool _isProcessingCameraFrame = false;
  DateTime? _lastWallFrameAt;

  void _setupListeners() {
    _managerSessionSub = _heatmapManager.sessionStream.listen((session) {
      final guidance = session == null
          ? null
          : _guidanceService.analyze(
            points: session.points,
            floorPlan: state.liveFloorPlan,
            isRecording: state.isRecording,
            hasArOrigin: true, // Assuming AR origin is set for guidance
            pendingWallCount: state.pendingWalls.length,
            currentRssi: state.currentRssi,
            surveyGate: state.surveyGate,
            lastSignalAt: state.lastSignalAt,
            currentSignalStdDev: state.lastSignalStdDev,
            currentX: state.currentPosition?.dx,
            currentY: state.currentPosition?.dy,
          );

      emit(state.copyWith(
        currentSession: session,
        clearCurrentSession: session == null,
        coverageScore: guidance?.coverageScore ?? 0.0,
        sparseRegion: guidance?.sparseRegion,
        clearSparseRegion: guidance?.sparseRegion == null,
      ));
    });

    _managerGateSub = _heatmapManager.gateStream.listen((gate) {
      if (gate != state.surveyGate) {
        emit(state.copyWith(surveyGate: gate));
      }
    });

    _managerPositionSub = _heatmapManager.rawPositionStream.listen((pos) {
      if (!state.isRecording || state.phase != ScanPhase.scanning) return;
      
      final currentPos = Offset(pos.x, pos.y);
      emit(state.copyWith(
        currentPosition: currentPos,
        currentHeading: pos.heading,
        lastStepTimestamp: pos.isStep ? DateTime.now() : state.lastStepTimestamp,
      ));

      if (state.isAutoSampling) {
        _maybeAutoSample(currentPos, pos.heading);
      }
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

    final result = await _getSessions();
    result.fold(
      (failure) => emit(state.copyWith(failure: failure, isLoading: false)),
      (sessions) => emit(state.copyWith(sessions: sessions, isLoading: false)),
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
        surveyGate: SurveyGate.none,
        clearTargetBssid: true,
        clearTargetSsid: true,
        clearLastRecordedPosition: true,
      ),
    );

    await _heatmapManager.startSession(name, null, null);
  }

  /// Adds the wall segment currently closest to the reticle center (0.5, 0.5) 
  /// into the live floor plan.
  void addNearestPendingWall() {
    if (state.phase != ScanPhase.scanning || state.pendingWalls.isEmpty) return;

    // Find the wall closest to screen center (0.5, 0.5)
    WallSegment? best;
    double minDistance = double.infinity;

    for (final wall in state.pendingWalls) {
      final centerX = (wall.x1 + wall.x2) / 2;
      final centerY = (wall.y1 + wall.y2) / 2;
      final dist = math.sqrt(
        math.pow(centerX - 0.5, 2) + math.pow(centerY - 0.5, 2),
      );
      if (dist < minDistance) {
        minDistance = dist;
        best = wall;
      }
    }

    if (best != null && minDistance < 0.25) {
      final worldWall = _projectScreenToWorld(best);
      addWallFromAr(worldWall);
    }
  }

  /// Projects a normalized screen-space wall segment into metric world space
  /// using the current position, heading, and assumed camera FOV.
  WallSegment _projectScreenToWorld(WallSegment screen) {
    final pos = state.currentPosition ?? Offset.zero;
    final headingDeg = state.currentHeading;
    
    // Assumptions for basic projection without full AR anchors:
    // 1. Wall is roughly 1.8m away (typical arm's reach + room perspective).
    // 2. Camera horizontal FOV is ~60 degrees.
    const distance = 1.8;
    const hFov = 60.0;
    
    double projectPoint(double nx, double ny) {
      // Offset from center screen (0.5) to angle
      final angleOffset = (nx - 0.5) * hFov;
      final worldAngle = (headingDeg + angleOffset) * (math.pi / 180.0);
      
      // Calculate world X, Y
      // resultX = currentX + d * sin(angle)
      // resultY = currentY + d * cos(angle)
      return worldAngle; // Returning angle to use in sin/cos for X and Y
    }

    final a1 = projectPoint(screen.x1, screen.y1);
    final a2 = projectPoint(screen.x2, screen.y2);

    return WallSegment(
      x1: pos.dx + distance * math.sin(a1),
      y1: pos.dy + distance * math.cos(a1),
      x2: pos.dx + distance * math.sin(a2),
      y2: pos.dy + distance * math.cos(a2),
    );
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
      _updateAutoWallTimer(screenWalls);
    } finally {
      _isProcessingCameraFrame = false;
    }
  }

  void _updateAutoWallTimer(List<WallSegment> pending) {
    if (!state.isAutoWallEnabled || pending.isEmpty) {
      _autoWallTimer?.cancel();
      _stableWallCandidate = null;
      return;
    }

    // Find the wall closest to screen center (0.5, 0.5)
    WallSegment? nearest;
    double minDistance = double.infinity;

    for (final wall in pending) {
      final centerX = (wall.x1 + wall.x2) / 2;
      final centerY = (wall.y1 + wall.y2) / 2;
      final dist = math.sqrt(
        math.pow(centerX - 0.5, 2) + math.pow(centerY - 0.5, 2),
      );
      if (dist < minDistance) {
        minDistance = dist;
        nearest = wall;
      }
    }

    if (nearest == null || minDistance > 0.15) { // Tighter center threshold for auto-commit
      _autoWallTimer?.cancel();
      _stableWallCandidate = null;
      return;
    }

    // If the candidate is stable (didn't move much from previous center candidate)
    if (_stableWallCandidate != null) {
      final prevCX = (_stableWallCandidate!.x1 + _stableWallCandidate!.x2) / 2;
      final prevCY = (_stableWallCandidate!.y1 + _stableWallCandidate!.y2) / 2;
      final newCX = (nearest.x1 + nearest.x2) / 2;
      final newCY = (nearest.y1 + nearest.y2) / 2;
      
      final delta = math.sqrt(math.pow(newCX - prevCX, 2) + math.pow(newCY - prevCY, 2));
      
      if (delta < 0.05) {
        // Already timing this stable wall, don't restart timer
        return;
      }
    }

    // New or moved stable candidate
    _autoWallTimer?.cancel();
    _stableWallCandidate = nearest;
    _autoWallTimer = Timer(const Duration(milliseconds: 1200), () {
      if (_stableWallCandidate != null) {
        addNearestPendingWall();
      }
    });
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
    final savedSession = await _heatmapManager.stopSession(liveWalls: walls);
    
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

    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (_) {
        emit(state.copyWith(selectedSession: updated));
        loadSessions(); // Refresh the list
      },
    );
  }

  Future<void> deleteSession(String sessionId) async {
    final result = await _repository.deleteSession(sessionId);

    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (_) {
        if (state.selectedSession?.id == sessionId) {
          emit(state.copyWith(
            clearSelectedSession: true,
            clearLiveFloorPlan: true,
            phase: ScanPhase.idle,
          ));
        }
        loadSessions();
      },
    );
  }

  void finishSession() {
    emit(state.copyWith(phase: ScanPhase.idle, clearSelectedSession: true));
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
    _autoWallTimer?.cancel();
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

  void toggleAutoWall() {
    emit(state.copyWith(isAutoWallEnabled: !state.isAutoWallEnabled));
  }



  void toggleAutoSampling() {
    final next = !state.isAutoSampling;
    _heatmapManager.setAutoSamplingEnabled(next);
    emit(state.copyWith(isAutoSampling: next));
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

    // BUG-25: Guard against stale signal locks.
    // If signal hasn't updated in > 2s, don't record a point.
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

    // Threshold met or first point: record it.
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
  }
}
