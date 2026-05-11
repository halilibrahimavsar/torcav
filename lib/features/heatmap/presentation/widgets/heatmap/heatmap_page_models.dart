import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/core/extensions/context_extensions.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';
import 'package:torcav/core/l10n/app_localizations.dart';

class HeatmapSummary {
  const HeatmapSummary({
    required this.sampleCount,
    required this.weakZoneCount,
    required this.averageRssi,
    required this.currentRssi,
    required this.widthMeters,
    required this.heightMeters,
  });

  factory HeatmapSummary.from({
    required HeatmapSession session,
    required int? currentRssi,
  }) {
    final points = session.points;
    final averageRssi =
        points.isEmpty
            ? null
            : points.map((point) => point.rssi).reduce((a, b) => a + b) /
                points.length;
    final weakZoneCount =
        points.where((point) => point.rssi < -72 || point.isFlagged).length;
    final bounds = MetricBounds.from(points: points);

    return HeatmapSummary(
      sampleCount: points.length,
      weakZoneCount: weakZoneCount,
      averageRssi: averageRssi,
      currentRssi: currentRssi,
      widthMeters: bounds.widthMeters,
      heightMeters: bounds.heightMeters,
    );
  }

  final int sampleCount;
  final int weakZoneCount;
  final double? averageRssi;
  final int? currentRssi;
  final double widthMeters;
  final double heightMeters;

  bool get hasSamples => sampleCount > 0;

  int? get signalForDisplay => currentRssi ?? averageRssi?.round();

  /// Returns the color representing the current signal quality.
  Color signalColor(Brightness brightness) =>
      AppColors.getSignalColor(signalForDisplay, brightness);

  /// Returns the color representing the overall coverage quality.
  Color coverageColor(Brightness brightness) => AppColors.getCoverageColor(
    hasSamples,
    averageRssi?.round(),
    weakZoneCount,
    sampleCount,
    brightness,
  );

  String signalDisplay(HeatmapCopy copy) {
    final signal = signalForDisplay;
    return signal == null ? copy.notAvailable : '$signal dBm';
  }

  String signalHelper(HeatmapCopy copy) {
    final signal = signalForDisplay;
    if (signal == null) return copy.signalUnavailableHelper;
    if (signal >= -60) return copy.signalStrongHelper;
    if (signal >= -72) return copy.signalFairHelper;
    return copy.signalWeakHelper;
  }

  String get coveragePercent {
    if (!hasSamples) return '0%';
    final areaM2 = widthMeters * heightMeters;
    final targetSamples = (areaM2 / 0.7).clamp(15.0, 100.0);
    final progress = (sampleCount / targetSamples).clamp(0.0, 1.0);
    return '${(progress * 100).round()}%';
  }

  String planSizeDisplay(HeatmapCopy copy) {
    if (!hasSamples) return copy.notAvailable;
    return '${widthMeters.toStringAsFixed(1)} x ${heightMeters.toStringAsFixed(1)} m';
  }
}

class MetricBounds {
  const MetricBounds({required this.widthMeters, required this.heightMeters});

  factory MetricBounds.from({required List<HeatmapPoint> points}) {
    final xs = <double>[0];
    final ys = <double>[0];

    for (final point in points) {
      xs.add(point.floorX);
      ys.add(point.floorY);
    }

    final width = (xs.reduce(math.max) - xs.reduce(math.min)).abs();
    final height = (ys.reduce(math.max) - ys.reduce(math.min)).abs();

    return MetricBounds(
      widthMeters: math.max(1, width),
      heightMeters: math.max(1, height),
    );
  }

  final double widthMeters;
  final double heightMeters;
}

/// A localized copy provider for Heatmap features.
/// This class now proxies to [AppLocalizations].
class HeatmapCopy {
  const HeatmapCopy._(this._l10n);

  factory HeatmapCopy.of(BuildContext context) {
    return HeatmapCopy._(context.l10n);
  }

  final AppLocalizations _l10n;

