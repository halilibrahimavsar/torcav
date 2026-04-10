import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:injectable/injectable.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../../../core/errors/failures.dart';
import '../../data/datasources/barometer_datasource.dart';
import '../../data/datasources/position_datasource.dart';
import '../../data/datasources/wall_detector_datasource.dart';
import '../../domain/entities/connected_signal.dart';
import '../../domain/entities/floor_plan.dart';
import '../../domain/entities/heatmap_point.dart';
import '../../domain/entities/heatmap_session.dart';
import '../../domain/entities/wall_segment.dart';
import '../../domain/repositories/heatmap_repository.dart';
import '../../domain/services/ar_capability_service.dart';
import '../../domain/services/connected_signal_service.dart';
import '../../domain/services/connected_signal_smoother.dart';
import '../../domain/usecases/finalize_floor_plan.dart';
import '../../domain/usecases/get_heatmap_sessions_usecase.dart';
import '../../../wifi_scan/domain/entities/scan_request.dart';
import '../../../wifi_scan/domain/usecases/scan_wifi.dart';
import 'scan_phase.dart';
import 'survey_gate.dart';

part 'heatmap_state.dart';

@injectable
class HeatmapBloc extends Cubit<HeatmapState> {
  HeatmapBloc(
    this._getSessions,
    this._repository,
    this._wallDetector,
    this._positionEngine,
    this._scanWifi,
    this._networkInfo,
    this._barometerSource,
    this._finalizeFloorPlan,
    this._arCapabilityService,
    this._connectedSignalService,
    this._signalSmoother,
  ) : super(const HeatmapState());

  final GetHeatmapSessionsUsecase _getSessions;
  final HeatmapRepository _repository;
  final WallDetectorDataSource _wallDetector;
  final PositionDataSource _positionEngine;
  final ScanWifi _scanWifi;
  final NetworkInfo _networkInfo;
  final BarometerDataSource _barometerSource;
  final FinalizeFloorPlan _finalizeFloorPlan;
  final ArCapabilityService _arCapabilityService;
  final ConnectedSignalService _connectedSignalService;
  final ConnectedSignalSmoother _signalSmoother;

  static const _scanCooldown = Duration(seconds: 30);
  static const _wallProcessingCooldown = Duration(milliseconds: 250);
  static const _signalPollInterval = Duration(seconds: 1);
  static const _signalFreshness = Duration(seconds: 3);
  static const _minimumPointDistanceMeters = 0.5;
  static const _flagMergeDistanceMeters = 0.65;
  static const _signalWindowSize = 5;
  static const _wallConfirmThreshold = 2;
  static const _wallCandidateTtl = Duration(milliseconds: 700);

  StreamSubscription<PositionUpdate>? _positionSubscription;
  Timer? _signalPollTimer;
  bool _isProcessingCameraFrame = false;
  DateTime? _lastWallFrameAt;
  DateTime? _lastScanTime;
  final List<int> _signalWindow = [];
  final Map<String, _WallCandidate> _wallCandidates = {};

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
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final session = HeatmapSession(
      id: id,
      name: name,
      points: const [],
      createdAt: DateTime.now(),
    );

    _signalWindow.clear();
    _wallCandidates.clear();
    _lastScanTime = null;
    _isProcessingCameraFrame = false;
    _lastWallFrameAt = null;
    _cancelSignalPolling();

