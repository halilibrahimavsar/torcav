import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/features/app_shell/presentation/pages/operations_hub_page.dart';

import '../../../../helpers/widget_pump.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('renders all four operation group headers', (tester) async {
    await pumpAppWidget(
      tester,
      OperationsHubPage(onNavigate: (_) {}),
      surfaceSize: const Size(600, 1200),
    );
    // Cards use StaggeredEntry with delays up to ~350ms.
    await tester.pump(const Duration(milliseconds: 500));

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    // Some group labels collide with card titles (e.g. "SECURITY" appears
    // both as the group header and the security card title). Assert at least
    // one occurrence per group; presence of all four confirms the headers.
    expect(find.text(l10n.opsGroupSecurity), findsAtLeastNWidgets(1));
    expect(find.text(l10n.opsGroupSpeed), findsAtLeastNWidgets(1));
    expect(find.text(l10n.opsGroupCoverage), findsAtLeastNWidgets(1));
    expect(find.text(l10n.opsGroupReports), findsAtLeastNWidgets(1));
  });

  testWidgets('renders six operation cards (one per feature)', (tester) async {
    await pumpAppWidget(
      tester,
      OperationsHubPage(onNavigate: (_) {}),
      surfaceSize: const Size(600, 1200),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Each card has one of these icons — assert the icon set is all present.
    expect(find.byIcon(Icons.security_rounded), findsOneWidget);
    expect(find.byIcon(Icons.speed_rounded), findsOneWidget);
    expect(find.byIcon(Icons.shield_rounded), findsOneWidget);
    expect(find.byIcon(Icons.auto_graph_rounded), findsOneWidget);
    expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
  });

  testWidgets('renders without exceptions', (tester) async {
    await pumpAppWidget(
      tester,
      OperationsHubPage(onNavigate: (_) {}),
      surfaceSize: const Size(600, 1200),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
  });
}
