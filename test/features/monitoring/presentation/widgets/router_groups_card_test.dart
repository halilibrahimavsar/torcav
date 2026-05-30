import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/features/monitoring/domain/router_grouping.dart';
import 'package:torcav/features/monitoring/presentation/widgets/router_groups_card.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/widget_pump.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildSubject({
    required List<RouterGroup> groups,
    void Function(int)? onJumpToBand,
  }) {
    return RouterGroupsCard(
      groups: groups,
      ratingFor: (_) => const {},
      onJumpToBand: onJumpToBand ?? (_) {},
    );
  }

  testWidgets('empty group list renders SizedBox.shrink (no UI)', (
    tester,
  ) async {
    await pumpAppWidget(tester, buildSubject(groups: const []));
    await tester.pump();

    expect(find.byIcon(Icons.router_outlined), findsNothing);
  });

  testWidgets('renders header and SSID for each group', (tester) async {
    final group = RouterGroup(
      ssid: 'MyHomeNet',
      bssidPrefix: 'AABBCCDDEE',
      radios: [
        buildWifiNetwork(
          ssid: 'MyHomeNet',
          bssid: 'AA:BB:CC:DD:EE:01',
        ),
        buildWifiNetwork(
          ssid: 'MyHomeNet',
          bssid: 'AA:BB:CC:DD:EE:11',
          frequency: 5180,
          signalStrength: -60,
        ),
      ],
    );

    await pumpAppWidget(
      tester,
      buildSubject(groups: [group]),
      surfaceSize: const Size(600, 800),
    );
    await tester.pump();

    expect(find.byIcon(Icons.router_outlined), findsOneWidget);
    expect(find.text('MyHomeNet'), findsOneWidget);
  });

  testWidgets('tapping a band chip invokes onJumpToBand', (tester) async {
    final group = RouterGroup(
      ssid: 'HomeNet',
      bssidPrefix: 'AABBCCDDEE',
      radios: [
        buildWifiNetwork(
          ssid: 'HomeNet',
          bssid: 'AA:BB:CC:DD:EE:01',
        ),
        buildWifiNetwork(
          ssid: 'HomeNet',
          bssid: 'AA:BB:CC:DD:EE:11',
          frequency: 5180,
          signalStrength: -60,
        ),
      ],
    );

    final taps = <int>[];
    await pumpAppWidget(
      tester,
      buildSubject(groups: [group], onJumpToBand: taps.add),
      surfaceSize: const Size(600, 800),
    );
    await tester.pump();

    final inkWells = find.byType(InkWell);
    expect(inkWells, findsAtLeastNWidgets(1));
    await tester.tap(inkWells.first, warnIfMissed: false);
    await tester.pump();

    expect(taps, isNotEmpty);
  });
}
