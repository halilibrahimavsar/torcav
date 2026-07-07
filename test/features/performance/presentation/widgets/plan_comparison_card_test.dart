import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/features/performance/domain/entities/plan_comparison.dart';
import 'package:torcav/features/performance/presentation/bloc/plan_comparison_cubit.dart';
import 'package:torcav/features/performance/presentation/widgets/plan_comparison_card.dart';

import '../../../../helpers/test_harness.dart';
import '../../../../helpers/widget_pump.dart';

class _MockPlanComparisonCubit extends MockCubit<PlanComparisonState>
    implements PlanComparisonCubit {}

void main() {
  late _MockPlanComparisonCubit cubit;

  setUp(() async {
    await setupHarness();
    cubit = _MockPlanComparisonCubit();
    when(() => cubit.load()).thenAnswer((_) async {});
    replaceSingleton<PlanComparisonCubit>(cubit);
  });

  tearDown(tearDownHarness);

  testWidgets('no plan declared → title + enter-plan CTA', (tester) async {
    when(() => cubit.state).thenReturn(const PlanComparisonNoPlan());

    await pumpAppWidget(
      tester,
      const PlanComparisonCard(),
      surfaceSize: const Size(800, 600),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('PAYING VS GETTING'), findsOneWidget);
    expect(find.text('Enter plan speed'), findsOneWidget);
  });

  testWidgets('delivering plan shows both values and the good verdict', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(
      PlanComparisonLoaded(
        PlanComparison(
          planMbps: 100,
          avgDownloadMbps: 90,
          bestDownloadMbps: 95,
          sampleCount: 5,
          lastSampleAt: DateTime(2026, 7, 7),
        ),
      ),
    );

    await pumpAppWidget(
      tester,
      const PlanComparisonCard(),
      surfaceSize: const Size(800, 600),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('100 Mbps'), findsOneWidget);
    expect(find.text('90.0 Mbps'), findsOneWidget);
    expect(find.text('average of 5 tests'), findsOneWidget);
    expect(find.text('90% of your plan'), findsOneWidget);
    expect(find.text("You're getting what you pay for."), findsOneWidget);
    expect(find.text('Prepare ISP report'), findsNothing);
  });

  testWidgets('under-delivering plan surfaces the ISP report CTA', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(
      PlanComparisonLoaded(
        PlanComparison(
          planMbps: 100,
          avgDownloadMbps: 30,
          bestDownloadMbps: 40,
          sampleCount: 3,
          lastSampleAt: DateTime(2026, 7, 7),
        ),
      ),
    );

    await pumpAppWidget(
      tester,
      const PlanComparisonCard(),
      surfaceSize: const Size(800, 600),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Well below what you pay for.'), findsOneWidget);
    expect(find.text('Prepare ISP report'), findsOneWidget);
  });
}
