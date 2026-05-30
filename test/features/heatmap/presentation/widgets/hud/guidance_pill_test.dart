import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';
import 'package:torcav/features/heatmap/presentation/widgets/hud/guidance_pill.dart';

import '../../../../../helpers/widget_pump.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('renders the idle stage label uppercased', (tester) async {
    await pumpAppWidget(
      tester,
      const GuidancePill(
        stage: SurveyStage.idle,
        tone: SurveyTone.info,
      ),
    );
    await tester.pump();

    // Real label content depends on l10n; assert presence of a single Text
    // with uppercase content (e.g. "PRESS START").
    final textWidget = tester.widget<Text>(find.byType(Text));
    expect(textWidget.data, isNotNull);
    expect(textWidget.data, equals(textWidget.data!.toUpperCase()));
  });

  testWidgets('renders customInstruction when provided', (tester) async {
    await pumpAppWidget(
      tester,
      const GuidancePill(
        stage: SurveyStage.coverageSweep,
        tone: SurveyTone.progress,
        customInstruction: 'Walk slowly',
      ),
    );
    await tester.pump();

    expect(find.text('WALK SLOWLY'), findsOneWidget);
  });

  testWidgets('renders without exception for every stage', (tester) async {
    for (final stage in SurveyStage.values) {
      await pumpAppWidget(
        tester,
        GuidancePill(stage: stage, tone: SurveyTone.info),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'stage=$stage');
    }
  });
}
