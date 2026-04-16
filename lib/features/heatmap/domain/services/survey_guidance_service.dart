import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/survey_gate.dart';

enum SurveyStage {
  idle,
  calibration,
  coverageSweep,
  weakZoneReview,
  wrapUp,
  review,
}

enum SurveyTone { info, progress, caution, success }

enum SparseRegion { leftWing, rightWing, topWing, bottomWing }

class SurveyFeedHealth extends Equatable {
  const SurveyFeedHealth({
    required this.motionLive,
    required this.wifiLive,
    required this.cameraLive,
  });

  final bool motionLive;
  final bool wifiLive;
  final bool cameraLive;

  @override
  List<Object?> get props => [motionLive, wifiLive, cameraLive];
}

class SurveyGuidance extends Equatable {
  const SurveyGuidance({
    required this.stage,
    required this.tone,
    required this.overallProgress,
    required this.coverageScore,
    required this.signalScore,
    required this.sparseRegion,
    required this.feeds,
    required this.readyToFinish,
    this.customInstruction,
  });

  /// Natural language summary of the survey results.
  String get summaryText {
    if (overallProgress < 0.4) {
      return 'Initial data points captured. Continue scanning for higher detail.';
    }
    if (overallProgress < 0.6) {
      return 'Good progress. Adding more samples in weak zones will improve insights.';
    }
    if (overallProgress < 0.8) {
      return 'Strong data density. Coverage is consistent across most areas.';
    }
    return 'Optimal survey quality. Your signal mapping is highly accurate.';
  }

  final SurveyStage stage;
  final SurveyTone tone;
  final double overallProgress;
  final double coverageScore;
  final double signalScore;
  final SparseRegion? sparseRegion;
  final SurveyFeedHealth feeds;
  final bool readyToFinish;
  final String? customInstruction;

  @override
  List<Object?> get props => [
        stage,
        tone,
        overallProgress,
        coverageScore,
        signalScore,
        sparseRegion,
        feeds,
        readyToFinish,
        customInstruction,
      ];
}

@LazySingleton()
class SurveyGuidanceService {
  const SurveyGuidanceService();

  SurveyGuidance analyze({
    required List<HeatmapPoint> points,
    required bool isRecording,
    required int? currentRssi,
    required SurveyGate surveyGate,
    required DateTime? lastSignalAt,
    required double currentSignalStdDev,
    double? currentX,
    double? currentY,
  }) {
    final hasMotion = currentX != null && currentY != null;
    final hasWifi = currentRssi != null || points.isNotEmpty;

    if (!isRecording) {
      return SurveyGuidance(
        stage: points.isEmpty ? SurveyStage.idle : SurveyStage.review,
        tone: points.isEmpty ? SurveyTone.info : SurveyTone.success,
        overallProgress: _overallProgress(
          points,
          surveyGate,
          lastSignalAt,
          currentSignalStdDev,
        ),
        coverageScore: _coverageScore(points, currentX, currentY),
        signalScore: _signalScore(
          points,
          surveyGate,
          lastSignalAt,
          currentSignalStdDev,
        ),
        sparseRegion: _sparseRegion(points),
        feeds: SurveyFeedHealth(
          motionLive: hasMotion || points.isNotEmpty,
          wifiLive: hasWifi,
          cameraLive: false,
        ),
        readyToFinish: points.isNotEmpty,
      );
    }

    final coverageScore = _coverageScore(points, currentX, currentY);
    final signalScore = _signalScore(
      points,
      surveyGate,
      lastSignalAt,
      currentSignalStdDev,
    );
    final overall = _combineScores(coverageScore, signalScore);
    final sparseRegion = _sparseRegion(points);
    final weakZoneCount = points.where((point) => point.rssi < -72).length;

    SurveyStage stage;
    SurveyTone tone;

    if (surveyGate == SurveyGate.noConnectedBssid) {
      stage = SurveyStage.calibration;
      tone = SurveyTone.caution;
    } else if (surveyGate == SurveyGate.staleSignal) {
      stage = SurveyStage.calibration;
      tone = SurveyTone.caution;
    } else if (!hasMotion || points.length < 3) {
      stage = SurveyStage.calibration;
      tone = SurveyTone.info;
    } else if (coverageScore < 0.72) {
      stage = SurveyStage.coverageSweep;
      tone = SurveyTone.progress;
    } else if (weakZoneCount > 0 && (currentRssi ?? -50) < -72) {
      stage = SurveyStage.weakZoneReview;
      tone = SurveyTone.caution;
    } else if (overall >= 0.78) {
      stage = SurveyStage.wrapUp;
      tone = SurveyTone.success;
    } else {
      stage = SurveyStage.coverageSweep;
      tone = SurveyTone.progress;
    }

    final readyToFinish = surveyGate == SurveyGate.none &&
        overall >= 0.78 &&
        coverageScore >= 0.72 &&
        signalScore >= 0.72;

    return SurveyGuidance(
      stage: stage,
      tone: tone,
      overallProgress: overall,
      coverageScore: coverageScore,
      signalScore: signalScore,
      sparseRegion: sparseRegion,
      feeds: SurveyFeedHealth(
        motionLive: hasMotion || points.isNotEmpty,
        wifiLive: hasWifi,
        cameraLive: isRecording,
      ),
      readyToFinish: readyToFinish,
    );
  }

