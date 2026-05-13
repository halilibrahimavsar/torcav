import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/security/domain/entities/evil_twin_assessment.dart';
import 'package:torcav/features/security/domain/services/evil_twin_explainer.dart';

void main() {
  const explainer = EvilTwinExplainer();

  test('dismissed pair gets a "Safe" label', () {
    const a = EvilTwinAssessment.legitimate(
      ssid: 'Home',
      peerBssid: 'AA:BB:CC:DD:EE:02',
      mitigations: [EvilTwinSignal.bssidProximity],
    );
    final exp = explainer.explain(a);
    expect(exp.confidenceLabel, 'Safe');
  });

  test('no candidate → Low', () {
    const a = EvilTwinAssessment.none('Home');
    expect(explainer.explain(a).confidenceLabel, 'Low');
  });

  test('high-confidence assessment yields "High" label', () {
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
    expect(explainer.explain(a).confidenceLabel, 'High');
  });

  test('medium-confidence assessment yields "Medium" label', () {
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
    expect(explainer.explain(a).confidenceLabel, 'Medium');
  });

  test('low-confidence assessment yields "Low" label', () {
    final a = EvilTwinAssessment(
      confidence: 0.55,
      isCandidate: true,
      dismissedAsLegitimate: false,
      suspicions: const [EvilTwinSignal.ouiMismatch],
      mitigations: const [],
      peerBssid: '11:22:33:44:55:66',
      ssid: 'Home',
    );
    expect(explainer.explain(a).confidenceLabel, 'Low');
  });
}
