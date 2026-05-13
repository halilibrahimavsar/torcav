import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/diagnostics/domain/entities/diagnosis_inputs.dart';
import 'package:torcav/features/diagnostics/domain/entities/root_cause_category.dart';
import 'package:torcav/features/diagnostics/domain/usecases/diagnose_usecase.dart';
import 'package:torcav/features/performance/domain/entities/speed_test_result.dart';
import 'package:torcav/features/security/domain/entities/dns_test_result.dart';
import 'package:torcav/features/security/domain/entities/network_context_type.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/features/wifi_scan/domain/services/channel_rating_engine.dart';

void main() {
  late DiagnoseUseCase useCase;

  setUp(() {
    useCase = DiagnoseUseCase(ChannelRatingEngine());
  });

  WifiNetwork connected({
    int rssi = -50,
    int channel = 36,
    int frequency = 5180,
    double phy = 866,
  }) {
    return WifiNetwork(
      ssid: 'Home',
      bssid: 'AA:BB:CC:DD:EE:FF',
      signalStrength: rssi,
      channel: channel,
      frequency: frequency,
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

  DiagnosisInputs build({
    WifiNetwork? connectedNetwork,
    List<WifiNetwork> visible = const [],
    SpeedTestResult? speedTest,
    DnsBenchmarkResult? dns,
    NetworkContextType context = NetworkContextType.home,
  }) {
    return DiagnosisInputs(
      connectedNetwork: connectedNetwork ?? connected(),
      visibleNetworks: visible,
      speedTest: speedTest ?? speed(),
      gatewayPingMs: null,
      dnsBenchmark: dns,
      context: context,
    );
  }

  test('healthy when every probe is well within thresholds', () {
    final result = useCase(
      build(
        connectedNetwork: connected(rssi: -45),
        speedTest: speed(download: 200, latency: 10, loaded: 14),
        dns: const DnsBenchmarkResult(
          name: 'Cloudflare',
          primaryIp: '1.1.1.1',
          latencyMs: 12,
          features: [],
        ),
      ),
    );
    expect(result.primaryCause, RootCauseCategory.healthy);
  });

  test('flags weak signal when RSSI is severe', () {
    final result = useCase(build(connectedNetwork: connected(rssi: -82)));
    expect(result.primaryCause, RootCauseCategory.weakSignal);
    final ev = result.allEvidence.firstWhere(
      (e) => e.category == RootCauseCategory.weakSignal,
    );
    expect(ev.severity, greaterThanOrEqualTo(0.9));
  });

  test('flags bufferbloat when induced latency is high', () {
    final result = useCase(build(speedTest: speed(latency: 15, loaded: 250)));
    expect(result.primaryCause, RootCauseCategory.bufferbloat);
  });

  test('flags slow DNS when best resolver latency is high', () {
    final result = useCase(
      build(
        dns: const DnsBenchmarkResult(
          name: 'Slow',
          primaryIp: '8.8.8.8',
          latencyMs: 280,
          features: [],
        ),
      ),
    );
    expect(result.primaryCause, RootCauseCategory.slowDns);
  });

  test('flags ISP slow when PHY is fast but download is low', () {
    final result = useCase(
      build(
        connectedNetwork: connected(),
        speedTest: speed(download: 5, latency: 10, loaded: 14),
      ),
    );
    expect(result.primaryCause, RootCauseCategory.ispSlow);
  });

  test('suppresses ISP-slow on public networks', () {
    final result = useCase(
      build(
        connectedNetwork: connected(),
        speedTest: speed(download: 5, latency: 10, loaded: 14),
        context: NetworkContextType.public,
      ),
    );
    expect(result.primaryCause, isNot(RootCauseCategory.ispSlow));
  });

  test('skips weak-signal when no connected network', () {
    final result = useCase(
      DiagnosisInputs(
        connectedNetwork: null,
        visibleNetworks: const [],
        speedTest: speed(),
        gatewayPingMs: null,
        dnsBenchmark: null,
        context: NetworkContextType.unknown,
      ),
    );
    final hasWeakSignal = result.allEvidence.any(
      (e) => e.category == RootCauseCategory.weakSignal,
    );
    expect(hasWeakSignal, isFalse);
  });
}
