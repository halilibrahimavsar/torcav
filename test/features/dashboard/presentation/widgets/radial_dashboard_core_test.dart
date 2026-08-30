import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/features/dashboard/presentation/widgets/radial_dashboard_core.dart';

import '../../../../helpers/widget_pump.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildSubject({
    int healthScore = 85,
    int? signalQualityPct = 70,
    int threatCount = 2,
    int deviceCount = 12,
    VoidCallback? onTapHealth,
    VoidCallback? onTapSignal,
    VoidCallback? onTapThreats,
    VoidCallback? onTapDevices,
  }) {
    return RadialDashboardCore(
      statusColor: const Color(0xFF00E5FF),
      label: 'secure',
      subLabel: '85%',
      healthScore: healthScore,
      signalQualityPct: signalQualityPct,
      threatCount: threatCount,
      deviceCount: deviceCount,
      onTapHealth: onTapHealth,
      onTapSignal: onTapSignal,
      onTapThreats: onTapThreats,
      onTapDevices: onTapDevices,
    );
  }

  testWidgets('renders all four gauge labels', (tester) async {
    await pumpAppWidget(tester, buildSubject());
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.text('85'), findsOneWidget); // health
    expect(find.text('70'), findsOneWidget); // signal
    expect(find.text('2'), findsOneWidget); // threats
    expect(find.text('12'), findsOneWidget); // devices
  });

  testWidgets('renders em-dash for null signal', (tester) async {
    await pumpAppWidget(tester, buildSubject(signalQualityPct: null));
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('tapping health gauge fires onTapHealth', (tester) async {
    var taps = 0;
    await pumpAppWidget(
      tester,
      buildSubject(onTapHealth: () => taps++),
    );
    await tester.pump(const Duration(milliseconds: 16));

    await tester.tap(find.byIcon(Icons.health_and_safety_rounded));
    expect(taps, 1);
  });

  testWidgets('tapping wifi gauge fires onTapSignal', (tester) async {
    var taps = 0;
    await pumpAppWidget(
      tester,
      buildSubject(onTapSignal: () => taps++),
    );
    await tester.pump(const Duration(milliseconds: 16));

    await tester.tap(find.byIcon(Icons.wifi_rounded));
    expect(taps, 1);
  });

  testWidgets('tapping warning gauge fires onTapThreats', (tester) async {
    var taps = 0;
    await pumpAppWidget(
      tester,
      buildSubject(onTapThreats: () => taps++),
    );
    await tester.pump(const Duration(milliseconds: 16));

    await tester.tap(find.byIcon(Icons.warning_amber_rounded));
    expect(taps, 1);
  });

  testWidgets('tapping devices gauge fires onTapDevices', (tester) async {
    var taps = 0;
    await pumpAppWidget(
      tester,
      buildSubject(onTapDevices: () => taps++),
    );
    await tester.pump(const Duration(milliseconds: 16));

    await tester.tap(find.byIcon(Icons.devices_other_rounded));
    expect(taps, 1);
  });

  // The gauges are a 12px icon over a bare number inside a CustomPaint ring —
  // nothing a screen reader can make sense of without an explicit label.
  testWidgets('each gauge is exposed as a labelled button', (tester) async {
    final handle = tester.ensureSemantics();

    await pumpAppWidget(
      tester,
      RadialDashboardCore(
        statusColor: Colors.green,
        label: 'SECURE',
        subLabel: 'HomeNet',
        healthScore: 82,
        signalQualityPct: 64,
        threatCount: 2,
        deviceCount: 7,
        onTapHealth: () {},
        onTapSignal: () {},
        onTapThreats: () {},
        onTapDevices: () {},
        onTapCore: () {},
      ),
      surfaceSize: const Size(500, 500),
    );
    await tester.pump(const Duration(milliseconds: 800));

    expect(
      find.bySemanticsLabel(RegExp(r'Network health 82 out of 100')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'Signal quality 64 percent')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'2 active security alerts')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'7 devices on the network')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'Network status: SECURE, HomeNet')),
      findsOneWidget,
    );

    handle.dispose();
  });

  testWidgets('unknown signal reads as unknown, not as zero', (tester) async {
    final handle = tester.ensureSemantics();

    await pumpAppWidget(
      tester,
      RadialDashboardCore(
        statusColor: Colors.grey,
        label: 'SCANNING',
        subLabel: '—',
        healthScore: 0,
        signalQualityPct: null,
        threatCount: 0,
        deviceCount: 0,
        onTapSignal: () {},
      ),
      surfaceSize: const Size(500, 500),
    );
    await tester.pump(const Duration(milliseconds: 800));

    expect(
      find.bySemanticsLabel(RegExp(r'Signal quality unknown')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'No active security alerts')),
      findsOneWidget,
    );

    handle.dispose();
  });

  testWidgets('gauge tap targets meet the 48px minimum', (tester) async {
    await pumpAppWidget(
      tester,
      RadialDashboardCore(
        statusColor: Colors.green,
        label: 'SECURE',
        subLabel: 'HomeNet',
        healthScore: 82,
        signalQualityPct: 64,
        threatCount: 0,
        deviceCount: 3,
        onTapHealth: () {},
      ),
      surfaceSize: const Size(500, 500),
    );
    await tester.pump(const Duration(milliseconds: 800));

    final targets = tester.widgetList<SizedBox>(
      find.descendant(
        of: find.byType(RadialDashboardCore),
        matching: find.byType(SizedBox),
      ),
    );
    final gaugeTargets = targets.where((b) => b.width == 48 && b.height == 48);
    expect(gaugeTargets, hasLength(4));
  });
}
