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

  testWidgets('renders every task it is given; tapping fires onTapTask', (
    tester,
  ) async {
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

    // The card no longer slices: GetNetworkHealthScoreUseCase decides how
    // many tasks are worth showing, and a second limit here meant it computed
    // five and silently dropped two.
    expect(find.text('+15'), findsOneWidget);
    expect(find.text('+25'), findsOneWidget);
    expect(find.text('+10'), findsOneWidget);
    expect(find.text('+5'), findsOneWidget);

    await tester.tap(find.text('+15'));
    expect(tapped?.pointValue, 15);
  });

  // Regression guard for the BLOCKER found in the 2026-08 audit: the card's
  // own switch knew only the six security-task keys, so every diagnostic
  // action key produced by DiagnoseUseCase fell through to `return titleKey`
  // and the dashboard printed a developer identifier at the user.
  testWidgets('diagnostic action keys resolve to text, never the raw key', (
    tester,
  ) async {
    const diagnosticKeys = [
      'speedDoctorActionMoveCloser',
      'speedDoctorActionAddMesh',
      'speedDoctorActionSwitchTo5Ghz',
      'speedDoctorActionChangeChannel',
      'speedDoctorActionMoveTo5Ghz',
      'speedDoctorActionEnableQos',
      'speedDoctorActionUpdateFirmware',
      'speedDoctorActionCallIsp',
      'speedDoctorActionRunWiredTest',
      'speedDoctorActionChangeDns',
      'speedDoctorActionEnableDoh',
    ];

    // The card renders at most three tasks, so walk the keys in batches.
    for (final key in diagnosticKeys) {
      await pumpAppWidget(
        tester,
        GamificationTasksCard(
          tasks: [
            GamificationTask(titleKey: key, pointValue: 20),
          ],
          onTapTask: (_) {},
        ),
        surfaceSize: const Size(800, 400),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        find.text(key),
        findsNothing,
        reason: '$key leaked to the UI as a raw localization key',
      );
    }
  });

  testWidgets('a known diagnostic key renders its English label', (
    tester,
  ) async {
    await pumpAppWidget(
      tester,
      GamificationTasksCard(
        tasks: const [
          GamificationTask(
            titleKey: 'speedDoctorActionAddMesh',
            pointValue: 20,
          ),
        ],
        onTapTask: (_) {},
      ),
      surfaceSize: const Size(800, 400),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Add a mesh node'), findsOneWidget);
  });

  testWidgets('security task keys still resolve to title and description', (
    tester,
  ) async {
    await pumpAppWidget(
      tester,
      GamificationTasksCard(
        tasks: const [
          GamificationTask(
            titleKey: 'harden_router',
            pointValue: 15,
            deepLinkRoute: 'router-hardening',
          ),
        ],
        onTapTask: (_) {},
      ),
      surfaceSize: const Size(800, 400),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Harden Router'), findsOneWidget);
    expect(find.text('harden_router'), findsNothing);
  });
}
