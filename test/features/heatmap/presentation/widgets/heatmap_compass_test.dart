import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap_compass.dart';

import '../../../../helpers/widget_pump.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('renders at the requested size when heading is provided', (
    tester,
  ) async {
    await pumpAppWidget(
      tester,
      const HeatmapCompass(size: 100, heading: 0),
    );
    await tester.pump();

    final sizedBox = tester.widget<SizedBox>(
      find.descendant(
        of: find.byType(HeatmapCompass),
        matching: find.byType(SizedBox),
      ),
    );
    expect(sizedBox.width, 100);
    expect(sizedBox.height, 100);
  });

  testWidgets('renders without exception for a range of heading values', (
    tester,
  ) async {
    for (final heading in const [0.0, 90.0, 180.0, 270.0, 359.9]) {
      await pumpAppWidget(
        tester,
        HeatmapCompass(heading: heading),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'heading=$heading');
    }
  });

  testWidgets('uses a CustomPaint internally', (tester) async {
    await pumpAppWidget(tester, const HeatmapCompass(heading: 45));
    await tester.pump();
    expect(
      find.descendant(
        of: find.byType(HeatmapCompass),
        matching: find.byType(CustomPaint),
      ),
      findsAtLeastNWidgets(1),
    );
  });
}
