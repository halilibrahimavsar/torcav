import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/diagnostics/domain/entities/diagnosis_evidence.dart';
import 'package:torcav/features/diagnostics/domain/entities/diagnosis_inputs.dart';
import 'package:torcav/features/diagnostics/domain/entities/root_cause_category.dart';
import 'package:torcav/features/diagnostics/domain/services/diagnosis_explainer.dart';
import 'package:torcav/features/performance/domain/entities/speed_test_result.dart';
import 'package:torcav/features/security/domain/entities/dns_test_result.dart';
import 'package:torcav/core/network/network_context_type.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

void main() {
  const explainer = DiagnosisExplainer();

  WifiNetwork network({int rssi = -50, double phy = 866}) {
    return WifiNetwork(
      ssid: 'Home',
      bssid: 'AA:BB:CC:DD:EE:FF',
      signalStrength: rssi,
      channel: 36,
      frequency: 5180,
      security: SecurityType.wpa2,
      estimatedMaxThroughputMbps: phy,
    );
  }

  SpeedTestResult speed({
    double download = 100,
    double latency = 12,
    double loaded = 18,
  }) {
    return SpeedTestResult(
      recordedAt: DateTime.now(),
      latencyMs: latency,
      jitterMs: 1,
      downloadMbps: download,
      uploadMbps: download,
      loadedLatencyMs: loaded,
    );
  }

  DiagnosisInputs inputs({
    SpeedTestResult? speedTest,
    DnsBenchmarkResult? dns,
    WifiNetwork? connected,
  }) {
    return DiagnosisInputs(
      connectedNetwork: connected ?? network(),
      visibleNetworks: const [],
      speedTest: speedTest,
      gatewayPingMs: null,
      dnsBenchmark: dns,
      context: NetworkContextType.home,
    );
  }

  test('every category produces non-empty whatIs / whyItMatters', () {
    for (final cat in RootCauseCategory.values) {
      final ev = DiagnosisEvidence(
        category: cat,
        severity: 0.6,
      );
      final exp = explainer.explain(ev, inputs(speedTest: speed()));
      expect(exp.whatIs, isNotEmpty, reason: 'whatIs for $cat');
      expect(exp.whyItMatters, isNotEmpty, reason: 'why for $cat');
    }
  });

  test('weak signal estimate scales with severity and download', () {
    const ev = DiagnosisEvidence(
      category: RootCauseCategory.weakSignal,
      severity: 0.8,
    );
    final exp = explainer.explain(
      ev,
      inputs(speedTest: speed(download: 60), connected: network(rssi: -75)),
    );
    expect(exp.estimatedImprovement, isNotNull);
    expect(exp.estimatedImprovement, contains('Mbps'));
  });

  test('bufferbloat estimate reports a latency reduction in ms', () {
    const ev = DiagnosisEvidence(
      category: RootCauseCategory.bufferbloat,
      severity: 0.9,
    );
    final exp = explainer.explain(
      ev,
      inputs(speedTest: speed(latency: 15, loaded: 250)),
    );
    expect(exp.estimatedImprovement, isNotNull);
    expect(exp.estimatedImprovement, contains('ms'));
  });

  test('slow DNS estimate reports a per-lookup reduction in ms', () {
    const ev = DiagnosisEvidence(
      category: RootCauseCategory.slowDns,
      severity: 0.8,
    );
    final exp = explainer.explain(
      ev,
      inputs(
        speedTest: speed(),
        dns: const DnsBenchmarkResult(
          name: 'Slow',
          primaryIp: '8.8.8.8',
          latencyMs: 280,
          features: [],
        ),
      ),
    );
    expect(exp.estimatedImprovement, isNotNull);
    expect(exp.estimatedImprovement, contains('per name lookup'));
  });

  test('healthy explainer never proposes an estimate or fix', () {
    const ev = DiagnosisEvidence(
      category: RootCauseCategory.healthy,
      severity: 0,
    );
    final exp = explainer.explain(ev, inputs());
    expect(exp.estimatedImprovement, isNull);
    expect(exp.howToFix, isEmpty);
  });

  test(
    'weak signal estimate suppressed when download is too low to project',
    () {
      const ev = DiagnosisEvidence(
        category: RootCauseCategory.weakSignal,
        severity: 0.6,
      );
      final exp = explainer.explain(
        ev,
        inputs(speedTest: speed(download: 0.5)),
      );
      expect(exp.estimatedImprovement, isNull);
    },
  );
}
