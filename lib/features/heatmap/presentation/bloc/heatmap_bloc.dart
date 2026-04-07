import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../../../core/errors/failures.dart';
import '../../data/datasources/barometer_datasource.dart';
import '../../data/datasources/position_datasource.dart';
import '../../data/datasources/wall_detector_datasource.dart';
import '../../domain/entities/floor_plan.dart';
import '../../domain/entities/heatmap_point.dart';
import '../../domain/entities/heatmap_session.dart';
import '../../domain/entities/wall_segment.dart';
import '../../domain/repositories/heatmap_repository.dart';
import '../../domain/usecases/finalize_floor_plan.dart';
import '../../domain/usecases/get_heatmap_sessions_usecase.dart';
import '../../../wifi_scan/domain/entities/scan_request.dart';
import '../../../wifi_scan/domain/entities/wifi_network.dart';
import '../../../wifi_scan/domain/usecases/scan_wifi.dart';
import 'scan_phase.dart';

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
  ) : super(const HeatmapState());

  final GetHeatmapSessionsUsecase _getSessions;
  final HeatmapRepository _repository;
  final WallDetectorDataSource _wallDetector;
  final PositionDataSource _positionEngine;
  final ScanWifi _scanWifi;
  final NetworkInfo _networkInfo;
  final BarometerDataSource _barometerSource;
  final FinalizeFloorPlan _finalizeFloorPlan;

  StreamSubscription<PositionUpdate>? _positionSubscription;
  bool _isProcessingCameraFrame = false;
  DateTime? _lastWallFrameAt;

  // WiFi RSSI cache — avoids hitting Android's scan throttle (4 scans/2 min)
  List<WifiNetwork> _cachedNetworks = [];
  DateTime? _lastScanTime;
  String? _targetBssid;
  static const _scanCooldown = Duration(seconds: 30);
  static const _wallProcessingCooldown = Duration(milliseconds: 250);

  Future<void> loadSessions() async {
    emit(state.copyWith(isLoading: true, clearFailure: true));
    final result = await _getSessions();
    result.fold(
      (failure) => emit(state.copyWith(failure: failure, isLoading: false)),
      (sessions) => emit(state.copyWith(sessions: sessions, isLoading: false)),
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

    _cachedNetworks = [];
    _lastScanTime = null;
    _targetBssid = null;
    _isProcessingCameraFrame = false;
    _lastWallFrameAt = null;

    emit(
      state.copyWith(
        currentSession: session,
        isRecording: true,
        phase: ScanPhase.scanning,
        clearFailure: true,
        clearSelectedSession: true,
        clearCurrentRssi: true,
        clearLastStepTimestamp: true,
        currentPosition: Offset.zero,
        currentFloor: 0,
        isArViewEnabled: false,
        liveFloorPlan: const FloorPlan(
          walls: [],
          widthMeters: 40,
          heightMeters: 40,
        ),
      ),
    );

    // Resolve target BSSID once so we can prefer the connected AP's RSSI.
    unawaited(_initTargetBssid());

    // Floor tracking is intentionally disabled for now.
    // On some MIUI/MediaTek devices optional sensor channels (especially
    // pressure) introduce startup jank before any survey data is collected.
    _barometerSource.stopTracking();

    await _positionSubscription?.cancel();
    _positionEngine.stopTracking();
    _positionSubscription = _positionEngine.positionStream.listen(
      _handlePositionUpdate,
    );
    _positionEngine.startTracking();
  }

  Future<void> _initTargetBssid() async {
    try {
      final bssid = await _networkInfo.getWifiBSSID();
      _targetBssid = bssid?.toUpperCase();
    } catch (_) {
      // Permission or platform error — fall back to strongest AP.
    }
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

    // Only sample RSSI and record a point on actual physical steps,
    // not on every compass heading update.
    if (pos.isStep) unawaited(_sampleRssi(offset));
  }

  Future<void> _sampleRssi(Offset pos) async {
    final now = DateTime.now();
    final shouldRescan =
        _lastScanTime == null || now.difference(_lastScanTime!) > _scanCooldown;

    if (shouldRescan) {
      _lastScanTime = now;
      final result = await _scanWifi(
        request: const ScanRequest(passes: 1, passIntervalMs: 200),
      );
      result.fold(
        (_) {}, // On failure keep using cached results.
        (snapshot) => _cachedNetworks = snapshot.toLegacyNetworks(),
      );
    }

    if (_cachedNetworks.isEmpty) return;

    final int rssi;
    if (_targetBssid != null) {
      final match =
          _cachedNetworks
              .where((n) => n.bssid.toUpperCase() == _targetBssid)
              .firstOrNull;
      rssi =
          match?.signalStrength ??
          _cachedNetworks.map((n) => n.signalStrength).reduce(math.max);
    } else {
      rssi = _cachedNetworks.map((n) => n.signalStrength).reduce(math.max);
    }

    emit(state.copyWith(currentRssi: rssi));
    _recordLivePoint(pos, rssi);
  }

  void _recordLivePoint(Offset pos, int rssi) {
    final session = state.currentSession;
    if (session == null) return;

    final newPoint = HeatmapPoint(
      x: 0,
      y: 0,
      floorX: pos.dx,
      floorY: pos.dy,
      rssi: rssi,
      floor: state.currentFloor,
      timestamp: DateTime.now(),
    );

    if (!_shouldRecordPoint(session, newPoint)) return;

    final updatedSession = session.copyWith(
      points: [...session.points, newPoint],
    );

    emit(state.copyWith(currentSession: updatedSession));
  }

  bool _shouldRecordPoint(HeatmapSession session, HeatmapPoint nextPoint) {
    if (session.points.isEmpty) return true;

    final lastPoint = session.points.last;
    final dx = nextPoint.floorX - lastPoint.floorX;
    final dy = nextPoint.floorY - lastPoint.floorY;
    final distance = math.sqrt(dx * dx + dy * dy);
    final elapsed = nextPoint.timestamp.difference(lastPoint.timestamp);
    final rssiDelta = (nextPoint.rssi - lastPoint.rssi).abs();

    final tooClose = distance < 0.35;
    final tooSoon = elapsed < const Duration(seconds: 2);
    final sameFloor = nextPoint.floor == lastPoint.floor;
    final verySimilarSignal = rssiDelta < 3;

    return !(tooClose && tooSoon && sameFloor && verySimilarSignal);
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

      for (final sw in screenWalls) {
        // Higher y in image (smaller sw.y1) roughly means the wall is further away.
        final depth = 5.0 - (sw.y1 * 3);

        final worldX = pos.dx + depth * math.sin(rad);
        final worldY = pos.dy - depth * math.cos(rad);

        final newWall = WallSegment(
          x1: worldX - 0.7 * math.cos(rad),
          y1: worldY - 0.7 * math.sin(rad),
          x2: worldX + 0.7 * math.cos(rad),
          y2: worldY + 0.7 * math.sin(rad),
        );

        final exists = worldWalls.any(
          (w) =>
              (w.x1 - newWall.x1).abs() < 0.4 &&
              (w.y1 - newWall.y1).abs() < 0.4,
        );
        if (!exists) {
          worldWalls.add(newWall);
        }
      }

      emit(
        state.copyWith(liveFloorPlan: currentPlan.copyWith(walls: worldWalls)),
      );
    } finally {
      _isProcessingCameraFrame = false;
    }
  }

  void pauseScanning() => emit(state.copyWith(phase: ScanPhase.paused));
  void resumeScanning() => emit(state.copyWith(phase: ScanPhase.scanning));
  void toggleArView() =>
      emit(state.copyWith(isArViewEnabled: !state.isArViewEnabled));

  Future<void> stopScanning() async {
    if (!state.isRecording) return;

    await _positionSubscription?.cancel();
    _positionEngine.stopTracking();
    _barometerSource.stopTracking();

    var session = state.currentSession;
    if (session == null) return;

    // Cluster accumulated walls into a clean floor plan before saving.
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
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _positionEngine.stopTracking();
    _barometerSource.stopTracking();
    return super.close();
  }

  void startSession(String name) => startScanning(name);
  void stopSession() => stopScanning();
  Future<void> addPoint(HeatmapPoint point) async {
    _recordLivePoint(Offset(point.floorX, point.floorY), point.rssi);
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
}
