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
import '../../domain/entities/floor_reading.dart';
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
  StreamSubscription<FloorReading>? _barometerSubscription;

  // WiFi RSSI cache — avoids hitting Android's scan throttle (4 scans/2 min)
  List<WifiNetwork> _cachedNetworks = [];
  DateTime? _lastScanTime;
  String? _targetBssid;
  static const _scanCooldown = Duration(seconds: 30);

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

    emit(
      state.copyWith(
        currentSession: session,
        isRecording: true,
        phase: ScanPhase.scanning,
        clearFailure: true,
        currentPosition: Offset.zero,
        currentFloor: 0,
        liveFloorPlan: const FloorPlan(
          walls: [],
          widthMeters: 40,
          heightMeters: 40,
        ),
      ),
    );

    // Resolve target BSSID once so we can prefer the connected AP's RSSI.
    unawaited(_initTargetBssid());

    // Start barometer — capture baseline from first reading.
    _startBarometer();

    await _positionSubscription?.cancel();
    _positionSubscription = _positionEngine.positionStream.listen(_handlePositionUpdate);
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

  void _startBarometer() {
    // Passing 0 triggers auto-calibration from the first real sensor reading.
    _barometerSource.startTracking(0);
    _barometerSubscription = _barometerSource.floorStream.listen(_handleFloorUpdate);
  }

  void _handleFloorUpdate(FloorReading reading) {
    emit(state.copyWith(currentFloor: reading.floorIndex));
  }

  void _handlePositionUpdate(PositionUpdate pos) {
    if (state.phase != ScanPhase.scanning) return;

    final offset = Offset(pos.x, pos.y);
    emit(state.copyWith(
      currentPosition: offset,
      currentHeading: pos.heading,
      lastStepTimestamp: pos.isStep ? DateTime.now() : null,
    ));

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
      final match = _cachedNetworks
          .where((n) => n.bssid.toUpperCase() == _targetBssid)
          .firstOrNull;
      rssi = match?.signalStrength ??
          _cachedNetworks
              .map((n) => n.signalStrength)
              .reduce(math.max);
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

    final updatedSession = session.copyWith(
      points: [...session.points, newPoint],
    );

    emit(state.copyWith(currentSession: updatedSession));
  }

  Future<void> processCameraImage(dynamic cameraImage) async {
    if (state.phase != ScanPhase.scanning) return;

    // Detect screen-space features
    final screenWalls = await _wallDetector.detectWalls(cameraImage as CameraImage);
    
    if (screenWalls.isNotEmpty) {
      emit(state.copyWith(pendingWalls: screenWalls));
      
      // Project into world space
      final pos = state.currentPosition ?? Offset.zero;
      final heading = state.currentHeading;
      final rad = heading * math.pi / 180;
      
      final currentPlan = state.liveFloorPlan ?? const FloorPlan(
        walls: [],
        widthMeters: 40,
        heightMeters: 40,
      );

      final worldWalls = List<WallSegment>.from(currentPlan.walls);
      
      for (final sw in screenWalls) {
        // Projection heuristic:
        // Assume wall is somewhere in front of user.
        // Higher y in image (smaller sw.y1) = further away.
        final depth = 5.0 - (sw.y1 * 3); 
        
        final worldX = pos.dx + depth * math.sin(rad);
        final worldY = pos.dy - depth * math.cos(rad);
        
        // Horizontal orientation relative to heading
        final newWall = WallSegment(
          x1: worldX - 0.7 * math.cos(rad),
          y1: worldY - 0.7 * math.sin(rad),
          x2: worldX + 0.7 * math.cos(rad),
          y2: worldY + 0.7 * math.sin(rad),
        );

        // Deduplication
        bool exists = worldWalls.any((w) => 
          (w.x1 - newWall.x1).abs() < 0.4 && (w.y1 - newWall.y1).abs() < 0.4
        );
        if (!exists) {
          worldWalls.add(newWall);
        }
      }

      emit(state.copyWith(
        liveFloorPlan: currentPlan.copyWith(walls: worldWalls),
      ));
    }
  }

  void pauseScanning() => emit(state.copyWith(phase: ScanPhase.paused));
  void resumeScanning() => emit(state.copyWith(phase: ScanPhase.scanning));
  void toggleArView() => emit(state.copyWith(isArViewEnabled: !state.isArViewEnabled));

  Future<void> stopScanning() async {
    if (!state.isRecording) return;

    await _positionSubscription?.cancel();
    _barometerSubscription?.cancel();
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

    final result = await _repository.saveSession(session!);
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (_) async {
        await loadSessions();
        emit(state.copyWith(
          isRecording: false,
          phase: ScanPhase.reviewing,
          currentSession: null,
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _barometerSubscription?.cancel();
    _barometerSource.stopTracking();
    return super.close();
  }

  void startSession(String name) => startScanning(name);
  void stopSession() => stopScanning();
  Future<void> addPoint(HeatmapPoint point) async {
    _recordLivePoint(Offset(point.floorX, point.floorY), point.rssi);
  }

  void selectSession(HeatmapSession session) {
    emit(state.copyWith(selectedSession: session, clearFailure: true));
  }

  void clearSelection() {
    emit(state.copyWith(clearSelectedSession: true, clearFailure: true));
  }

  Future<void> deleteSession(String sessionId) async {
    final result = await _repository.deleteSession(sessionId);
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (_) async {
        await loadSessions();
        if (state.selectedSession?.id == sessionId) {
          emit(state.copyWith(clearSelectedSession: true));
        }
      },
    );
  }
}
