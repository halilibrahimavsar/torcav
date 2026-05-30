import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/features/dashboard/presentation/widgets/activity_timeline.dart';
import 'package:torcav/features/security/domain/entities/security_event.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/widget_pump.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('empty state — tapping shows scan deep-link route', (
    tester,
  ) async {
    String? captured;
    await pumpAppWidget(
      tester,
      ActivityTimeline(
        snapshots: const [],
        events: const [],
        onNavigate: (dest) => captured = dest,
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.byIcon(Icons.history_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.history_rounded));
    await tester.pump();
    expect(captured, 'wifi');
  });

  testWidgets('populated state renders cards for snapshots and events', (
    tester,
  ) async {
    await pumpAppWidget(
      tester,
      ActivityTimeline(
        snapshots: [
          buildScanSnapshot(
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            networks: [buildWifiNetwork()],
          ),
        ],
        events: [
          buildSecurityEvent(
            type: SecurityEventType.evilTwinDetected,
            timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          ),
        ],
        onNavigate: (_) {},
      ),
      surfaceSize: const Size(800, 400),
    );
    await tester.pump(const Duration(milliseconds: 16));

    // The radar (scan) icon is rendered both as background and as badge.
    expect(find.byIcon(Icons.radar_rounded), findsWidgets);
    expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
    // Empty-state hint should not appear.
    expect(find.byIcon(Icons.history_rounded), findsNothing);
  });
}