    emit(
      state.copyWith(
        currentSession: session,
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
        isArViewEnabled: true,
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

    await _resolveTargetAccessPoint();
    _startSignalPolling();
    unawaited(refreshConnectedSignal());
    unawaited(runMetadataScan());

    _barometerSource.stopTracking();

    await _positionSubscription?.cancel();
    _positionEngine.stopTracking();
    _positionSubscription = _positionEngine.positionStream.listen(
      _handlePositionUpdate,
    );
    _positionEngine.startTracking();
    _refreshSurveyGate();
  }

  Future<void> _resolveTargetAccessPoint() async {
    ConnectedSignal? connectedSignal;
    try {
      connectedSignal = await _connectedSignalService.getConnectedSignal();
    } catch (e) {
      log('signal resolve error: $e');
      connectedSignal = null;
    }

    String? bssid = connectedSignal?.bssid.toUpperCase();
    String? ssid = connectedSignal?.ssid;

    if (bssid == null || bssid.isEmpty) {
      try {
        bssid = (await _networkInfo.getWifiBSSID())?.toUpperCase();
      } catch (e) {
        log('bssid resolve error: $e');
      }
    }
    if (ssid == null || ssid.isEmpty) {
      try {
        final rawSsid = await _networkInfo.getWifiName();
        ssid = rawSsid?.replaceAll('"', '');
      } catch (e) {
        log('ssid resolve error: $e');
      }
    }

    emit(
      state.copyWith(
        targetBssid: bssid,
        targetSsid: ssid,
        clearTargetBssid: bssid == null || bssid.isEmpty,
        clearTargetSsid: ssid == null || ssid.isEmpty,
      ),
    );
    _refreshSurveyGate();
  }

  void _startSignalPolling() {
    _cancelSignalPolling();
    _signalPollTimer = Timer.periodic(_signalPollInterval, (_) {
      unawaited(refreshConnectedSignal());
    });
  }

  void _cancelSignalPolling() {
    _signalPollTimer?.cancel();
    _signalPollTimer = null;
  }

  Future<void> refreshConnectedSignal() async {
    if (!state.isRecording || state.phase != ScanPhase.scanning) return;

    final sample = await _connectedSignalService.getConnectedSignal();
    if (sample == null) {
      _signalWindow.clear();
      emit(
        state.copyWith(
          clearCurrentRssi: true,
          clearLastSignalAt: true,
          lastSignalStdDev: 0,
          lastSignalSampleCount: 0,
        ),
      );
      _refreshSurveyGate(forceGate: SurveyGate.noConnectedBssid);
      return;
    }

    final normalizedBssid = sample.bssid.toUpperCase();
    final targetBssid = state.targetBssid?.toUpperCase();
    if (targetBssid == null || targetBssid.isEmpty) {
      emit(
        state.copyWith(
          targetBssid: normalizedBssid,
          targetSsid: sample.ssid.isEmpty ? state.targetSsid : sample.ssid,
        ),
      );
    } else if (normalizedBssid != targetBssid) {
      _signalWindow.clear();
      emit(
        state.copyWith(
          clearCurrentRssi: true,
          clearLastSignalAt: true,
          lastSignalStdDev: 0,
          lastSignalSampleCount: 0,
        ),
      );
      _refreshSurveyGate(forceGate: SurveyGate.noConnectedBssid);
      return;
    }

    _signalWindow.add(sample.rssi);
    if (_signalWindow.length > _signalWindowSize) {
      _signalWindow.removeAt(0);
    }

    final smoothed = _signalSmoother.smooth(_signalWindow);
    if (smoothed == null) {
      _refreshSurveyGate(forceGate: SurveyGate.staleSignal);
      return;
    }

    emit(
      state.copyWith(
        targetBssid: normalizedBssid,
        targetSsid: sample.ssid.isEmpty ? state.targetSsid : sample.ssid,
        currentRssi: smoothed.rssi,
        lastSignalAt: sample.timestamp,
        lastSignalStdDev: smoothed.stdDev,
        lastSignalSampleCount: smoothed.sampleCount,
      ),
    );

    final now = DateTime.now();
    final shouldRescan =
        _lastScanTime == null || now.difference(_lastScanTime!) > _scanCooldown;
    if (shouldRescan) {
      unawaited(runMetadataScan());
    }

    _refreshSurveyGate();
  }

  Future<void> runMetadataScan() async {
    if (!state.isRecording) return;

    _lastScanTime = DateTime.now();
    final result = await _scanWifi(
      request: const ScanRequest(passes: 3, passIntervalMs: 300),
    );
    result.fold((_) {}, (snapshot) {
      final match =
          snapshot.networks
              .where(
                (network) =>
                    network.bssid.toUpperCase() ==
                    state.targetBssid?.toUpperCase(),
              )
              .firstOrNull;
      if (match == null) return;

      emit(
        state.copyWith(
          targetSsid: match.ssid.isEmpty ? state.targetSsid : match.ssid,
          lastSignalStdDev: math.max(
            state.lastSignalStdDev,
            match.signalStdDev,
          ),
        ),
      );
    });
  }

  void _handlePositionUpdate(PositionUpdate pos) {
    if (state.phase != ScanPhase.scanning) return;

    final offset = Offset(pos.x, pos.y);
    emit(
      state.copyWith(
        currentPosition: offset,
        currentHeading: pos.heading,
        lastStepTimestamp: pos.isStep ? DateTime.now() : null,
      ),
    );

    _refreshSurveyGate();
    if (pos.isStep) {
      _recordCurrentPosition(offset);
    }
  }

  void _recordCurrentPosition(Offset pos) {
    final session = state.currentSession;
    final signalAge = _currentSignalAge;
    if (session == null ||
        state.surveyGate != SurveyGate.none ||
        state.currentRssi == null ||
        signalAge == null ||
        signalAge > _signalFreshness) {
      return;
    }

    final newPoint = HeatmapPoint(
      x: 0,
      y: 0,
      floorX: pos.dx,
      floorY: pos.dy,
      floorZ: 0,
      heading: state.currentHeading,
      rssi: state.currentRssi!,
      timestamp: state.lastSignalAt ?? DateTime.now(),
      ssid: state.targetSsid ?? '',
      bssid: state.targetBssid ?? '',
      floor: state.currentFloor,
      sampleCount: state.lastSignalSampleCount,
      rssiStdDev: state.lastSignalStdDev,
    );

    if (!_shouldRecordPoint(session, newPoint)) return;

    emit(
      state.copyWith(
        currentSession: session.copyWith(points: [...session.points, newPoint]),
      ),
    );
  }

  bool _shouldRecordPoint(HeatmapSession session, HeatmapPoint nextPoint) {
    if (session.points.isEmpty) return true;
    final lastPoint = session.points.last;
    final dx = nextPoint.floorX - lastPoint.floorX;
    final dy = nextPoint.floorY - lastPoint.floorY;
    final distance = math.sqrt(dx * dx + dy * dy);
    return distance >= _minimumPointDistanceMeters;
  }

  Duration? get _currentSignalAge {
    final lastSignalAt = state.lastSignalAt;
    if (lastSignalAt == null) return null;
    return DateTime.now().difference(lastSignalAt);
  }

  void _refreshSurveyGate({SurveyGate? forceGate}) {
    final gate = forceGate ?? _resolveSurveyGate();
    if (gate != state.surveyGate) {
      emit(state.copyWith(surveyGate: gate));
    }
  }

  SurveyGate _resolveSurveyGate() {
    if (!state.isRecording) return SurveyGate.none;
    if (state.targetBssid == null || state.targetBssid!.isEmpty) {
      return SurveyGate.noConnectedBssid;
    }
    if (state.isArSupported && !state.hasArOrigin) {
      return SurveyGate.originNotPlaced;
    }
    if (state.currentPosition == null) {
      return SurveyGate.trackingLost;
    }
    if (state.currentRssi == null) {
      return SurveyGate.noConnectedBssid;
    }
    final signalAge = _currentSignalAge;
    if (signalAge == null || signalAge > _signalFreshness) {
      return SurveyGate.staleSignal;
    }
    return SurveyGate.none;
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

      if (screenWalls.isEmpty) return;

      final pos = state.currentPosition ?? Offset.zero;
      final heading = state.currentHeading;
      final rad = heading * math.pi / 180;

      final currentPlan =
          state.liveFloorPlan ??
          const FloorPlan(walls: [], widthMeters: 40, heightMeters: 40);

      final worldWalls = List<WallSegment>.from(currentPlan.walls);

      // Expire stale candidates before processing new frame.
      _wallCandidates.removeWhere(
        (_, c) => now.difference(c.lastSeen) > _wallCandidateTtl,
      );

      for (final sw in screenWalls) {
        // Part 4: Perspective-based depth from vertical apparent size.
        final double depth;
        if (sw.y2 - sw.y1 > 0.15) {
          const vFovRad = 50.0 * math.pi / 180.0;
          final angularSize = (sw.y2 - sw.y1) * vFovRad;
          const knownWallHeightMeters = 2.5;
          final perspectiveDepth = angularSize > 0.01
              ? knownWallHeightMeters / (2 * math.tan(angularSize / 2))
              : null;
          depth = (perspectiveDepth?.clamp(1.0, 8.0) ??
                  (5.0 - (sw.y1 * 3)).clamp(1.5, 6.0))
              .toDouble();
        } else {
          depth = (5.0 - (sw.y1 * 3)).clamp(1.5, 6.0).toDouble();
        }

        // Part 2: Horizontal FOV offset — project wall left/right of center.
        const hFovRad = 60.0 * math.pi / 180.0;
        final screenOffsetX = sw.x1 - 0.5;
        final lateralAngle = screenOffsetX * hFovRad;
        final lateralOffset = depth * math.tan(lateralAngle);
        final perpRad = rad + math.pi / 2;

        // Part 1: Fixed coordinate system — cos for X, sin for Y (matches PDR).
        final worldX = pos.dx +
            depth * math.cos(rad) +
            lateralOffset * math.cos(perpRad);
        final worldY = pos.dy +
            depth * math.sin(rad) +
            lateralOffset * math.sin(perpRad);

        final newWall = WallSegment(
          x1: worldX - 0.7 * math.cos(rad),
          y1: worldY - 0.7 * math.sin(rad),
          x2: worldX + 0.7 * math.cos(rad),
          y2: worldY + 0.7 * math.sin(rad),
        );

        // Part 3: Temporal confirmation — require _wallConfirmThreshold hits.
        final cx = (newWall.x1 + newWall.x2) / 2;
        final cy = (newWall.y1 + newWall.y2) / 2;
        final key = '${cx.toStringAsFixed(1)}_${cy.toStringAsFixed(1)}';

        final existing = _wallCandidates[key];
        if (existing == null) {
          _wallCandidates[key] = _WallCandidate(
            segment: newWall,
            hits: 1,
            lastSeen: now,
          );
        } else {
          final updated = _WallCandidate(
            segment: newWall,
            hits: existing.hits + 1,
            lastSeen: now,
          );
          _wallCandidates[key] = updated;

          if (updated.hits >= _wallConfirmThreshold) {
            // Part 5: Center-based dedup at 0.5m radius.
            final alreadyExists = worldWalls.any(
              (w) => _segCenterDist(w, newWall) < 0.5,
            );
            if (!alreadyExists) {
              worldWalls.add(newWall);
            }
          }
        }
      }

      emit(
        state.copyWith(
          liveFloorPlan: currentPlan.copyWith(walls: worldWalls),
        ),
      );
    } finally {
      _isProcessingCameraFrame = false;
    }
  }