  double _overallProgress(
    List<HeatmapPoint> points,
    SurveyGate surveyGate,
    DateTime? lastSignalAt,
    double currentSignalStdDev,
  ) {
    final coverage = _coverageScore(points, null, null);
    final signal = _signalScore(
      points,
      surveyGate,
      lastSignalAt,
      currentSignalStdDev,
    );
    return _combineScores(coverage, signal);
  }

  double _combineScores(double coverage, double signal) {
    return ((coverage * 0.6) + (signal * 0.4)).clamp(0.0, 1.0);
  }

  double _coverageScore(
    List<HeatmapPoint> points,
    double? currentX,
    double? currentY,
  ) {
    if (points.isEmpty) return 0;

    final xs = points.map((point) => point.floorX).toList();
    final ys = points.map((point) => point.floorY).toList();
    if (currentX != null && currentY != null) {
      xs.add(currentX);
      ys.add(currentY);
    }

    final width = (xs.reduce(math.max) - xs.reduce(math.min)).abs();
    final height = (ys.reduce(math.max) - ys.reduce(math.min)).abs();
    final cells = points
        .map(
          (point) =>
              '${point.floorX.floor()}:${point.floorY.floor()}:${point.floor}',
        )
        .toSet()
        .length;
    final uniqueCoverage = (cells / 45).clamp(0.0, 1.0);
    final span = (math.max(width, height) / 10).clamp(0.0, 1.0);

    final sparseRegion = _sparseRegion(points);
    final balance = sparseRegion == null ? 1.0 : 0.65;

    return ((uniqueCoverage * 0.5) + (span * 0.25) + (balance * 0.25)).clamp(
      0.0,
      1.0,
    );
  }

  double _signalScore(
    List<HeatmapPoint> points,
    SurveyGate surveyGate,
    DateTime? lastSignalAt,
    double currentSignalStdDev,
  ) {
    if (points.isEmpty && lastSignalAt == null) return 0;

    final lockScore = surveyGate == SurveyGate.noConnectedBssid ? 0.0 : 1.0;
    final freshness = lastSignalAt == null
        ? 0.0
        : (1 -
                (DateTime.now().difference(lastSignalAt).inMilliseconds /
                    3000.0))
            .clamp(0.0, 1.0);
    final varianceScore = (1 - (currentSignalStdDev / 12)).clamp(0.0, 1.0);

    return ((lockScore * 0.45) + (freshness * 0.35) + (varianceScore * 0.20))
        .clamp(0.0, 1.0);
  }

  SparseRegion? _sparseRegion(List<HeatmapPoint> points) {
    if (points.length < 5) return null;

    final minX = points.map((point) => point.floorX).reduce(math.min);
    final maxX = points.map((point) => point.floorX).reduce(math.max);
    final minY = points.map((point) => point.floorY).reduce(math.min);
    final maxY = points.map((point) => point.floorY).reduce(math.max);
    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;

    final counts = <SparseRegion, int>{
      SparseRegion.leftWing: 0,
      SparseRegion.rightWing: 0,
      SparseRegion.topWing: 0,
      SparseRegion.bottomWing: 0,
    };

    for (final point in points) {
      counts[point.floorX <= centerX
              ? SparseRegion.leftWing
              : SparseRegion.rightWing] =
          counts[point.floorX <= centerX
                  ? SparseRegion.leftWing
                  : SparseRegion.rightWing]! +
              1;
      counts[point.floorY <= centerY
              ? SparseRegion.topWing
              : SparseRegion.bottomWing] =
          counts[point.floorY <= centerY
                  ? SparseRegion.topWing
                  : SparseRegion.bottomWing]! +
              1;
    }

    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final minEntry = sortedEntries.first;
    final maxEntry = sortedEntries.last;

    if (maxEntry.value - minEntry.value < math.max(2, points.length ~/ 5)) {
      return null;
    }

    return minEntry.key;
  }
}
