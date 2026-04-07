import 'dart:math' as math;

import '../entities/floor_plan.dart';
import '../entities/heatmap_point.dart';

enum SurveyStage {
  idle,
  calibration,
  planCapture,
  coverageSweep,
  weakZoneReview,
  wrapUp,
  review,
}

enum SurveyTone { info, progress, caution, success }

enum SparseRegion { leftWing, rightWing, topWing, bottomWing }

class SurveyFeedHealth {
  const SurveyFeedHealth({
    required this.motionLive,
    required this.wifiLive,
    required this.cameraLive,
    required this.planLive,
  });

  final bool motionLive;
  final bool wifiLive;
  final bool cameraLive;
  final bool planLive;
}

class SurveyGuidance {
  const SurveyGuidance({
    required this.stage,
    required this.tone,
    required this.overallProgress,
    required this.planScore,
    required this.coverageScore,
    required this.signalScore,
    required this.sparseRegion,
    required this.feeds,
    required this.suggestAr,
    required this.readyToFinish,
  });

  final SurveyStage stage;
  final SurveyTone tone;
  final double overallProgress;
  final double planScore;
  final double coverageScore;
  final double signalScore;
  final SparseRegion? sparseRegion;
  final SurveyFeedHealth feeds;
  final bool suggestAr;
  final bool readyToFinish;
}

class SurveyGuidanceService {
  const SurveyGuidanceService();

  SurveyGuidance analyze({
    required List<HeatmapPoint> points,
    required FloorPlan? floorPlan,
    required bool isRecording,
    required bool isArViewEnabled,
    required int pendingWallCount,
    required int? currentRssi,
    double? currentX,
    double? currentY,
  }) {
    final wallCount = floorPlan?.walls.length ?? 0;
    final hasMotion = currentX != null && currentY != null;
    final hasWifi = currentRssi != null || points.isNotEmpty;
    final hasPlan = wallCount > 0 || pendingWallCount > 0;

    if (!isRecording) {
      return SurveyGuidance(
        stage: points.isEmpty ? SurveyStage.idle : SurveyStage.review,
        tone: points.isEmpty ? SurveyTone.info : SurveyTone.success,
        overallProgress: _overallProgress(points, wallCount, pendingWallCount),
        planScore: _planScore(wallCount, pendingWallCount, isArViewEnabled),
        coverageScore: _coverageScore(points, currentX, currentY),
        signalScore: _signalScore(points),
        sparseRegion: _sparseRegion(points),
        feeds: SurveyFeedHealth(
          motionLive: hasMotion || points.isNotEmpty,
          wifiLive: hasWifi,
          cameraLive: false,
          planLive: wallCount > 0,
        ),
        suggestAr: false,
        readyToFinish: points.isNotEmpty,
      );
    }

    final planScore = _planScore(wallCount, pendingWallCount, isArViewEnabled);
    final coverageScore = _coverageScore(points, currentX, currentY);
    final signalScore = _signalScore(points);
    final overall = _combineScores(planScore, coverageScore, signalScore);
    final sparseRegion = _sparseRegion(points);
    final suggestAr =
        points.length >= 3 && planScore < 0.55 && !isArViewEnabled;
    final weakZoneCount = points.where((point) => point.rssi < -72).length;

    SurveyStage stage;
    SurveyTone tone;

    if (!hasMotion || points.length < 3) {
      stage = SurveyStage.calibration;
      tone = SurveyTone.info;
    } else if (planScore < 0.45) {
      stage = SurveyStage.planCapture;
      tone = suggestAr ? SurveyTone.caution : SurveyTone.progress;
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

    final readyToFinish =
        overall >= 0.78 && planScore >= 0.55 && coverageScore >= 0.68;

    return SurveyGuidance(
      stage: stage,
      tone: tone,
      overallProgress: overall,
      planScore: planScore,
      coverageScore: coverageScore,
      signalScore: signalScore,
      sparseRegion: sparseRegion,
      feeds: SurveyFeedHealth(
        motionLive: hasMotion || points.isNotEmpty,
        wifiLive: hasWifi,
        cameraLive: isArViewEnabled,
        planLive: hasPlan,
      ),
      suggestAr: suggestAr,
      readyToFinish: readyToFinish,
    );
  }

  double _overallProgress(
    List<HeatmapPoint> points,
    int wallCount,
    int pendingWallCount,
  ) {
    final plan = _planScore(wallCount, pendingWallCount, false);
    final coverage = _coverageScore(points, null, null);
    final signal = _signalScore(points);
    return _combineScores(plan, coverage, signal);
  }

  double _combineScores(double plan, double coverage, double signal) {
    return ((plan * 0.35) + (coverage * 0.35) + (signal * 0.30)).clamp(
      0.0,
      1.0,
    );
  }

  double _planScore(int wallCount, int pendingWallCount, bool isArViewEnabled) {
    final committed = (wallCount / 10).clamp(0.0, 1.0);
    final live = (pendingWallCount / 6).clamp(0.0, 1.0);
    final arBonus = isArViewEnabled ? 0.08 : 0.0;
    return math.max(committed, live * 0.55).clamp(0.0, 1.0) + arBonus > 1.0
        ? 1.0
        : math.max(committed, live * 0.55) + arBonus;
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
    final area = math.max(1.0, width * height);
    final density = (points.length / area).clamp(0.0, 1.2) / 1.2;
    final span = (math.max(width, height) / 10).clamp(0.0, 1.0);

    final sparseRegion = _sparseRegion(points);
    final balance = sparseRegion == null ? 1.0 : 0.65;

    return ((density * 0.45) + (span * 0.30) + (balance * 0.25)).clamp(
      0.0,
      1.0,
    );
  }

  double _signalScore(List<HeatmapPoint> points) {
    if (points.isEmpty) return 0;

    final sampleScore = (points.length / 18).clamp(0.0, 1.0);
    final values = points.map((point) => point.rssi).toList();
    final variation = (values.reduce(math.max) - values.reduce(math.min)).abs();
    final variationScore = (variation / 25).clamp(0.0, 1.0);

    return ((sampleScore * 0.7) + (variationScore * 0.3)).clamp(0.0, 1.0);
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

    final sortedEntries =
        counts.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
    final minEntry = sortedEntries.first;
    final maxEntry = sortedEntries.last;

    if (maxEntry.value - minEntry.value < math.max(2, points.length ~/ 5)) {
      return null;
    }

    return minEntry.key;
  }
}
