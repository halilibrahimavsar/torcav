part of 'heatmap_bloc.dart';

class HeatmapState extends Equatable {
  const HeatmapState({
    this.sessions = const [],
    this.currentSession,
    this.selectedSession,
    this.isLoading = false,
    this.isRecording = false,
    this.failure,
    this.phase = ScanPhase.idle,
    this.liveFloorPlan,
    this.currentPosition,
    this.currentHeading = 0.0,
    this.currentRssi,
    this.pendingWalls = const [],
    this.isArViewEnabled = true,
    this.lastStepTimestamp,
  });

  final List<HeatmapSession> sessions;
  final HeatmapSession? currentSession;
  final HeatmapSession? selectedSession;
  final bool isLoading;
  final bool isRecording;
  final Failure? failure;

  /// Current lifecycle stage of the scanning process.
  final ScanPhase phase;

  /// In-progress floor plan being built from walls.
  final FloorPlan? liveFloorPlan;

  /// Current metric position (x, y) in meters from origin.
  final Offset? currentPosition;

  /// Current device heading in degrees (0..360).
  final double currentHeading;

  /// Most recent Wi-Fi signal strength sample.
  final int? currentRssi;

  /// Recently detected wall segments from camera feed.
  final List<WallSegment> pendingWalls;

  /// Whether the AR camera view is currently active (vs 2D map).
  final bool isArViewEnabled;

  /// Timestamp of the last physical step detected by the sensors.
  final DateTime? lastStepTimestamp;

  HeatmapState copyWith({
    List<HeatmapSession>? sessions,
    HeatmapSession? currentSession,
    HeatmapSession? selectedSession,
    bool clearSelectedSession = false,
    bool? isLoading,
    bool? isRecording,
    Failure? failure,
    bool clearFailure = false,
    ScanPhase? phase,
    FloorPlan? liveFloorPlan,
    Offset? currentPosition,
    double? currentHeading,
    int? currentRssi,
    List<WallSegment>? pendingWalls,
    bool? isArViewEnabled,
    DateTime? lastStepTimestamp,
  }) =>
      HeatmapState(
        sessions: sessions ?? this.sessions,
        currentSession: currentSession ?? this.currentSession,
        selectedSession:
            clearSelectedSession ? null : selectedSession ?? this.selectedSession,
        isLoading: isLoading ?? this.isLoading,
        isRecording: isRecording ?? this.isRecording,
        failure: clearFailure ? null : failure ?? this.failure,
        phase: phase ?? this.phase,
        liveFloorPlan: liveFloorPlan ?? this.liveFloorPlan,
        currentPosition: currentPosition ?? this.currentPosition,
        currentHeading: currentHeading ?? this.currentHeading,
        currentRssi: currentRssi ?? this.currentRssi,
        pendingWalls: pendingWalls ?? this.pendingWalls,
        isArViewEnabled: isArViewEnabled ?? this.isArViewEnabled,
        lastStepTimestamp: lastStepTimestamp ?? this.lastStepTimestamp,
      );

  @override
  List<Object?> get props => [
        sessions,
        currentSession,
        selectedSession,
        isLoading,
        isRecording,
        failure,
        phase,
        liveFloorPlan,
        currentPosition,
        currentHeading,
        currentRssi,
        pendingWalls,
        isArViewEnabled,
        lastStepTimestamp,
      ];
}
