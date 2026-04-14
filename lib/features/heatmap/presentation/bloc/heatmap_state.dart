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
    this.targetBssid,
    this.targetSsid,
    this.surveyGate = SurveyGate.none,
    this.lastSignalAt,
    this.lastSignalStdDev = 0.0,
    this.lastSignalSampleCount = 0,
    this.lastStepTimestamp,
    this.currentFloor = 0,
    this.isAutoSampling = true,
    this.lastRecordedPosition,
    this.autoSamplingDistance = 1.5,
    this.coverageScore = 0.0,
    this.sparseRegion,
    this.isAutoWallEnabled = true,
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

  /// Locked target access point for the current survey.
  final String? targetBssid;
  final String? targetSsid;

  /// Gate that currently blocks measurements.
  final SurveyGate surveyGate;

  /// Timestamp of the freshest stabilized signal sample.
  final DateTime? lastSignalAt;

  /// Standard deviation for the current stabilized RSSI sample window.
  final double lastSignalStdDev;

  /// Number of raw RSSI samples backing the current stabilized value.
  final int lastSignalSampleCount;

  /// Timestamp of the last physical step detected by the sensors.
  final DateTime? lastStepTimestamp;

  /// Current floor index relative to scan start (0 = starting floor).
  final int currentFloor;

  /// Whether data points should be automatically recorded based on movement.
  final bool isAutoSampling;

  /// Last position where a data point was successfully recorded.
  final Offset? lastRecordedPosition;

  /// Distance threshold in meters to trigger an automatic sample.
  final double autoSamplingDistance;

  /// Overall coverage score (0.0 to 1.0) derived from spatial density.
  final double coverageScore;

  /// The quadrant identified as having the lowest data density.
  final SparseRegion? sparseRegion;

  /// Whether detected walls should be automatically committed.
  final bool isAutoWallEnabled;

  HeatmapState copyWith({
    List<HeatmapSession>? sessions,
    HeatmapSession? currentSession,
    bool clearCurrentSession = false,
    HeatmapSession? selectedSession,
    bool clearSelectedSession = false,
    bool? isLoading,
    bool? isRecording,
    Failure? failure,
    bool clearFailure = false,
    ScanPhase? phase,
    FloorPlan? liveFloorPlan,
    bool clearLiveFloorPlan = false,
    Offset? currentPosition,
    bool clearCurrentPosition = false,
    double? currentHeading,
    int? currentRssi,
    bool clearCurrentRssi = false,
    List<WallSegment>? pendingWalls,
    String? targetBssid,
    bool clearTargetBssid = false,
    String? targetSsid,
    bool clearTargetSsid = false,
    SurveyGate? surveyGate,
    DateTime? lastSignalAt,
    bool clearLastSignalAt = false,
    double? lastSignalStdDev,
    int? lastSignalSampleCount,
    DateTime? lastStepTimestamp,
    bool clearLastStepTimestamp = false,
    int? currentFloor,
    bool? isAutoSampling,
    Offset? lastRecordedPosition,
    bool clearLastRecordedPosition = false,
    double? autoSamplingDistance,
    double? coverageScore,
    SparseRegion? sparseRegion,
    bool clearSparseRegion = false,
    bool? isAutoWallEnabled,
  }) => HeatmapState(
    sessions: sessions ?? this.sessions,
    currentSession:
        clearCurrentSession ? null : currentSession ?? this.currentSession,
    selectedSession:
        clearSelectedSession ? null : selectedSession ?? this.selectedSession,
    isLoading: isLoading ?? this.isLoading,
    isRecording: isRecording ?? this.isRecording,
    failure: clearFailure ? null : failure ?? this.failure,
    phase: phase ?? this.phase,
    liveFloorPlan:
        clearLiveFloorPlan ? null : liveFloorPlan ?? this.liveFloorPlan,
    currentPosition:
        clearCurrentPosition ? null : currentPosition ?? this.currentPosition,
    currentHeading: currentHeading ?? this.currentHeading,
    currentRssi: clearCurrentRssi ? null : currentRssi ?? this.currentRssi,
    pendingWalls: pendingWalls ?? this.pendingWalls,
    targetBssid: clearTargetBssid ? null : targetBssid ?? this.targetBssid,
    targetSsid: clearTargetSsid ? null : targetSsid ?? this.targetSsid,
    surveyGate: surveyGate ?? this.surveyGate,
    lastSignalAt: clearLastSignalAt ? null : lastSignalAt ?? this.lastSignalAt,
    lastSignalStdDev: lastSignalStdDev ?? this.lastSignalStdDev,
    lastSignalSampleCount: lastSignalSampleCount ?? this.lastSignalSampleCount,
    lastStepTimestamp:
        clearLastStepTimestamp
            ? null
            : lastStepTimestamp ?? this.lastStepTimestamp,
    currentFloor: currentFloor ?? this.currentFloor,
    isAutoSampling: isAutoSampling ?? this.isAutoSampling,
    lastRecordedPosition: clearLastRecordedPosition
        ? null
        : lastRecordedPosition ?? this.lastRecordedPosition,
    autoSamplingDistance: autoSamplingDistance ?? this.autoSamplingDistance,
    coverageScore: coverageScore ?? this.coverageScore,
    sparseRegion: clearSparseRegion ? null : sparseRegion ?? this.sparseRegion,
    isAutoWallEnabled: isAutoWallEnabled ?? this.isAutoWallEnabled,
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
    targetBssid,
    targetSsid,
    surveyGate,
    lastSignalAt,
    lastSignalStdDev,
    lastSignalSampleCount,
    lastStepTimestamp,
    currentFloor,
    isAutoSampling,
    lastRecordedPosition,
    autoSamplingDistance,
    coverageScore,
    sparseRegion,
    isAutoWallEnabled,
  ];
}
