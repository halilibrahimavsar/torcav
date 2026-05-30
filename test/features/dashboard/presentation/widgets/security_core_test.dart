import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/features/dashboard/presentation/widgets/security_core.dart';

import '../../../../helpers/widget_pump.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('renders label and subLabel uppercased / verbatim', (
    tester,
  ) async {
    await pumpAppWidget(
      tester,
      const SecurityCore(label: 'secure', subLabel: '95%'),
    );
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.text('SECURE'), findsOneWidget);
    expect(find.text('95%'), findsOneWidget);
  });

  testWidgets('shows spinner when isLoading is true', (tester) async {
    await pumpAppWidget(
      tester,
      const SecurityCore(
        label: 'loading',
        subLabel: '—',
        isLoading: true,
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('does not show spinner by default', (tester) async {
    await pumpAppWidget(
      tester,
      const SecurityCore(label: 'safe', subLabel: '100%'),
    );
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('respects custom statusColor', (tester) async {
    const red = Color(0xFFFF3344);
    await pumpAppWidget(
      tester,
      const SecurityCore(
        label: 'critical',
        subLabel: '20%',
        statusColor: red,
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));

    final labelText = tester.widget<Text>(find.text('CRITICAL'));
    expect(labelText.style?.color, red);
  });
}
