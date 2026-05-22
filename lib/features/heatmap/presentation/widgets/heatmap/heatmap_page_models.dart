import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/core/extensions/context_extensions.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
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

  /// Returns the color representing the overall coverage quality.
  Color coverageColor(Brightness brightness) => AppColors.getCoverageColor(
    hasSamples,
    averageRssi?.round(),
    weakZoneCount,
    sampleCount,
    brightness,
  );

  String get coveragePercent {
    if (!hasSamples) return '0%';
    final areaM2 = widthMeters * heightMeters;
    final targetSamples = (areaM2 / 0.7).clamp(15.0, 100.0);
    final progress = (sampleCount / targetSamples).clamp(0.0, 1.0);
    return '${(progress * 100).round()}%';
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

  String get samplesShort => _l10n.heatmapSamplesShort;

  String get surveyCompleteTitle => _l10n.surveyComplete;

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

  String get samplesLabel => _l10n.heatmapSamplesLabel;

  String get avgSignalLabel => _l10n.heatmapAvgSignalLabel;

  String get notAvailable => _l10n.heatmapNotAvailable;

  String get noSurveyYetTitle => _l10n.heatmapNoSurveyYetTitle;
  String get noSurveyYetBody => _l10n.heatmapNoSurveyYetBody;
  String get walkToBeginTitle => _l10n.heatmapWalkToBeginTitle;
  String get walkToBeginBody => _l10n.heatmapWalkToBeginBody;

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

  String get tutorialTitle => _l10n.heatmapTutorialTitle;
  String get tutorialStep1 => _l10n.heatmapTutorialStep1;
  String get tutorialStep2 => _l10n.heatmapTutorialStep2;
  String get tutorialStep3 => _l10n.heatmapTutorialStep3;
  String get tutorialStep4 => _l10n.heatmapTutorialStep4;
}
