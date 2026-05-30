import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:torcav/features/dashboard/presentation/pages/notification_sheet.dart';
import 'package:torcav/features/security/presentation/bloc/notification/notification_bloc.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/widget_pump.dart';

class _MockNotificationBloc extends MockBloc<NotificationEvent, NotificationState>
    implements NotificationBloc {}

class _FakeNotificationEvent extends Fake implements NotificationEvent {}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(_FakeNotificationEvent());
  });

  late _MockNotificationBloc bloc;

  setUp(() {
    bloc = _MockNotificationBloc();
  });

  Future<void> pumpSheet(WidgetTester tester) {
    return pumpAppWidget(
      tester,
      BlocProvider<NotificationBloc>.value(
        value: bloc,
        child: const NotificationSheet(),
      ),
      surfaceSize: const Size(400, 800),
    );
  }

  testWidgets('shows spinner during loading state', (tester) async {
    when(() => bloc.state).thenReturn(NotificationLoading());

    await pumpSheet(tester);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders empty-state when no notifications', (tester) async {
    when(() => bloc.state).thenReturn(
      const NotificationLoaded(notifications: [], unreadCount: 0),
    );

    await pumpSheet(tester);
    await tester.pump();

    expect(find.byIcon(Icons.security_update_good_rounded), findsOneWidget);
  });

  testWidgets('renders event list when notifications present', (tester) async {
    when(() => bloc.state).thenReturn(
      NotificationLoaded(
        notifications: [
          buildSecurityEvent(id: 1, ssid: 'CafeNet'),
          buildSecurityEvent(id: 2, ssid: 'HomeNet'),
        ],
        unreadCount: 2,
      ),
    );

    await pumpSheet(tester);
    await tester.pump();

    expect(find.text('CafeNet'), findsOneWidget);
    expect(find.text('HomeNet'), findsOneWidget);
  });

  testWidgets('tapping "Clear all" dispatches ClearAllNotifications', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(
      NotificationLoaded(
        notifications: [buildSecurityEvent(id: 1)],
        unreadCount: 1,
      ),
    );

    await pumpSheet(tester);
    await tester.pump();

    await tester.tap(find.byIcon(Icons.delete_sweep_rounded));
    await tester.pump();

    verify(() => bloc.add(any(that: isA<ClearAllNotifications>()))).called(1);
  });

  testWidgets('tapping "Mark all read" dispatches MarkAllNotificationsAsRead',
      (tester) async {
    when(() => bloc.state).thenReturn(
      NotificationLoaded(
        notifications: [buildSecurityEvent(id: 1)],
        unreadCount: 1,
      ),
    );

    await pumpSheet(tester);
    await tester.pump();

    await tester.tap(find.byIcon(Icons.done_all_rounded));
    await tester.pump();

    verify(() => bloc.add(any(that: isA<MarkAllNotificationsAsRead>())))
        .called(1);
  });
}
