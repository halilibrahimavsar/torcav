import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/dashboard/presentation/widgets/health_hero_card.dart';
import 'package:torcav/features/diagnostics/domain/entities/diagnosis_inputs.dart';
import 'package:torcav/features/diagnostics/domain/entities/diagnosis_result.dart';
import 'package:torcav/features/diagnostics/domain/entities/root_cause_category.dart';
import 'package:torcav/features/security/domain/entities/network_context_type.dart';

import '../../../../helpers/widget_pump.dart';

DiagnosisResult _diagnosis(RootCauseCategory cause) => DiagnosisResult(
  timestamp: DateTime(2026, 7, 7),
  primaryCause: cause,
  allEvidence: const [],
  inputs: const DiagnosisInputs(
    connectedNetwork: null,
    visibleNetworks: [],
    speedTest: null,
    gatewayPingMs: null,
    dnsBenchmark: null,
    context: NetworkContextType.unknown,
  ),
);

Widget _hero({
  int score = 92,
  bool isConnected = true,
  DiagnosisResult? diagnosis,
  void Function(RootCauseCategory)? onAction,
  VoidCallback? onFullDiagnosis,
}) {
  return HealthHeroCard(
    score: score,
    isConnected: isConnected,
    ssid: 'Lab AP',
    statusLabel: 'CONNECTED',
    diagnosis: diagnosis,
    onTapScore: () {},
    onAction: onAction ?? (_) {},
    onFullDiagnosis: onFullDiagnosis ?? () {},
  );
}

void main() {
  testWidgets('healthy verdict shows score and slow-internet CTA only', (
    tester,
  ) async {
    RootCauseCategory? tapped;
    await pumpAppWidget(
      tester,
      _hero(
        diagnosis: _diagnosis(RootCauseCategory.healthy),
        onAction: (c) => tapped = c,
      ),
      surfaceSize: const Size(800, 900),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('92'), findsOneWidget);
    expect(find.text('NETWORK HEALTHY'), findsOneWidget);
    expect(find.text('IS INTERNET SLOW?'), findsOneWidget);
    // Healthy state must not duplicate the diagnosis entry point.
    expect(find.text('See full diagnosis'), findsNothing);

    await tester.tap(find.text('IS INTERNET SLOW?'));
    expect(tapped, RootCauseCategory.healthy);
  });

  testWidgets('diagnosed cause renders verdict + one routed action', (
    tester,
  ) async {
    RootCauseCategory? tapped;
    await pumpAppWidget(
      tester,
      _hero(
        score: 55,
        diagnosis: _diagnosis(RootCauseCategory.crowdedChannel),
        onAction: (c) => tapped = c,
      ),
      surfaceSize: const Size(800, 900),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('55'), findsOneWidget);
    expect(find.text('CROWDED CHANNEL'), findsOneWidget);
    expect(find.text('BEST NEXT MOVE'), findsOneWidget);
    expect(find.text('Change Wi-Fi channel'), findsOneWidget);
    expect(find.text('See full diagnosis'), findsOneWidget);

    await tester.tap(find.text('Change Wi-Fi channel'));
    expect(tapped, RootCauseCategory.crowdedChannel);
  });

  testWidgets('missing diagnosis falls back to healthy verdict', (
    tester,
  ) async {
    await pumpAppWidget(
      tester,
      _hero(),
      surfaceSize: const Size(800, 900),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('NETWORK HEALTHY'), findsOneWidget);
  });

  testWidgets('disconnected state hides score and shows connect hint', (
    tester,
  ) async {
    await pumpAppWidget(
      tester,
      _hero(isConnected: false),
      surfaceSize: const Size(800, 900),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('92'), findsNothing);
    expect(
      find.text(
        "Connect to Wi-Fi and I'll analyze your network and summarize "
        'its health.',
      ),
      findsOneWidget,
    );
  });
}
