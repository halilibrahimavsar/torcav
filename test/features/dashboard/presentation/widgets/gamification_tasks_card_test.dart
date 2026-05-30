import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/features/dashboard/presentation/widgets/gamification_tasks_card.dart';
import 'package:torcav/features/diagnostics/domain/entities/network_health_score.dart';

import '../../../../helpers/widget_pump.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('empty task list renders SizedBox.shrink (nothing visible)', (
    tester,
  ) async {
    await pumpAppWidget(
      tester,
      GamificationTasksCard(tasks: const [], onTapTask: (_) {}),
    );
    await tester.pump();

    expect(find.byIcon(Icons.task_alt_rounded), findsNothing);
  });

  testWidgets('renders up to 3 tasks; tapping fires onTapTask', (tester) async {
    final tasks = [
      const GamificationTask(
        titleKey: 'enable_wpa3',
        pointValue: 15,
        deepLinkRoute: 'router-hardening',
      ),
      const GamificationTask(
        titleKey: 'disable_wps',
        pointValue: 25,
        deepLinkRoute: 'router-hardening',
      ),
      const GamificationTask(
        titleKey: 'optimize_channel',
        pointValue: 10,
      ),
      const GamificationTask(
        titleKey: 'harden_router',
        pointValue: 5,
      ),
    ];
    GamificationTask? tapped;

    await pumpAppWidget(
      tester,
      GamificationTasksCard(tasks: tasks, onTapTask: (t) => tapped = t),
      surfaceSize: const Size(800, 1000),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('+15'), findsOneWidget);
    expect(find.text('+25'), findsOneWidget);
    expect(find.text('+10'), findsOneWidget);
    // 4th task is sliced off.
    expect(find.text('+5'), findsNothing);

    await tester.tap(find.text('+15'));
    expect(tapped?.pointValue, 15);
  });
}
