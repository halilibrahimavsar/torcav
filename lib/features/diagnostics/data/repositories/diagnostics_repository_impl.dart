import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../../heatmap/domain/services/connected_signal_service.dart';
import '../../../monitoring/domain/usecases/ping_node_usecase.dart';
import '../../../performance/domain/entities/speed_test_progress.dart';
import '../../../performance/domain/entities/speed_test_result.dart';
import '../../../performance/domain/usecases/run_speed_test_usecase.dart';
import '../../../security/data/datasources/dns_test_data_source.dart';
import '../../../security/domain/entities/dns_test_result.dart';
import '../../../security/domain/entities/network_context_type.dart';
import '../../../security/domain/services/network_context_resolver.dart';
import '../../../wifi_scan/domain/entities/wifi_network.dart';
import '../../../wifi_scan/domain/services/scan_session_store.dart';
import '../../domain/entities/diagnosis_inputs.dart';
import '../../domain/repositories/diagnostics_repository.dart';

@LazySingleton(as: DiagnosticsRepository)
class DiagnosticsRepositoryImpl implements DiagnosticsRepository {
  final RunSpeedTestUseCase _runSpeedTest;
  final DnsDataSource _dnsDataSource;
  final ConnectedSignalService _connectedSignal;
  final ScanSessionStore _scanStore;
  final NetworkContextResolver _contextResolver;
  final PingNodeUseCase _pingNode;
  final NetworkInfo _networkInfo;

  DiagnosticsRepositoryImpl(
    this._runSpeedTest,
    this._dnsDataSource,
    this._connectedSignal,
    this._scanStore,
    this._contextResolver,
    this._pingNode,
    this._networkInfo,
  );

  @override
  Stream<DiagnosticsProgress> collectInputs() async* {
    // Step 1: signal + visible networks (cheap, sync-ish).
    yield const DiagnosticsProgress(
      step: DiagnosticsStep.signal,
      progress: 0.05,
    );

    final visible =
        _scanStore.latest?.toLegacyNetworks() ?? const <WifiNetwork>[];
    final connectedSignal = await _connectedSignal.getConnectedSignal();
    final connected = _resolveConnectedNetwork(visible, connectedSignal);

    yield DiagnosticsProgress(
      step: DiagnosticsStep.channel,
      progress: 0.15,
      partialInputs: DiagnosisInputs(
        connectedNetwork: connected,
        visibleNetworks: visible,
        speedTest: null,
        gatewayPingMs: null,
        dnsBenchmark: null,
        context: NetworkContextType.unknown,
      ),
    );

    // Step 2: kick off speed test, DNS benchmark, and gateway ping in parallel.
    final dnsFuture = _safeDnsBenchmark();
    final contextFuture = _safeContext(connected);
    final gatewayPingFuture = _safeGatewayPing();

    yield const DiagnosticsProgress(
      step: DiagnosticsStep.speedTest,
      progress: 0.25,
    );

    SpeedTestResult? speedTest;
    await for (final progress in _safeSpeedTestStream()) {
      // Map speed-test phase progress (0..1 across latency/download/upload)
      // into the 0.25 .. 0.85 slice of overall progress.
      final phaseFraction = _phaseFraction(progress.phase);
      yield DiagnosticsProgress(
        step: DiagnosticsStep.speedTest,
        progress: 0.25 + phaseFraction * 0.6,
      );
      if (progress.phase == SpeedTestPhase.done) {
        speedTest = SpeedTestResult(
          recordedAt: DateTime.now(),
          latencyMs: progress.latencyMs,
          jitterMs: progress.jitterMs,
          downloadMbps: progress.downloadMbps,
          uploadMbps: progress.uploadMbps,
          packetLoss: progress.packetLoss,
          loadedLatencyMs: progress.loadedLatencyMs,
        );
      }
    }

    yield const DiagnosticsProgress(step: DiagnosticsStep.dns, progress: 0.9);

    final dns = await dnsFuture;
    final context = await contextFuture;
    final gatewayPing = await gatewayPingFuture;

    final inputs = DiagnosisInputs(
      connectedNetwork: connected,
      visibleNetworks: visible,
      speedTest: speedTest,
      gatewayPingMs: gatewayPing,
      dnsBenchmark: dns,
      context: context,
    );

    yield DiagnosticsProgress(
      step: DiagnosticsStep.finalize,
      progress: 1.0,
      partialInputs: inputs,
    );
  }

  /// Build a [WifiNetwork] for the currently-connected AP. Prefers a row from
  /// the latest scan (it carries PHY rate / channel width / standard) and
  /// falls back to a synthetic record from [ConnectedSignal] alone.
  WifiNetwork? _resolveConnectedNetwork(
    List<WifiNetwork> visible,
    connectedSignal,
  ) {
    if (connectedSignal == null) return null;
    final bssid = (connectedSignal.bssid as String).toUpperCase();
    for (final net in visible) {
      if (net.bssid.toUpperCase() == bssid) {
        // Trust the live RSSI from the connected-signal channel — it's
        // typically fresher than the scan sample.
        return net.copyWith(signalStrength: connectedSignal.rssi as int);
      }
    }
    return WifiNetwork(
      ssid: connectedSignal.ssid as String,
      bssid: bssid,
      signalStrength: connectedSignal.rssi as int,
      channel: 0,
      frequency: connectedSignal.frequency as int,
      security: SecurityType.unknown,
    );
  }

  Future<DnsBenchmarkResult?> _safeDnsBenchmark() async {
    try {
      final group = await _dnsDataSource.runBenchmarkWithDnssec();
      if (group.benchmarks.isEmpty) return null;
      // benchmarks are pre-sorted ascending by latency; the first non-failed
      // entry is the winner.
      for (final b in group.benchmarks) {
        if (b.latencyMs >= 0) return b;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Resolve the default gateway IP via [NetworkInfo] and ping it. Best-
  /// effort: any failure (no Wi-Fi, permission denied, ICMP blocked)
  /// returns null and the caller treats gateway latency as unknown.
  Future<int?> _safeGatewayPing() async {
    try {
      final gateway = await _networkInfo.getWifiGatewayIP();
      if (gateway == null || gateway.isEmpty) return null;
      final result = await _pingNode(gateway);
      return result.fold((_) => null, (latency) => latency);
    } catch (_) {
      return null;
    }
  }

  Future<NetworkContextType> _safeContext(WifiNetwork? connected) async {
    if (connected == null) return NetworkContextType.unknown;
    try {
      return await _contextResolver.resolve(connected);
    } catch (_) {
      return NetworkContextType.unknown;
    }
  }

  Stream<SpeedTestProgress> _safeSpeedTestStream() async* {
    try {
      yield* _runSpeedTest.call();
    } catch (_) {
      yield const SpeedTestProgress(phase: SpeedTestPhase.done);
    }
  }

  double _phaseFraction(SpeedTestPhase phase) {
    switch (phase) {
      case SpeedTestPhase.idle:
        return 0;
      case SpeedTestPhase.latency:
        return 0.2;
      case SpeedTestPhase.download:
        return 0.6;
      case SpeedTestPhase.upload:
        return 0.85;
      case SpeedTestPhase.done:
        return 1.0;
    }
  }
}
