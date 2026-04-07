import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../data/datasources/position_datasource.dart';
import '../../data/datasources/wall_detector_datasource.dart';
import '../../domain/entities/floor_plan.dart';
import '../../domain/entities/heatmap_point.dart';
import '../../domain/entities/heatmap_session.dart';
import '../../domain/entities/wall_segment.dart';
import '../../domain/repositories/heatmap_repository.dart';
import '../../domain/usecases/get_heatmap_sessions_usecase.dart';
import 'scan_phase.dart';

part 'heatmap_state.dart';

@injectable
class HeatmapBloc extends Cubit<HeatmapState> {
  HeatmapBloc(
    this._getSessions,
    this._repository,
    this._wallDetector,
    this._positionEngine,
  ) : super(const HeatmapState());

  final GetHeatmapSessionsUsecase _getSessions;
  final HeatmapRepository _repository;
  final WallDetectorDataSource _wallDetector;
  final PositionDataSource _positionEngine;

  StreamSubscription<PositionUpdate>? _positionSubscription;
  StreamSubscription<int>? _rssiSubscription;

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
      ),
    );

    // Subscribe to position updates
    await _positionSubscription?.cancel();
    _positionSubscription = _positionEngine.positionStream.listen((pos) {
      _handlePositionUpdate(pos);
    });
    _positionEngine.startTracking();

    // Subscribe to RSSI updates
    // In a real device, this would come from a Wi-Fi scanning service
    // For now, we simulate or use a platform channel
  }

  void _handlePositionUpdate(PositionUpdate pos) {
    if (state.phase != ScanPhase.scanning) return;

    final offset = Offset(pos.x, pos.y);
    emit(state.copyWith(
      currentPosition: offset,
      currentHeading: pos.heading,
      lastStepTimestamp: pos.isStep ? DateTime.now() : null,
    ));

    // Auto-sample RSSI every few meters if needed, or by timer
    _sampleRssi(offset);
  }

  void _sampleRssi(Offset pos) {
    // This is where we'd call the real Wi-Fi scan
    // For demo/VIP feel, we simulate a reading based on distance from "virtual APs"
    final rssi = -40 - (pos.distance * 5).toInt();
    emit(state.copyWith(currentRssi: rssi));
    
    _recordLivePoint(pos, rssi);
  }

  void _recordLivePoint(Offset pos, int rssi) {
    final session = state.currentSession;
    if (session == null) return;

    final newPoint = HeatmapPoint(
      x: 0, // Deprecated
      y: 0, // Deprecated
      floorX: pos.dx,
      floorY: pos.dy,
      rssi: rssi,
      timestamp: DateTime.now(),
    );

    final updatedSession = session.copyWith(
      points: [...session.points, newPoint],
    );

    emit(state.copyWith(currentSession: updatedSession));
  }

  Future<void> processCameraImage(dynamic cameraImage) async {
    if (state.phase != ScanPhase.scanning) return;

    // Throttle processing if needed
    final walls = await _wallDetector.detectWalls(cameraImage);
    
    if (walls.isNotEmpty) {
      emit(state.copyWith(pendingWalls: walls));
      // In a real app, we'd integrate these into the liveFloorPlan
    }
  }

  void pauseScanning() {
    if (state.phase != ScanPhase.scanning) return;
    emit(state.copyWith(phase: ScanPhase.paused));
  }

  void resumeScanning() {
    if (state.phase != ScanPhase.paused) return;
    emit(state.copyWith(phase: ScanPhase.scanning));
  }

  void toggleArView() {
    emit(state.copyWith(isArViewEnabled: !state.isArViewEnabled));
  }

  Future<void> stopScanning() async {
    if (!state.isRecording) return;
    
    await _positionSubscription?.cancel();
    await _rssiSubscription?.cancel();

    final session = state.currentSession;
    if (session == null) return;

    // Save the session to local storage
    final result = await _repository.saveSession(session);
    
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (_) async {
        await loadSessions();
        emit(state.copyWith(
          isRecording: false,
          phase: ScanPhase.reviewing,
          currentSession: null,
          clearFailure: true,
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _rssiSubscription?.cancel();
    return super.close();
  }

  // legacy methods for backward compatibility or simple UI
  void startSession(String name) => startScanning(name);
  void stopSession() => stopScanning();
  Future<void> addPoint(HeatmapPoint point) async {
    // Map old tap-to-record to the new session
    _recordLivePoint(Offset(point.floorX, point.floorY), point.rssi);
  }

  void selectSession(HeatmapSession session) {
    emit(state.copyWith(selectedSession: session, clearFailure: true));
  }

  void clearSelection() {
    emit(state.copyWith(clearSelectedSession: true, clearFailure: true));
  }

  Future<void> deleteSession(String sessionId) async {
    final deleteResult = await _repository.deleteSession(sessionId);

    await deleteResult.fold(
      (failure) async => emit(state.copyWith(failure: failure)),
      (_) async {
        final sessionsResult = await _getSessions();
        sessionsResult.fold(
          (failure) => emit(state.copyWith(failure: failure)),
          (sessions) {
            final wasSelected = state.selectedSession?.id == sessionId;
            emit(state.copyWith(
              sessions: sessions,
              clearSelectedSession: wasSelected,
              clearFailure: true,
            ));
          },
        );
      },
    );
  }
}
