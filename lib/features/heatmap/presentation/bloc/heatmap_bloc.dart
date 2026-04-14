import 'dart:async';
import 'dart:math' as math;
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
import 'package:torcav/features/heatmap/data/datasources/ar_plane_scanner_datasource.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';
import 'package:torcav/features/heatmap/presentation/bloc/scan_phase.dart';

part 'heatmap_state.dart';

@injectable
class HeatmapBloc extends Cubit<HeatmapState> {
  HeatmapBloc(
    this._getSessions,
    this._repository,
    this._arPlaneScanner,
    this._heatmapManager,
    this._signalTracker,
    this._guidanceService,
  ) : super(const HeatmapState()) {
    _setupListeners();
  }

  final GetHeatmapSessionsUsecase _getSessions;
  final HeatmapRepository _repository;
  final ArPlaneScannerDataSource _arPlaneScanner;
  final HeatmapManager _heatmapManager;
  final SignalTracker _signalTracker;
  final SurveyGuidanceService _guidanceService;

  static const _flagMergeDistanceMeters = 0.5;
  static const _wallCommitRadiusMeters = 2.5;
  static const _wallStabilityMeters = 0.12;

  StreamSubscription? _managerSessionSub;
  StreamSubscription? _managerGateSub;
  StreamSubscription? _managerPositionSub;
  StreamSubscription? _signalStateSub;
  StreamSubscription? _wallScannerSub;
  StreamSubscription? _cameraPoseSub;
  Offset? _arOrigin;
  Timer? _autoWallTimer;
  WallSegment? _stableWallCandidate;

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

    _wallScannerSub = _arPlaneScanner.wallStream.listen((walls) {
      if (state.phase != ScanPhase.scanning) return;
      emit(state.copyWith(pendingWalls: walls));
      _updateAutoWallTimer(walls);
    });

    _cameraPoseSub = _arPlaneScanner.cameraPoseStream.listen((rawPose) {
      if (state.phase != ScanPhase.scanning) return;
      _arOrigin ??= rawPose;
      final origin = _arOrigin!;
      final pos = Offset(rawPose.dx - origin.dx, rawPose.dy - origin.dy);

      _heatmapManager.syncPosition(pos.dx, pos.dy);
      emit(state.copyWith(currentPosition: pos));

      if (state.isAutoSampling) {
        _maybeAutoSample(pos, state.currentHeading);
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
    _arOrigin = null;
    _arPlaneScanner.start();

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

  /// Commits the pending wall whose midpoint is closest to the user's
  /// current world position, provided it's within [_wallCommitRadiusMeters].
  void addNearestPendingWall() {
    final best = _nearestPendingWall();
    if (best != null) addWallFromAr(best);
  }

  WallSegment? _nearestPendingWall() {
    if (state.phase != ScanPhase.scanning || state.pendingWalls.isEmpty) {
      return null;
    }
    final pos = state.currentPosition ?? Offset.zero;

    WallSegment? best;
    double bestDist = double.infinity;
    for (final wall in state.pendingWalls) {
      final cx = (wall.x1 + wall.x2) / 2;
      final cy = (wall.y1 + wall.y2) / 2;
      final dx = cx - pos.dx;
      final dy = cy - pos.dy;
      final d = math.sqrt(dx * dx + dy * dy);
      if (d < bestDist) {
        bestDist = d;
        best = wall;
      }
    }
    if (best == null || bestDist > _wallCommitRadiusMeters) return null;
    return best;
  }

  void _updateAutoWallTimer(List<WallSegment> pending) {
    if (!state.isAutoWallEnabled || pending.isEmpty) {
      _autoWallTimer?.cancel();
      _stableWallCandidate = null;
      return;
    }

    final nearest = _nearestPendingWall();
    if (nearest == null) {
      _autoWallTimer?.cancel();
      _stableWallCandidate = null;
      return;
    }

    if (_stableWallCandidate != null) {
      final prevCX = (_stableWallCandidate!.x1 + _stableWallCandidate!.x2) / 2;
      final prevCY = (_stableWallCandidate!.y1 + _stableWallCandidate!.y2) / 2;
      final newCX = (nearest.x1 + nearest.x2) / 2;
      final newCY = (nearest.y1 + nearest.y2) / 2;
      final delta = math.sqrt(
        math.pow(newCX - prevCX, 2) + math.pow(newCY - prevCY, 2),
      );
      if (delta < _wallStabilityMeters) return;
    }

    _autoWallTimer?.cancel();
    _stableWallCandidate = nearest;
    _autoWallTimer = Timer(const Duration(milliseconds: 1200), () {
      if (_stableWallCandidate != null) addNearestPendingWall();
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
    await _arPlaneScanner.stop();
    _autoWallTimer?.cancel();
    _stableWallCandidate = null;

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
    await _arPlaneScanner.stop();
    _autoWallTimer?.cancel();
    _stableWallCandidate = null;
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
    _wallScannerSub?.cancel();
    _cameraPoseSub?.cancel();
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
