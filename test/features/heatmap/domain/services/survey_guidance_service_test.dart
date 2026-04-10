import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/heatmap/domain/entities/floor_plan.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/wall_segment.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';
import 'package:torcav/features/heatmap/presentation/bloc/survey_gate.dart';

void main() {
  const service = SurveyGuidanceService();

  test(
    'suggests AR when there are enough samples but wall confidence is weak',
    () {
      final guidance = service.analyze(
        points: [
          _point(0, 0, -61),
          _point(1, 0, -63),
          _point(2, 0.5, -62),
          _point(2.5, 1.1, -64),
        ],
        floorPlan: null,
        isRecording: true,
        isArViewEnabled: false,
        hasArOrigin: false,
        pendingWallCount: 0,
        currentRssi: -63,
        surveyGate: SurveyGate.none,
        lastSignalAt: DateTime.now(),
        currentSignalStdDev: 1.8,
        currentX: 2.5,
        currentY: 1.1,
      );

      expect(guidance.stage, SurveyStage.planCapture);
      expect(guidance.suggestAr, isTrue);
      expect(guidance.readyToFinish, isFalse);
    },
  );

  test('marks survey ready when plan and coverage are both strong', () {
    final guidance = service.analyze(
      points: [
        _point(0, 0, -58),
        _point(1, 0, -59),
        _point(2, 0, -60),
        _point(0, 1, -57),
        _point(1, 1, -58),
        _point(2, 1, -61),
        _point(0, 2, -56),
        _point(1, 2, -59),
        _point(2, 2, -60),
        _point(3, 1, -62),
        _point(3, 2, -61),
        _point(3, 0, -60),
        _point(4, 0, -61),
        _point(4, 1, -62),
        _point(4, 2, -60),
        _point(5, 0, -59),
        _point(5, 1, -60),
        _point(5, 2, -58),
        _point(2, 3, -57),
        _point(3, 3, -59),
        _point(4, 3, -60),
      ],
      floorPlan: const FloorPlan(
        walls: [
          WallSegment(x1: 0, y1: 0, x2: 4, y2: 0),
          WallSegment(x1: 4, y1: 0, x2: 4, y2: 2),
          WallSegment(x1: 4, y1: 2, x2: 0, y2: 2),
          WallSegment(x1: 0, y1: 2, x2: 0, y2: 0),
          WallSegment(x1: 1.5, y1: 0, x2: 1.5, y2: 2),
          WallSegment(x1: 2.5, y1: 0, x2: 2.5, y2: 2),
          WallSegment(x1: 0, y1: 3, x2: 5, y2: 3),
          WallSegment(x1: 5, y1: 0, x2: 5, y2: 3),
          WallSegment(x1: 0, y1: 0, x2: 0, y2: 3),
        ],
        widthMeters: 5,
        heightMeters: 3,
      ),
      isRecording: true,
      isArViewEnabled: false,
      hasArOrigin: true,
      pendingWallCount: 0,
      currentRssi: -59,
      surveyGate: SurveyGate.none,
      lastSignalAt: DateTime.now(),
      currentSignalStdDev: 1.4,
      currentX: 5,
      currentY: 3,
    );

    expect(guidance.readyToFinish, isTrue);
    expect(guidance.stage, SurveyStage.wrapUp);
    expect(guidance.overallProgress, greaterThan(0.75));
  });

  test('locks guidance when connected signal is missing', () {
    final guidance = service.analyze(
      points: [_point(0, 0, -65), _point(1, 0, -66)],
      floorPlan: null,
      isRecording: true,
      isArViewEnabled: true,
      hasArOrigin: true,
      pendingWallCount: 0,
      currentRssi: null,
      surveyGate: SurveyGate.noConnectedBssid,
      lastSignalAt: null,
      currentSignalStdDev: 0,
      currentX: 1,
      currentY: 0,
    );

    expect(guidance.tone, SurveyTone.caution);
    expect(guidance.readyToFinish, isFalse);
    expect(guidance.stage, SurveyStage.calibration);
  });
}

HeatmapPoint _point(double x, double y, int rssi) {
  return HeatmapPoint(
    x: 0,
    y: 0,
    floorX: x,
    floorY: y,
    rssi: rssi,
    timestamp: DateTime(2026, 4, 7, 12),
  );
}
