import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:torcav/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:torcav/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:torcav/features/dashboard/presentation/widgets/health_hero_card.dart';
import 'package:torcav/features/dashboard/presentation/widgets/live_metrics_bento.dart';
import 'package:torcav/features/dashboard/presentation/widgets/radial_dashboard_core.dart';
import 'package:torcav/features/ping_stabilizer/presentation/bloc/ping_stabilizer_cubit.dart';
import 'package:torcav/features/ping_stabilizer/presentation/bloc/ping_stabilizer_state.dart';
import 'package:torcav/features/security/presentation/bloc/notification/notification_bloc.dart';

import '../../../../helpers/test_harness.dart';
import '../../../../helpers/widget_pump.dart';

class _MockDashboardCubit extends MockCubit<DashboardState>
    implements DashboardCubit {}

class _MockNotificationBloc
    extends MockBloc<NotificationEvent, NotificationState>
    implements NotificationBloc {}

class _MockPingStabilizerCubit extends MockCubit<PingStabilizerState>
    implements PingStabilizerCubit {}

class _FakeNotificationEvent extends Fake implements NotificationEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeNotificationEvent());
  });

  late _MockDashboardCubit dashboardCubit;
  late _MockNotificationBloc notificationBloc;
  late _MockPingStabilizerCubit pingStabilizerCubit;

  setUp(() async {
    await setupHarness();

    dashboardCubit = _MockDashboardCubit();
    notificationBloc = _MockNotificationBloc();
    pingStabilizerCubit = _MockPingStabilizerCubit();

    when(() => dashboardCubit.load()).thenAnswer((_) async {});
    when(() => notificationBloc.state).thenReturn(
      const NotificationLoaded(notifications: [], unreadCount: 0),
    );
    when(() => pingStabilizerCubit.state).thenReturn(
      PingStabilizerState.initial(),
    );
    when(() => pingStabilizerCubit.bootstrap()).thenAnswer((_) async {});

    replaceSingleton<DashboardCubit>(dashboardCubit);
    replaceSingleton<NotificationBloc>(notificationBloc);
    replaceSingleton<PingStabilizerCubit>(pingStabilizerCubit);
  });

  tearDown(tearDownHarness);

  testWidgets('Loading state shows scanning spinner', (tester) async {
    when(() => dashboardCubit.state).thenReturn(const DashboardLoading());

    await pumpAppWidget(
      tester,
      DashboardPage(onNavigate: (_) {}),
      surfaceSize: const Size(800, 1600),
    );
    await tester.pump(const Duration(milliseconds: 800));

    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('Failure state shows error message', (tester) async {
    when(() => dashboardCubit.state).thenReturn(
      const DashboardFailure(ServerFailure('boom')),
    );

    await pumpAppWidget(
      tester,
      DashboardPage(onNavigate: (_) {}),
      surfaceSize: const Size(800, 1600),
    );
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('boom'), findsOneWidget);
  });

  testWidgets(
    'Success state shows hero; advanced section reveals core + bento',
    (tester) async {
      when(() => dashboardCubit.state).thenReturn(
        const DashboardSuccess(
          ssid: 'Lab AP',
          ip: '192.168.1.10',
          gateway: '192.168.1.1',
          networkCount: 5,
          securityScore: 85,
          signalQualityPct: 75,
          threatCount: 1,
          newDeviceCount: 0,
          channelRatings: [],
          scoreHistory: [60, 70, 80, 85],
          rssiHistory: [-55, -50],
          recentEvents: [],
          recentSnapshots: [],
        ),
      );

      await pumpAppWidget(
        tester,
        DashboardPage(onNavigate: (_) {}),
        surfaceSize: const Size(800, 1800),
      );
      // Two pumps: the first fires the StaggeredEntry delay timers, the
      // second settles their slide/fade animations at the final position.
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 800));

      expect(tester.takeException(), isNull);
      // Hero renders the health score and the healthy verdict (state carries
      // no diagnosis, which the hero treats as healthy).
      expect(find.byType(HealthHeroCard), findsOneWidget);
      expect(find.text('85'), findsWidgets);
      expect(find.text('NETWORK HEALTHY'), findsOneWidget);
      // Pro depth is collapsed by default (P2 first-screen simplification).
      expect(find.byType(RadialDashboardCore), findsNothing);
      expect(find.byType(LiveMetricsBento), findsNothing);

      await tester.tap(find.byType(ExpansionTile));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));

      expect(tester.takeException(), isNull);
      expect(find.byType(RadialDashboardCore), findsOneWidget);
      expect(find.byType(LiveMetricsBento), findsOneWidget);
      // Signal quality label now visible inside the advanced section.
      expect(find.text('75'), findsWidgets);
    },
  );
}
