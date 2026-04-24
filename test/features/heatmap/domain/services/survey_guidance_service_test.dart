import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';
import 'package:torcav/features/heatmap/domain/entities/survey_gate.dart';

void main() {
  const service = SurveyGuidanceService();

  test('marks survey ready when coverage and signal are both strong', () {
    // Generate a dense, well-spread grid to hit coverage and signal thresholds
    final points = <HeatmapPoint>[];
    for (int x = 0; x <= 10; x++) {
      for (int y = 0; y <= 10; y++) {
        points.add(_point(x.toDouble(), y.toDouble(), -55 - (x + y) % 10));
      }
    }

    final guidance = service.analyze(
      points: points,
      isRecording: true,
      currentRssi: -59,
      surveyGate: SurveyGate.none,
      lastSignalAt: DateTime.now(),
      currentSignalStdDev: 1.4,
      currentX: 10,
      currentY: 10,
    );

    expect(guidance.readyToFinish, isTrue);
    expect(guidance.stage, SurveyStage.wrapUp);
    expect(guidance.overallProgress, greaterThan(0.75));
  });

  test('locks guidance when connected signal is missing', () {
    final guidance = service.analyze(
      points: [_point(0, 0, -65), _point(1, 0, -66)],
      isRecording: true,
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
    floorX: x,
    floorY: y,
    rssi: rssi,
    timestamp: DateTime(2026, 4, 7, 12),
  );
}