  String get pageTitle => _l10n.heatmapPageTitle;
  String get pageSubtitle => _l10n.heatmapPageSubtitle;
  String get historyTooltip => _l10n.heatmapHistoryTooltip;
  String get themeToggleTooltip => _l10n.heatmapThemeToggleTooltip;
  String get previewSessionName => _l10n.preview;
  String get recordingStatus => _l10n.recording;
  String get reviewingStatus => _l10n.reviewing;
  String get idleStatus => _l10n.idle;
  String get samplesShort => _l10n.heatmapSamplesShort;
  String get wallsShort => _l10n.heatmapWallsShort;

  String get surveyCompleteTitle => _l10n.surveyComplete;
  String get surveyCompleteBody => _l10n.surveyCompleteDesc;
  String get coverageLabel => _l10n.coverage;
  String get blindSpotsLabel => _l10n.blindSpots;
  String get finishAndSave => _l10n.saveAndFinish;
  String get restartSurvey => _l10n.heatmapRestartSurvey;
  String get renameSurvey => _l10n.heatmapRenameSurvey;
  String get shareHeatmap => _l10n.heatmapShareHeatmap;
  String get renameDialogTitle => _l10n.heatmapRenameDialogTitle;
  String get save => _l10n.heatmapSave;
  String get shareSubject => _l10n.heatmapShareSubject;
  String get shareText => _l10n.heatmapShareText;

  String get issueTitle => _l10n.heatmapIssueTitle;
  String get genericIssueBody => _l10n.heatmapGenericIssueBody;

  String get goalTitle => _l10n.heatmapGoalTitle;
  String get goalBody => _l10n.heatmapGoalBody;

  String get waitingForDataTitle => _l10n.heatmapWaitingForDataTitle;
  String get waitingForDataBody => _l10n.heatmapWaitingForDataBody;

  String get arCaptureTitle => _l10n.heatmapArCaptureTitle;
  String get arCaptureBody => _l10n.heatmapArCaptureBody;
  String get mapCaptureTitle => _l10n.heatmapMapCaptureTitle;
  String get mapCaptureBody => _l10n.heatmapMapCaptureBody;

  String get reviewTitle => _l10n.heatmapReviewTitle;
  String reviewBody(HeatmapSummary summary) {
    if (!summary.hasSamples) {
      return _l10n.heatmapReviewBodyNoSamples;
    }
    return _l10n.heatmapReviewBodyReady;
  }

  String get samplesLabel => _l10n.heatmapSamplesLabel;
  String get wallsLabel => _l10n.heatmapWallsLabel;
  String get currentSignalLabel => _l10n.heatmapCurrentSignalLabel;
  String get avgSignalLabel => _l10n.heatmapAvgSignalLabel;
  String get weakZonesLabel => _l10n.heatmapWeakZonesLabel;
  String get planSizeLabel => _l10n.heatmapPlanSizeLabel;
  String get notAvailable => _l10n.heatmapNotAvailable;
  String get noSamplesHelper => _l10n.heatmapNoSamplesHelper;
  String samplesHelper(int count) => _l10n.heatmapSamplesHelper(count);
  String get noWallsHelper => _l10n.heatmapNoWallsHelper;
  String wallsHelper(int count) => _l10n.heatmapWallsHelper(count);
  String get signalUnavailableHelper => _l10n.heatmapSignalUnavailableHelper;
  String get signalStrongHelper => _l10n.heatmapSignalStrongHelper;
  String get signalFairHelper => _l10n.heatmapSignalFairHelper;
  String get signalWeakHelper => _l10n.heatmapSignalWeakHelper;
  String weakZoneHelper(int count) {
    if (count == 0) return _l10n.heatmapWeakZoneHelperNone;
    if (count == 1) return _l10n.heatmapWeakZoneHelperOne;
    return _l10n.heatmapWeakZoneHelperMany(count);
  }

  String get planSizeHelper => _l10n.heatmapPlanSizeHelper;

  String get noSurveyYetTitle => _l10n.heatmapNoSurveyYetTitle;
  String get noSurveyYetBody => _l10n.heatmapNoSurveyYetBody;
  String get walkToBeginTitle => _l10n.heatmapWalkToBeginTitle;
  String get walkToBeginBody => _l10n.heatmapWalkToBeginBody;

