import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';


import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/domain/entities/survey_gate.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';

export 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart'
    show SparseRegion, SurveyTone;

/// Color mapping for survey tones used in the HUD.
Color surveyToneColor(SurveyTone tone) {
  switch (tone) {
    case SurveyTone.info:
      return AppColors.neonCyan;
    case SurveyTone.progress:
      return AppColors.neonYellow;
    case SurveyTone.caution:
      return AppColors.neonOrange;
    case SurveyTone.success:
      return AppColors.neonGreen;
  }
}

/// Internal data classes (slices) for the AR HUD components to facilitate
/// granular BlocSelectors and maintain clean state propagation.

class SsidSlice {
  const SsidSlice({
    required this.ssid,
    required this.bssid,
    required this.rssi,
    required this.locked,
  });

  final String ssid;
  final String bssid;
  final int? rssi;
  final bool locked;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SsidSlice &&
          ssid == other.ssid &&
          bssid == other.bssid &&
          rssi == other.rssi &&
          locked == other.locked;

  @override
  int get hashCode => Object.hash(ssid, bssid, rssi, locked);
}

class ReticleSlice {
  const ReticleSlice({
    required this.rssi,
    required this.lastStepTimestamp,
    required this.surveyGate,
    required this.hasPendingWall,
  });

  final int? rssi;
  final DateTime? lastStepTimestamp;
  final SurveyGate surveyGate;
  final bool hasPendingWall;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReticleSlice &&
          rssi == other.rssi &&
          lastStepTimestamp == other.lastStepTimestamp &&
          surveyGate == other.surveyGate &&
          hasPendingWall == other.hasPendingWall;

  @override
  int get hashCode => Object.hash(rssi, lastStepTimestamp, surveyGate, hasPendingWall);
}

class GateSlice {
  const GateSlice({
    required this.gate,
    required this.targetBssid,
    required this.targetSsid,
  });

  final SurveyGate gate;
  final String? targetBssid;
  final String? targetSsid;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GateSlice &&
          gate == other.gate &&
          targetBssid == other.targetBssid &&
          targetSsid == other.targetSsid;

  @override
  int get hashCode => Object.hash(gate, targetBssid, targetSsid);
}

class SignalSlice {
  const SignalSlice({
    required this.rssi,
    required this.stdDev,
    required this.sampleCount,
    required this.ageSeconds,
    required this.surveyGate,
  });

  final int? rssi;
  final double stdDev;
  final int sampleCount;
  final int? ageSeconds;
  final SurveyGate surveyGate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignalSlice &&
          rssi == other.rssi &&
          stdDev == other.stdDev &&
          sampleCount == other.sampleCount &&
          ageSeconds == other.ageSeconds &&
          surveyGate == other.surveyGate;

  @override
  int get hashCode =>
      Object.hash(rssi, stdDev, sampleCount, ageSeconds, surveyGate);
}

class MiniMapSlice {
  const MiniMapSlice({
    this.session,
    this.currentPosition,
    this.currentHeading,
  });

  final HeatmapSession? session;
  final Offset? currentPosition;
  final double? currentHeading;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiniMapSlice &&
          session == other.session &&
          currentPosition == other.currentPosition &&
          currentHeading == other.currentHeading;

  @override
  int get hashCode => Object.hash(session, currentPosition, currentHeading);
}

/// Helper to compact BSSID for display.
String compactBssid(String bssid) {
  if (bssid.length < 8) return bssid;
  final parts = bssid.split(':');
  if (parts.length < 3) return bssid;
  return '${parts.first}:${parts[1]}:..:${parts.last}';
}

/// Slice for [ArCameraView] guidance analysis (BUG-02 fix).
///
/// Only the fields below affect the output of [SurveyGuidanceService.analyze].
/// Isolating them in a dedicated slice ensures the expensive guidance call is
/// only re-run when relevant state changes, not on every heading or RSSI tick.
class GuidanceSlice extends Equatable {
  const GuidanceSlice({required this.guidance});

  final SurveyGuidance guidance;

  @override
  List<Object?> get props => [guidance];
}

/// Slice for [ArCameraView] guidance analysis (BUG-02 fix).
///
/// Only the fields below affect the output of [SurveyGuidanceService.analyze].
/// Isolating them in a dedicated slice ensures the expensive guidance call is
/// only re-run when relevant state changes, not on every heading or RSSI tick.
class GuidanceCameraSlice extends Equatable {
  const GuidanceCameraSlice({
    required this.pointCount,
    required this.hasFloorPlan,
    required this.isRecording,
    required this.hasArOrigin,
    required this.pendingWallCount,
    required this.currentRssi,
    required this.surveyGate,
    required this.lastSignalAt,
    required this.lastSignalStdDev,
    required this.currentPosition,
    required this.phase,
    required this.pendingWalls,
    required this.lastStepTimestamp,
  });

  final int pointCount;
  final bool hasFloorPlan;
  final bool isRecording;
  final bool hasArOrigin;
  final int pendingWallCount;
  final int? currentRssi;
  final SurveyGate surveyGate;
  final DateTime? lastSignalAt;
  final double lastSignalStdDev;
  final Offset? currentPosition;
  final dynamic phase;
  final List<dynamic> pendingWalls;
  final DateTime? lastStepTimestamp;

  @override
  List<Object?> get props => [
        pointCount,
        hasFloorPlan,
        isRecording,
        hasArOrigin,
        pendingWallCount,
        currentRssi,
        surveyGate,
        lastSignalAt,
        lastSignalStdDev,
        currentPosition,
        phase,
        pendingWalls,
        lastStepTimestamp,
      ];
}
