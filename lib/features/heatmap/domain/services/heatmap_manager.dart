import 'dart:async';
import 'package:injectable/injectable.dart';

import 'package:torcav/features/heatmap/data/datasources/barometer_datasource.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/domain/entities/position_update.dart';
import 'package:torcav/features/heatmap/domain/entities/survey_gate.dart';
import 'package:torcav/features/heatmap/domain/repositories/heatmap_repository.dart';
import 'package:torcav/features/heatmap/domain/services/position_tracker.dart';
import 'package:torcav/features/heatmap/domain/services/signal_tracker.dart';

/// Orchestrator service that manages a live heatmap scanning session.
/// Coordinates SignalTracker and PositionTracker.
@LazySingleton()
class HeatmapManager {
  HeatmapManager(
    this._signalTracker,
    this._positionTracker,
    this._repository,
    this._barometerSource,
  );

  final SignalTracker _signalTracker;
  final PositionTracker _positionTracker;
  final HeatmapRepository _repository;
  final BarometerDataSource _barometerSource;

  static const _minimumPointDistanceMeters = 0.5;
  static const _signalFreshnessSeconds = 3;

  HeatmapSession? _currentSession;
  HeatmapSession? get currentSession => _currentSession;

  final _sessionController = StreamController<HeatmapSession?>.broadcast();
  Stream<HeatmapSession?> get sessionStream => _sessionController.stream;

  Stream<PointCandidate> get positionStream => _positionTracker.candidateStream;

  Stream<PositionUpdate> get rawPositionStream => _positionTracker.rawPositionStream;

  final _gateController = StreamController<SurveyGate>.broadcast();
  Stream<SurveyGate> get gateStream => _gateController.stream;

  SignalState _lastSignalState = const SignalState();
  StreamSubscription? _signalSub;
  StreamSubscription? _positionSub;
  bool _autoSamplingEnabled = true;

  /// Toggles automatic recording on step candidates. When false the manager
  /// stops auto-recording points; the user must explicitly record via the
  /// reticle (flag) action.
  void setAutoSamplingEnabled(bool enabled) {
    _autoSamplingEnabled = enabled;
  }

  /// Start a new scanning session
  Future<void> startSession(String name, String? bssid, String? ssid) async {
    _currentSession = HeatmapSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      points: const [],
      createdAt: DateTime.now(),
    );
    _sessionController.add(_currentSession);

    _signalSub?.cancel();
    _signalSub = _signalTracker.stateStream.listen(_onSignalUpdate);
    await _signalTracker.start(bssid, ssid);

    _positionSub?.cancel();
    _positionSub = _positionTracker.candidateStream.listen(_onPositionCandidate);
    _positionTracker.start(0.0, 0.0);

    _barometerSource.stopTracking(); // Ensure fresh start
  }

  /// Stop and save the session, returning the finalized session
  Future<HeatmapSession?> stopSession() async {
    _signalTracker.stop();
    _positionTracker.stop();
    _barometerSource.stopTracking();

    if (_currentSession == null) return null;

    final finalSession = _currentSession!;
    await _repository.saveSession(finalSession);
    _currentSession = null;
    _sessionController.add(null);

    return finalSession;
  }

  /// Discard the current session
  void discardSession() {
    _signalTracker.stop();
    _positionTracker.stop();
    _barometerSource.stopTracking();
    _currentSession = null;
    _sessionController.add(null);
  }

  void _onSignalUpdate(SignalState signal) {
    _lastSignalState = signal;
    _updateGate();
  }

  void _onPositionCandidate(PointCandidate candidate) {
    if (_currentSession == null) return;
    if (!_autoSamplingEnabled) return;

    // Validate if we should record
    if (!_validateSignalFreshness()) {
      _gateController.add(SurveyGate.staleSignal);
      return;
    }

    if (!_positionTracker.shouldRecordPoint(
      _currentSession!, 
      candidate.x, 
      candidate.y, 
      _minimumPointDistanceMeters,
    )) {
      return;
    }

    final newPoint = HeatmapPoint(
      x: 0, y: 0,
      floorX: candidate.x,
      floorY: candidate.y,
      floorZ: 0,
      heading: candidate.heading,
      rssi: _lastSignalState.currentRssi ?? 0,
      timestamp: _lastSignalState.lastSignalAt ?? DateTime.now(),
      ssid: _lastSignalState.targetSsid ?? '',
      bssid: _lastSignalState.targetBssid ?? '',
      floor: 0, // Floor tracking can be added here
      sampleCount: _lastSignalState.sampleCount,
      rssiStdDev: _lastSignalState.stdDev,
    );

    _currentSession = _currentSession!.copyWith(
      points: [..._currentSession!.points, newPoint],
    );
    _positionTracker.markPointRecorded(candidate.x, candidate.y);
    _sessionController.add(_currentSession);
  }

  /// Manually records a point for the current session.
  void recordPoint({
    required double floorX,
    required double floorY,
    required double heading,
    required int rssi,
    required DateTime timestamp,
    required String ssid,
    required String bssid,
    required int floor,
    required int sampleCount,
    required double rssiStdDev,
  }) {
    if (_currentSession == null) return;

    final newPoint = HeatmapPoint(
      x: 0,
      y: 0,
      floorX: floorX,
      floorY: floorY,
      floorZ: 0,
      heading: heading,
      rssi: rssi,
      timestamp: timestamp,
      ssid: ssid,
      bssid: bssid,
      floor: floor,
      sampleCount: sampleCount,
      rssiStdDev: rssiStdDev,
    );

    _currentSession = _currentSession!.copyWith(
      points: [..._currentSession!.points, newPoint],
    );
    _sessionController.add(_currentSession);
  }

  bool _validateSignalFreshness() {
    if (_lastSignalState.currentRssi == null || _lastSignalState.lastSignalAt == null) return false;
    final age = DateTime.now().difference(_lastSignalState.lastSignalAt!).inSeconds;
    return age <= _signalFreshnessSeconds;
  }

  void _updateGate() {
    // Basic gate logic moved here, can be expanded
    if (_lastSignalState.targetBssid == null) {
      _gateController.add(SurveyGate.noConnectedBssid);
    } else if (_lastSignalState.currentRssi == null) {
      _gateController.add(SurveyGate.noConnectedBssid);
    } else if (!_validateSignalFreshness()) {
      _gateController.add(SurveyGate.staleSignal);
    } else if ((_lastSignalState.currentRssi ?? 0) < -85) {
      _gateController.add(SurveyGate.weakSignal);
    } else {
      _gateController.add(SurveyGate.none);
    }
  }

  /// Syncs global position from AR
  void syncPosition(double x, double y) {
    _positionTracker.setPosition(x, y);
  }

  /// Manually realigns the underlying PDR heading to the absolute compass.
  void realignHeading() {
    _positionTracker.realign();
  }

  void dispose() {
    _signalSub?.cancel();
    _positionSub?.cancel();
    _sessionController.close();
    _gateController.close();
  }
}
