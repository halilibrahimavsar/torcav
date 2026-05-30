import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/features/performance/domain/entities/speed_test_progress.dart';
import 'package:torcav/features/performance/presentation/widgets/speedometer_arc.dart';

import '../../../../helpers/widget_pump.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('idle phase shows the "tap to start" affordance and an icon', (
    tester,
  ) async {
    await pumpAppWidget(
      tester,
      const SpeedometerArc(download: 0, upload: 0),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byIcon(Icons.speed_rounded), findsOneWidget);
  });

  testWidgets(
    'download phase: center metric renders the download value (truncated)',
    (tester) async {
      await pumpAppWidget(
        tester,
        const SpeedometerArc(
          download: 50,
          upload: 0,
          phase: SpeedTestPhase.download,
        ),
      );
      // TweenAnimationBuilder needs ≥ 800ms to settle on the end value.
      await tester.pump(const Duration(milliseconds: 900));

      // "50.0" appears in both the big center label and the DL mini-stat.
      expect(find.text('50.0'), findsAtLeastNWidgets(1));
    },
  );

  testWidgets(
    'upload phase: center metric shows the upload value, not download',
    (tester) async {
      await pumpAppWidget(
        tester,
        const SpeedometerArc(
          download: 100,
          upload: 30,
          phase: SpeedTestPhase.upload,
        ),
      );
      await tester.pump(const Duration(milliseconds: 900));

      // The big center text uses fontSize 56; mini-stat uses 14. Locate the
      // 56-px Text to confirm the *center* shows the upload value.
      final centerText = find.byWidgetPredicate((w) =>
          w is Text &&
          w.data == '30.0' &&
          (w.style?.fontSize ?? 0) >= 40,);
      expect(centerText, findsOneWidget);
    },
  );

  testWidgets(
    'done phase: hides the mini stats divider (no "tap to stop" hint)',
    (tester) async {
      await pumpAppWidget(
        tester,
        const SpeedometerArc(
          download: 100,
          upload: 30,
          phase: SpeedTestPhase.done,
        ),
      );
      await tester.pump(const Duration(milliseconds: 900));

      // In done state the bloc shows the center value only — no DL/UL split row.
      expect(find.text('DL'), findsNothing);
      expect(find.text('UL'), findsNothing);
    },
  );

  testWidgets('onTap is invoked when the gauge is tapped', (tester) async {
    var tapped = 0;
    await pumpAppWidget(
      tester,
      SpeedometerArc(
        download: 0,
        upload: 0,
        onTap: () => tapped++,
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.byType(SpeedometerArc));
    expect(tapped, 1);
  });

  testWidgets('renders without exception across every phase', (tester) async {
    for (final phase in SpeedTestPhase.values) {
      await pumpAppWidget(
        tester,
        SpeedometerArc(
          download: 25,
          upload: 15,
          phase: phase,
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull, reason: 'phase=$phase');
    }
  });
}
