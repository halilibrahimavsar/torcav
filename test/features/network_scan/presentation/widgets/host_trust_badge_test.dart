import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/features/network_scan/domain/entities/host_trust_assessment.dart';
import 'package:torcav/features/network_scan/presentation/widgets/host_trust_badge.dart';

import '../../../../helpers/widget_pump.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  HostTrustAssessment assess(HostTrustLevel level) {
    return HostTrustAssessment(
      level: level,
      headline: 'sample headline',
      reasons: const [HostTrustReason(summary: 'open port 23')],
    );
  }

  testWidgets('safe level uses verified icon', (tester) async {
    await pumpAppWidget(
      tester,
      HostTrustBadge(assessment: assess(HostTrustLevel.safe)),
    );
    await tester.pump();
    expect(find.byIcon(Icons.verified_user_rounded), findsOneWidget);
  });

  testWidgets('caution level uses shield_outlined icon', (tester) async {
    await pumpAppWidget(
      tester,
      HostTrustBadge(assessment: assess(HostTrustLevel.caution)),
    );
    await tester.pump();
    expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
  });

  testWidgets('risky level uses gpp_bad icon', (tester) async {
    await pumpAppWidget(
      tester,
      HostTrustBadge(assessment: assess(HostTrustLevel.risky)),
    );
    await tester.pump();
    expect(find.byIcon(Icons.gpp_bad_rounded), findsOneWidget);
  });

  testWidgets('tapping opens the details modal sheet', (tester) async {
    await pumpAppWidget(
      tester,
      HostTrustBadge(assessment: assess(HostTrustLevel.risky)),
    );
    await tester.pump();

    await tester.tap(find.byType(InkWell));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('open port 23'), findsOneWidget);
  });
}
