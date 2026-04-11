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
    this.isArSupported = false,
    this.targetBssid,
    this.targetSsid,
    this.surveyGate = SurveyGate.none,
    this.lastSignalAt,
    this.lastSignalStdDev = 0.0,
    this.lastSignalSampleCount = 0,
    this.hasArOrigin = false,
    this.arOriginHeadingOffset = 0.0,
    this.lastStepTimestamp,
    this.currentFloor = 0,
    this.isAutoSampling = false,
    this.lastRecordedPosition,
    this.autoSamplingDistance = 0.8,
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

  /// Whether the AR survey origin has been placed.
  final bool hasArOrigin;

  /// Degrees to rotate compass heading to align magnetic North with AR forward.
  final double arOriginHeadingOffset;

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

  /// Whether the device supports AR features.
  final bool isArSupported;

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
    bool? isArSupported,
    String? targetBssid,
    bool clearTargetBssid = false,
    String? targetSsid,
    bool clearTargetSsid = false,
    SurveyGate? surveyGate,
    DateTime? lastSignalAt,
    bool clearLastSignalAt = false,
    double? lastSignalStdDev,
    int? lastSignalSampleCount,
    bool? hasArOrigin,
    double? arOriginHeadingOffset,
    DateTime? lastStepTimestamp,
    bool clearLastStepTimestamp = false,
    int? currentFloor,
    bool? isAutoSampling,
    Offset? lastRecordedPosition,
    bool clearLastRecordedPosition = false,
    double? autoSamplingDistance,
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
    isArSupported: isArSupported ?? this.isArSupported,
    targetBssid: clearTargetBssid ? null : targetBssid ?? this.targetBssid,
    targetSsid: clearTargetSsid ? null : targetSsid ?? this.targetSsid,
    surveyGate: surveyGate ?? this.surveyGate,
    lastSignalAt: clearLastSignalAt ? null : lastSignalAt ?? this.lastSignalAt,
    lastSignalStdDev: lastSignalStdDev ?? this.lastSignalStdDev,
    lastSignalSampleCount: lastSignalSampleCount ?? this.lastSignalSampleCount,
    hasArOrigin: hasArOrigin ?? this.hasArOrigin,
    arOriginHeadingOffset: arOriginHeadingOffset ?? this.arOriginHeadingOffset,
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
    isArSupported,
    targetBssid,
    targetSsid,
    surveyGate,
    lastSignalAt,
    lastSignalStdDev,
    lastSignalSampleCount,
    hasArOrigin,
    arOriginHeadingOffset,
    lastStepTimestamp,
    currentFloor,
    isAutoSampling,
    lastRecordedPosition,
    autoSamplingDistance,
  ];
}