  double _segCenterDist(WallSegment a, WallSegment b) {
    final acx = (a.x1 + a.x2) / 2;
    final acy = (a.y1 + a.y2) / 2;
    final bcx = (b.x1 + b.x2) / 2;
    final bcy = (b.y1 + b.y2) / 2;
    final dx = acx - bcx, dy = acy - bcy;
    return math.sqrt(dx * dx + dy * dy);
  }

  void pauseScanning() => emit(state.copyWith(phase: ScanPhase.paused));

  void resumeScanning() {
    emit(state.copyWith(phase: ScanPhase.scanning));
    _refreshSurveyGate();
  }

  void toggleArView() =>
      emit(state.copyWith(isArViewEnabled: !state.isArViewEnabled));

  void markArOriginPlaced() {
    emit(state.copyWith(hasArOrigin: true));
    _refreshSurveyGate();
  }

  void resetArOrigin() {
    emit(state.copyWith(hasArOrigin: false));
    _refreshSurveyGate();
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

    await _positionSubscription?.cancel();
    _positionEngine.stopTracking();
    _barometerSource.stopTracking();
    _cancelSignalPolling();

    var session = state.currentSession;
    if (session == null) return;

    final walls = state.liveFloorPlan?.walls ?? [];
    if (walls.isNotEmpty) {
      final planResult = await _finalizeFloorPlan(walls);
      planResult.fold(
        (_) {},
        (plan) => session = session!.copyWith(floorPlan: plan),
      );
    }

    final savedSession = session!;
    final result = await _repository.saveSession(savedSession);
    await result.fold(
      (failure) async => emit(state.copyWith(failure: failure)),
      (_) async {
        await loadSessions();
        emit(
          state.copyWith(
            isRecording: false,
            phase: ScanPhase.reviewing,
            clearCurrentSession: true,
            selectedSession: savedSession,
            liveFloorPlan: savedSession.floorPlan,
            clearLiveFloorPlan: savedSession.floorPlan == null,
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
      },
    );
  }

  @override
  Future<void> close() {
    _cancelSignalPolling();
    _positionSubscription?.cancel();
    _positionEngine.stopTracking();
    _barometerSource.stopTracking();
    return super.close();
  }

  void startSession(String name) => unawaited(startScanning(name));

  void stopSession() => unawaited(stopScanning());

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

  Future<void> startScreenRecording() async {
    if (state.isScreenRecording) return;
    try {
      final fileName = 'torcav_ar_${DateTime.now().millisecondsSinceEpoch}';

      final result = await FlutterScreenRecording.startRecordScreen(
        fileName,
        titleNotification: 'Torcav AR Scanning',
        messageNotification: 'Recording AR Wifi Heatmap...',
      );

      if (result) {
        emit(
          state.copyWith(isScreenRecording: true, clearScreenRecordPath: true),
        );
      }
    } catch (e) {
      log('screen record start failed: $e');
    }
  }

  Future<void> stopScreenRecording() async {
    if (!state.isScreenRecording) return;
    try {
      final path = await FlutterScreenRecording.stopRecordScreen;
      if (path.isNotEmpty) {
        emit(state.copyWith(isScreenRecording: false, screenRecordPath: path));
      } else {
        emit(state.copyWith(isScreenRecording: false));
      }
    } catch (_) {
      emit(state.copyWith(isScreenRecording: false));
    }
  }
}

class _WallCandidate {
  const _WallCandidate({
    required this.segment,
    required this.hits,
    required this.lastSeen,
  });

  final WallSegment segment;
  final int hits;
  final DateTime lastSeen;
}
