import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/features/network_scan/domain/entities/network_scan_profile.dart';
import 'package:torcav/features/network_scan/presentation/widgets/scan_profile_card.dart';

import '../../../../helpers/widget_pump.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('fast profile shows bolt icon and "~3-5 s" ETA', (tester) async {
    await pumpAppWidget(
      tester,
      const ScanProfileCard(profile: NetworkScanProfile.fast),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
    expect(find.text('~3-5 s'), findsOneWidget);
    expect(find.text('50×'), findsOneWidget);
    expect(find.text('FAST'), findsOneWidget);
  });

  testWidgets('balanced profile shows tune icon and balanced metrics', (
    tester,
  ) async {
    await pumpAppWidget(
      tester,
      const ScanProfileCard(profile: NetworkScanProfile.balanced),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    expect(find.text('~8-12 s'), findsOneWidget);
    expect(find.text('30×'), findsOneWidget);
  });

  testWidgets('aggressive profile shows travel_explore icon and slow ETA', (
    tester,
  ) async {
    await pumpAppWidget(
      tester,
      const ScanProfileCard(profile: NetworkScanProfile.aggressive),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byIcon(Icons.travel_explore_rounded), findsOneWidget);
    expect(find.text('~20-40 s'), findsOneWidget);
    expect(find.text('15×'), findsOneWidget);
  });
}
