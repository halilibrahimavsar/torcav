import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/security/domain/entities/evil_twin_assessment.dart';
import 'package:torcav/features/security/domain/services/evil_twin_explainer.dart';

void main() {
  const explainer = EvilTwinExplainer();

  test('dismissed pair gets a "Safe" explanation with no actions to take', () {
    const a = EvilTwinAssessment.legitimate(
      ssid: 'Home',
      peerBssid: 'AA:BB:CC:DD:EE:02',
      mitigations: [EvilTwinSignal.bssidProximity],
    );
    final exp = explainer.explain(a);
    expect(exp.confidenceLabel, 'Safe');
    expect(exp.headline.toLowerCase(), contains('same router'));
    expect(exp.recommendedActions, isNotEmpty);
    expect(exp.observedSignals, isEmpty);
    expect(exp.mitigationSignals, isNotEmpty);
  });

  test('high-confidence assessment recommends disconnecting first', () {
    final a = EvilTwinAssessment(
      confidence: 0.85,
      isCandidate: true,
      dismissedAsLegitimate: false,
      suspicions: const [
        EvilTwinSignal.ouiMismatch,
        EvilTwinSignal.securityDowngrade,
      ],
      mitigations: const [],
      peerBssid: '11:22:33:44:55:66',
      ssid: 'Home',
    );
    final exp = explainer.explain(a);
    expect(exp.confidenceLabel, 'High');
    expect(
      exp.recommendedActions.first.toLowerCase(),
      contains('disconnect'),
    );
    expect(exp.observedSignals.length, 2);
  });

  test('medium-confidence flag warns without forcing disconnect', () {
    final a = EvilTwinAssessment(
      confidence: 0.62,
      isCandidate: true,
      dismissedAsLegitimate: false,
      suspicions: const [
        EvilTwinSignal.ouiMismatch,
        EvilTwinSignal.channelWidthMismatch,
      ],
      mitigations: const [],
      peerBssid: '11:22:33:44:55:66',
      ssid: 'Home',
    );
    final exp = explainer.explain(a);
    expect(exp.confidenceLabel, 'Medium');
    expect(
      exp.recommendedActions.first.toLowerCase(),
      isNot(contains('disconnect')),
    );
  });

  test('every confidence path produces non-empty whatIs / whyItMatters', () {
    const cases = [
      EvilTwinAssessment.legitimate(
        ssid: 'Home',
        peerBssid: 'AA:BB:CC:DD:EE:02',
        mitigations: [EvilTwinSignal.bssidProximity],
      ),
      EvilTwinAssessment.none('Home'),
      EvilTwinAssessment(
        confidence: 0.55,
        isCandidate: true,
        dismissedAsLegitimate: false,
        suspicions: [EvilTwinSignal.ouiMismatch],
        mitigations: [],
        peerBssid: '11:22:33:44:55:66',
        ssid: 'Home',
      ),
    ];
    for (final a in cases) {
      final exp = explainer.explain(a);
      expect(exp.whatIs, isNotEmpty);
      expect(exp.whyItMatters, isNotEmpty);
      expect(exp.confidencePhrase, isNotEmpty);
    }
  });
}
