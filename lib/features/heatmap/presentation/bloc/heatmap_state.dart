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
    this.isArSupported = false,
    this.targetBssid,
    this.targetSsid,
    this.surveyGate = SurveyGate.none,
    this.lastSignalAt,
    this.lastSignalStdDev = 0.0,
    this.lastSignalSampleCount = 0,
    this.hasArOrigin = false,
    this.lastStepTimestamp,
    this.currentFloor = 0,
    this.isScreenRecording = false,
    this.screenRecordPath,
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

  /// Timestamp of the last physical step detected by the sensors.
  final DateTime? lastStepTimestamp;

  /// Current floor index relative to scan start (0 = starting floor).
  final int currentFloor;

  /// Whether the user is currently recording the AR session to a video.
  final bool isScreenRecording;

  /// Path to the most recently saved AR session video.
  final String? screenRecordPath;

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
    bool? isArViewEnabled,
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
    DateTime? lastStepTimestamp,
    bool clearLastStepTimestamp = false,
    int? currentFloor,
    bool? isScreenRecording,
    String? screenRecordPath,
    bool clearScreenRecordPath = false,
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
    isArViewEnabled: isArViewEnabled ?? this.isArViewEnabled,
    isArSupported: isArSupported ?? this.isArSupported,
    targetBssid: clearTargetBssid ? null : targetBssid ?? this.targetBssid,
    targetSsid: clearTargetSsid ? null : targetSsid ?? this.targetSsid,
    surveyGate: surveyGate ?? this.surveyGate,
    lastSignalAt: clearLastSignalAt ? null : lastSignalAt ?? this.lastSignalAt,
    lastSignalStdDev: lastSignalStdDev ?? this.lastSignalStdDev,
    lastSignalSampleCount: lastSignalSampleCount ?? this.lastSignalSampleCount,
    hasArOrigin: hasArOrigin ?? this.hasArOrigin,
    lastStepTimestamp:
        clearLastStepTimestamp
            ? null
            : lastStepTimestamp ?? this.lastStepTimestamp,
    currentFloor: currentFloor ?? this.currentFloor,
    isScreenRecording: isScreenRecording ?? this.isScreenRecording,
    screenRecordPath:
        clearScreenRecordPath
            ? null
            : screenRecordPath ?? this.screenRecordPath,
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
    isArSupported,
    targetBssid,
    targetSsid,
    surveyGate,
    lastSignalAt,
    lastSignalStdDev,
    lastSignalSampleCount,
    hasArOrigin,
    lastStepTimestamp,
    currentFloor,
    isScreenRecording,
    screenRecordPath,
  ];
}
