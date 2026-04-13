import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_session.dart';
import 'package:torcav/features/heatmap/domain/services/survey_guidance_service.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';
import 'package:torcav/features/heatmap/presentation/bloc/scan_phase.dart';
import 'package:torcav/features/heatmap/domain/entities/survey_gate.dart';
import 'package:torcav/features/heatmap/presentation/widgets/ar_hud_overlay.dart';

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
        x: 0,
        y: 0,
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
      isArSupported: true,
      targetSsid: ssid,
      targetBssid: 'AA:BB:CC:DD:EE:FF',
      surveyGate: gate,
      lastSignalAt: DateTime.now(),
      lastSignalStdDev: 1.8,
      lastSignalSampleCount: 5,
      hasArOrigin: true,
    );
  }

  SurveyGuidance guidance({
    SurveyStage stage = SurveyStage.coverageSweep,
    SurveyTone tone = SurveyTone.progress,
    SparseRegion? sparseRegion,
    bool readyToFinish = false,
    double plan = 0.4,
    double coverage = 0.5,
    double signal = 0.6,
  }) {
    return SurveyGuidance(
      stage: stage,
      tone: tone,
      overallProgress: 0.5,
      planScore: plan,
      coverageScore: coverage,
      signalScore: signal,
      sparseRegion: sparseRegion,
      feeds: const SurveyFeedHealth(
        motionLive: true,
        wifiLive: true,
        cameraLive: true,
        planLive: true,
      ),
      suggestAr: false,
      readyToFinish: readyToFinish,
    );
  }

  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<HeatmapBloc>.value(value: bloc, child: child),
      ),
    );
  }

  setUp(() {
    bloc = MockHeatmapBloc();
  });

  testWidgets('renders SSID chip, compass, survey pilot card, and dock', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(baseState(ssid: 'TestAP'));
    whenListen(
      bloc,
      Stream<HeatmapState>.fromIterable([baseState(ssid: 'TestAP')]),
      initialState: baseState(ssid: 'TestAP'),
    );

    await tester.pumpWidget(
      wrap(
        ArHudOverlay(
          guidance: guidance(),
          onFlagWeakZone: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('TESTAP'), findsOneWidget);
    expect(find.text('SWEEP ROOMS'), findsOneWidget); // stage label
    expect(find.text('PLAN'), findsOneWidget);
    expect(find.text('COV'), findsOneWidget);
    expect(find.text('SIG'), findsOneWidget);
    expect(find.text('6 pts'), findsOneWidget);
  });

  testWidgets('shows weak-tier "TAP TO FLAG" label and fires callback', (
    tester,
  ) async {
    final state = baseState(rssi: -85);
    when(() => bloc.state).thenReturn(state);
    whenListen(
      bloc,
      Stream<HeatmapState>.fromIterable([state]),
      initialState: state,
    );

    var flagged = 0;
    await tester.pumpWidget(
      wrap(
        ArHudOverlay(
          guidance: guidance(tone: SurveyTone.caution),
          onFlagWeakZone: () => flagged++,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('TAP TO FLAG'), findsOneWidget);
    await tester.tap(find.text('TAP TO FLAG'));
    await tester.pump();
    expect(flagged, 1);
  });

  testWidgets('does NOT show tap-to-flag in strong signal tier', (
    tester,
  ) async {
    final state = baseState(rssi: -45);
    when(() => bloc.state).thenReturn(state);
    whenListen(
      bloc,
      Stream<HeatmapState>.fromIterable([state]),
      initialState: state,
    );

    await tester.pumpWidget(
      wrap(
        ArHudOverlay(
          guidance: guidance(tone: SurveyTone.success),
          onFlagWeakZone: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('TAP TO FLAG'), findsNothing);
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

    await tester.pumpWidget(
      wrap(ArHudOverlay(guidance: guidance(tone: SurveyTone.caution))),
    );
    await tester.pump();

    expect(find.text('MEASUREMENT LOCKED'), findsOneWidget);
  });

  testWidgets('renders sparse-region arrow labels for each region', (
    tester,
  ) async {
    final state = baseState();
    when(() => bloc.state).thenReturn(state);
    whenListen(
      bloc,
      Stream<HeatmapState>.fromIterable([state]),
      initialState: state,
    );

    final cases = <SparseRegion, String>{
      SparseRegion.leftWing: 'HEAD LEFT',
      SparseRegion.rightWing: 'HEAD RIGHT',
      SparseRegion.topWing: 'MOVE FORWARD',
      SparseRegion.bottomWing: 'STEP BACK',
    };

    for (final entry in cases.entries) {
      await tester.pumpWidget(
        wrap(ArHudOverlay(guidance: guidance(sparseRegion: entry.key))),
      );
      await tester.pump();
      expect(
        find.text(entry.value),
        findsOneWidget,
        reason: 'region ${entry.key}',
      );
    }
  });

  testWidgets('renders ready-to-finish banner when guidance.readyToFinish', (
    tester,
  ) async {
    final state = baseState();
    when(() => bloc.state).thenReturn(state);
    whenListen(
      bloc,
      Stream<HeatmapState>.fromIterable([state]),
      initialState: state,
    );

    await tester.pumpWidget(
      wrap(
        ArHudOverlay(
          guidance: guidance(tone: SurveyTone.success, readyToFinish: true),
        ),
      ),
    );
    // Banner fades in via its controller.
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('COVERAGE COMPLETE'), findsOneWidget);
    expect(find.text('Tap to finish scan'), findsOneWidget);
  });

  testWidgets('shows estimated mode badge in camera fallback mode', (
    tester,
  ) async {
    final state = baseState();
    when(() => bloc.state).thenReturn(state);
    whenListen(
      bloc,
      Stream<HeatmapState>.fromIterable([state]),
      initialState: state,
    );

    await tester.pumpWidget(
      wrap(ArHudOverlay(guidance: guidance(), estimatedMode: true)),
    );
    await tester.pump();

    expect(find.text('ESTIMATED MODE'), findsOneWidget);
  });

}
