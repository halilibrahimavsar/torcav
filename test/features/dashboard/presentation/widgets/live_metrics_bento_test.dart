import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/features/dashboard/presentation/widgets/live_metrics_bento.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/widget_pump.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildSubject({
    int? signalQualityPct = 70,
    List<int> rssiHistory = const [],
    List<int> scoreHistory = const [],
    int newDeviceCount = 0,
    double? lastDownloadMbps,
    double? lastUploadMbps,
    DateTime? lastSpeedTestAt,
    VoidCallback? onTapSignal,
    VoidCallback? onTapScore,
    VoidCallback? onTapChannels,
    VoidCallback? onTapDevices,
    VoidCallback? onTapThreats,
    VoidCallback? onTapSpeed,
  }) {
    return LiveMetricsBento(
      signalQualityPct: signalQualityPct,
      rssiHistory: rssiHistory,
      scoreHistory: scoreHistory,
      channelRatings: const [],
      newDeviceCount: newDeviceCount,
      recentEvents: const [],
      lastDownloadMbps: lastDownloadMbps,
      lastUploadMbps: lastUploadMbps,
      lastSpeedTestAt: lastSpeedTestAt,
      onTapSignal: onTapSignal ?? () {},
      onTapScore: onTapScore ?? () {},
      onTapChannels: onTapChannels ?? () {},
      onTapDevices: onTapDevices ?? () {},
      onTapThreats: onTapThreats ?? () {},
      onTapSpeed: onTapSpeed ?? () {},
    );
  }

  testWidgets('renders six metric tiles with empty data', (tester) async {
    await pumpAppWidget(
      tester,
      buildSubject(),
      surfaceSize: const Size(800, 1600),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Six tiles in a 2-col grid.
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('renders populated tiles with realistic state', (tester) async {
    await pumpAppWidget(
      tester,
      buildSubject(
        rssiHistory: const [-70, -65, -60, -55, -50],
        scoreHistory: const [60, 70, 80, 85],
        newDeviceCount: 3,
        lastDownloadMbps: 150,
        lastUploadMbps: 30,
        lastSpeedTestAt: DateTime(2026, 5, 25, 11),
      ),
      surfaceSize: const Size(800, 1600),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(GridView), findsOneWidget);
    // New device counter — '3' must be in the tree.
    expect(find.textContaining('3'), findsWidgets);
  });

  testWidgets('survives null signal / null speed gracefully', (tester) async {
    await pumpAppWidget(
      tester,
      buildSubject(
        signalQualityPct: null,
      ),
      surfaceSize: const Size(800, 1600),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('includes channel rating bar tile when ratings supplied', (
    tester,
  ) async {
    await pumpAppWidget(
      tester,
      LiveMetricsBento(
        signalQualityPct: 80,
        rssiHistory: const [-50, -55, -52],
        scoreHistory: const [],
        channelRatings: [
          buildChannelRating(channel: 1, rating: 8),
          buildChannelRating(rating: 5),
          buildChannelRating(channel: 11, rating: 7),
        ],
        newDeviceCount: 0,
        recentEvents: const [],
        lastDownloadMbps: null,
        lastUploadMbps: null,
        lastSpeedTestAt: null,
        onTapSignal: () {},
        onTapScore: () {},
        onTapChannels: () {},
        onTapDevices: () {},
        onTapThreats: () {},
        onTapSpeed: () {},
      ),
      surfaceSize: const Size(800, 1600),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
  });

  // The tiles are sparklines, bars and waveforms — a screen reader gets
  // nothing from them unless the value is spoken. Guards the six labels the
  // 2026-08 audit's X-3 pass added.
  testWidgets('each metric tile is a button that speaks its value', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await pumpAppWidget(
      tester,
      buildSubject(
        signalQualityPct: 72,
        rssiHistory: const [-60, -58, -55],
        scoreHistory: const [70, 80, 88],
        newDeviceCount: 2,
        lastDownloadMbps: 94.5,
        lastUploadMbps: 12.25,
        onTapSignal: () {},
      ),
      surfaceSize: const Size(900, 1200),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      find.bySemanticsLabel(RegExp(r'72 percent quality.*latest -55 dBm')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'latest 88 out of 100')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp(r'2 new devices')), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'download 94\.5 megabits')),
      findsOneWidget,
    );

    handle.dispose();
  });

  testWidgets('empty metrics read as "not yet", never as zero', (tester) async {
    final handle = tester.ensureSemantics();

    await pumpAppWidget(
      tester,
      buildSubject(signalQualityPct: null),
      surfaceSize: const Size(900, 1200),
    );
    await tester.pump(const Duration(milliseconds: 600));

    // "0 dBm" or "0 out of 100" would be a lie; absence has to sound absent.
    expect(
      find.bySemanticsLabel(RegExp(r'no signal reading yet')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp(r'no history yet')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'no speed test yet')), findsOneWidget);

    handle.dispose();
  });
}
