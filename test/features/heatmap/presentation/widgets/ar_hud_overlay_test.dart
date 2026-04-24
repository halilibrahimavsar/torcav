import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';
import 'package:torcav/features/heatmap/presentation/bloc/scan_phase.dart';
import 'package:torcav/features/heatmap/domain/entities/survey_gate.dart';
import 'package:torcav/features/heatmap/presentation/widgets/ar_hud_overlay.dart';

import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockHeatmapBloc extends MockCubit<HeatmapState> implements HeatmapBloc {}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  late MockHeatmapBloc bloc;

  HeatmapState baseState({
    int? rssi = -55,
    int sampleCount = 6,
    String ssid = 'HomeNet',
    SurveyGate gate = SurveyGate.none,
  }) {
    final points = List.generate(
      sampleCount,
      (i) => HeatmapPoint(
        floorX: i.toDouble(),
        floorY: i.toDouble(),
        rssi: rssi ?? -90,
        timestamp: DateTime(2024, 1, 1, 0, 0, i),
        ssid: ssid,
      ),
    );
    return HeatmapState(
      currentSession: HeatmapSession(
        id: 's1',
        name: 'test',
        points: points,
        createdAt: DateTime(2024),
      ),
      isRecording: true,
      phase: ScanPhase.scanning,
      currentRssi: rssi,
      currentPosition: const Offset(1, 1),
      currentHeading: 90,
      targetSsid: ssid,
      targetBssid: 'AA:BB:CC:DD:EE:FF',
      surveyGate: gate,
      lastSignalAt: DateTime.now(),
      lastSignalStdDev: 1.8,
      lastSignalSampleCount: 5,
    );
  }

  Widget wrap(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BlocProvider<HeatmapBloc>.value(value: bloc, child: child),
      ),
    );
  }

  setUp(() {
    bloc = MockHeatmapBloc();
  });

  testWidgets('renders SSID chip and recording status', (tester) async {
    when(() => bloc.state).thenReturn(baseState(ssid: 'TestAP'));
    whenListen(
      bloc,
      Stream<HeatmapState>.fromIterable([baseState(ssid: 'TestAP')]),
      initialState: baseState(ssid: 'TestAP'),
    );

    await tester.pumpWidget(wrap(const ArHudOverlay()));
    await tester.pump();

    expect(find.text('TESTAP'), findsOneWidget);
  });

  testWidgets('shows measurement-locked banner when target AP is missing', (
    tester,
  ) async {
    final state = baseState(gate: SurveyGate.noConnectedBssid);
    when(() => bloc.state).thenReturn(state);
    whenListen(
      bloc,
      Stream<HeatmapState>.fromIterable([state]),
      initialState: state,
    );

    await tester.pumpWidget(wrap(const ArHudOverlay()));
    await tester.pump();

    expect(find.text('MEASUREMENT LOCKED'), findsOneWidget);
  });

  testWidgets('renders SurveyPilotCard during scanning', (tester) async {
    final state = baseState();
    when(() => bloc.state).thenReturn(state);
    whenListen(
      bloc,
      Stream<HeatmapState>.fromIterable([state]),
      initialState: state,
    );

    await tester.pumpWidget(wrap(const ArHudOverlay()));
    await tester.pump();

    // SurveyPilotCard emits the 'COMPLETE' suffix next to the progress %.
    expect(find.text('COMPLETE'), findsOneWidget);
  });

  testWidgets('hides SurveyPilotCard when the lock banner is visible', (
    tester,
  ) async {
    final state = baseState(gate: SurveyGate.noConnectedBssid);
    when(() => bloc.state).thenReturn(state);
    whenListen(
      bloc,
      Stream<HeatmapState>.fromIterable([state]),
      initialState: state,
    );

    await tester.pumpWidget(wrap(const ArHudOverlay()));
    await tester.pump();

    expect(find.text('MEASUREMENT LOCKED'), findsOneWidget);
    expect(find.text('COMPLETE'), findsNothing);
  });
}