  String get mapViewLabel => _l10n.heatmapMapViewLabel;
  String get resultViewLabel => _l10n.heatmapResultViewLabel;

  String get findingsTitle => _l10n.heatmapFindingsTitle;
  String get recordingInsightReady => _l10n.heatmapInsightReady;
  String get recordingInsightTooEarly => _l10n.heatmapInsightTooEarly;
  String get recordingInsightNoWalls => _l10n.heatmapInsightNoWalls;
  String recordingInsight(HeatmapSummary summary) =>
      _l10n.heatmapInsightLive(summary.sampleCount);

  String get reviewInsightNoSamples => _l10n.heatmapReviewInsightNoSamples;
  String get reviewInsightNoPlan => _l10n.heatmapReviewInsightNoPlan;
  String get reviewInsightStrong => _l10n.heatmapReviewInsightStrong;
  String reviewInsightWeak(int weakCount) =>
      _l10n.heatmapReviewInsightWeak(weakCount);
  String reviewInsightBalanced(int weakCount) =>
      _l10n.heatmapReviewInsightBalanced(weakCount);

  String get closeReview => _l10n.heatmapCloseReview;
  String get newSurvey => _l10n.heatmapNewSurvey;
  String get finishAndReview => _l10n.heatmapFinishAndReview;
  String get startSurvey => _l10n.heatmapStartSurvey;
  String get newSurveyDialogTitle => _l10n.heatmapNewSurveyDialogTitle;
  String defaultSessionName(DateTime now) {
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    return _l10n.heatmapDefaultSessionName(timeStr);
  }

  String get sessionNameField => _l10n.heatmapSessionNameField;
  String get newSurveyHint => _l10n.heatmapNewSurveyHint;
  String get cancel => _l10n.cancel;
  String get startNow => _l10n.startNowCaps;

  String get savedSurveysTitle => _l10n.heatmapSavedSurveysTitle;
  String get noSavedSurveys => _l10n.heatmapNoSavedSurveys;
  String savedSurveySubtitle(int samples, int weak, String timestamp) =>
      _l10n.heatmapSavedSurveySubtitle(samples, weak, timestamp);

  String get deleteSurveyTooltip => _l10n.heatmapDeleteSurveyTooltip;

  String get legendTitle => _l10n.heatmapLegendTitle;
  String get legendStrong => _l10n.heatmapLegendStrong;
  String get legendFair => _l10n.heatmapLegendFair;
  String get legendWeak => _l10n.heatmapLegendWeak;
  String get cameraViewLabel => _l10n.heatmapCameraViewLabel;
  String get infoSheetTitle => _l10n.heatmapInfoSheetTitle;

  String feedStatusLabel(String label, bool active) => _l10n.heatmapFeedStatus(
    label,
    active ? _l10n.heatmapActive : _l10n.heatmapInactive,
  );

  String get tutorialTitle => _l10n.heatmapTutorialTitle;
  String get tutorialStep1 => _l10n.heatmapTutorialStep1;
  String get tutorialStep2 => _l10n.heatmapTutorialStep2;
  String get tutorialStep3 => _l10n.heatmapTutorialStep3;
  String get tutorialStep4 => _l10n.heatmapTutorialStep4;

  String get arViewLabel => _l10n.heatmapArViewLabel;
  String get switchToMapHint => _l10n.heatmapSwitchToMapHint;
  String get switchToArHint => _l10n.heatmapSwitchToArHint;

  String get routeLabel => _l10n.heatmapRouteLabel;
  String get planConfidenceLabel => _l10n.heatmapPlanConfidenceLabel;
  String get coverageConfidenceLabel => _l10n.heatmapCoverageConfidenceLabel;
  String get signalConfidenceLabel => _l10n.heatmapSignalConfidenceLabel;
  String get motionFeedLabel => _l10n.heatmapMotionFeedLabel;
  String get wifiFeedLabel => 'Wi-Fi';
  String get cameraFeedLabel => _l10n.heatmapCameraFeedLabel;
  String get planFeedLabel => _l10n.heatmapPlanFeedLabel;

  String percent(double value) => '${(value.clamp(0.0, 1.0) * 100).round()}%';

  Color guidanceColor(SurveyGuidance guidance, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    switch (guidance.tone) {
      case SurveyTone.info:
        return isLight ? AppColors.inkCyan : AppColors.neonCyan;
      case SurveyTone.progress:
        return isLight ? AppColors.inkGreen : AppColors.neonGreen;
      case SurveyTone.caution:
        return isLight ? AppColors.inkOrange : AppColors.neonOrange;
      case SurveyTone.success:
        return isLight ? AppColors.inkBlue : AppColors.neonBlue;
    }
  }

  IconData guidanceIcon(SurveyGuidance guidance) {
    switch (guidance.stage) {
      case SurveyStage.idle:
        return Icons.play_arrow_rounded;
      case SurveyStage.calibration:
        return Icons.directions_walk_rounded;
      case SurveyStage.coverageSweep:
        return Icons.alt_route_rounded;
      case SurveyStage.weakZoneReview:
        return Icons.wifi_tethering_error_rounded;
      case SurveyStage.wrapUp:
        return Icons.flag_rounded;
      case SurveyStage.review:
        return Icons.analytics_rounded;
    }
  }

  String guidanceTitle(SurveyGuidance guidance) {
    switch (guidance.stage) {
      case SurveyStage.idle:
        return _l10n.heatmapGuidanceIdleTitle;
      case SurveyStage.calibration:
        return _l10n.heatmapGuidanceCalibrationTitle;
      case SurveyStage.coverageSweep:
        return _l10n.heatmapGuidanceSweepTitle;
      case SurveyStage.weakZoneReview:
        return _l10n.heatmapGuidanceWeakCheckTitle;
      case SurveyStage.wrapUp:
        return _l10n.heatmapGuidanceWrapUpTitle;
      case SurveyStage.review:
        return _l10n.heatmapGuidanceReviewTitle;
    }
  }

  String guidanceBody(SurveyGuidance guidance, HeatmapSummary summary) {
    switch (guidance.stage) {
      case SurveyStage.idle:
        return _l10n.heatmapGuidanceIdleBody;
      case SurveyStage.calibration:
        return _l10n.heatmapGuidanceCalibrationBody;
      case SurveyStage.coverageSweep:
        return _l10n.heatmapGuidanceSweepBody(routeLabelValue(guidance));
      case SurveyStage.weakZoneReview:
        return _l10n.heatmapGuidanceWeakCheckBody;
      case SurveyStage.wrapUp:
        return _l10n.heatmapGuidanceWrapUpBody;
      case SurveyStage.review:
        return _l10n.heatmapGuidanceReviewBody(
          (guidance.overallProgress * 100).round(),
          summary.sampleCount,
        );
    }
  }

  String routeLabelValue(SurveyGuidance guidance) {
    if (guidance.readyToFinish) {
      return _l10n.heatmapRouteFinish;
    }
    switch (guidance.stage) {
      case SurveyStage.idle:
        return _l10n.heatmapRouteStart;
      case SurveyStage.calibration:
        return _l10n.heatmapRouteWalkForward;
      case SurveyStage.coverageSweep:
        return directionLabel(guidance.sparseRegion);
      case SurveyStage.weakZoneReview:
        return _l10n.heatmapRouteSweepWeak;
      case SurveyStage.wrapUp:
        return _l10n.heatmapRouteWrapUp;
      case SurveyStage.review:
        return _l10n.heatmapRouteReview;
    }
  }

  String directionLabel(SparseRegion? region) {
    switch (region) {
      case SparseRegion.leftWing:
        return _l10n.heatmapRegionLeft;
      case SparseRegion.rightWing:
        return _l10n.heatmapRegionRight;
      case SparseRegion.topWing:
        return _l10n.heatmapRegionUpper;
      case SparseRegion.bottomWing:
        return _l10n.heatmapRegionLower;
      case null:
        return _l10n.heatmapRegionKeep;
    }
  }
}
