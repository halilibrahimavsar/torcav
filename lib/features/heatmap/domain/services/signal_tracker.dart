import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:torcav/core/logging/app_logger.dart';
import 'package:torcav/features/wifi_scan/domain/entities/scan_request.dart';
import 'package:torcav/features/wifi_scan/domain/usecases/scan_wifi.dart';

import 'package:torcav/features/heatmap/domain/services/connected_signal_service.dart';
import 'package:torcav/features/heatmap/domain/services/connected_signal_smoother.dart';
import 'package:network_info_plus/network_info_plus.dart';

/// Represents the current signal state for the heatmap.
class SignalState {
  const SignalState({
    this.targetBssid,
    this.targetSsid,
    this.currentRssi,
    this.lastSignalAt,
    this.stdDev = 0.0,
    this.sampleCount = 0,
  });

  final String? targetBssid;
  final String? targetSsid;
  final int? currentRssi;
  final DateTime? lastSignalAt;
  final double stdDev;
  final int sampleCount;

  SignalState copyWith({
    String? targetBssid,
    String? targetSsid,
    int? currentRssi,
    DateTime? lastSignalAt,
    double? stdDev,
    int? sampleCount,
    bool clearRssi = false,
  }) =>
      SignalState(
        targetBssid: targetBssid ?? this.targetBssid,
        targetSsid: targetSsid ?? this.targetSsid,
        currentRssi: clearRssi ? null : (currentRssi ?? this.currentRssi),
        lastSignalAt: clearRssi ? null : (lastSignalAt ?? this.lastSignalAt),
        stdDev: clearRssi ? 0.0 : (stdDev ?? this.stdDev),
        sampleCount: clearRssi ? 0 : (sampleCount ?? this.sampleCount),
      );
}

/// Service responsible for tracking and smoothing the connected Wi-Fi signal.
/// Handles polling, metadata scanning, and target AP resolution.
@LazySingleton()
class SignalTracker {
  SignalTracker(
    this._connectedSignalService,
    this._signalSmoother,
    this._scanWifi,
    this._networkInfo,
  );

  final ConnectedSignalService _connectedSignalService;
  final ConnectedSignalSmoother _signalSmoother;
  final ScanWifi _scanWifi;
  final NetworkInfo _networkInfo;

  static const _pollInterval = Duration(milliseconds: 800);
  static const _scanCooldown = Duration(seconds: 30);
  static const _signalWindowSize = 3;
  // BUG-16: Discard samples older than this threshold before averaging.
  // Reduced to 3s for higher movement sensitivity.
  static const _signalStalenessSeconds = 3;

  final _stateController = StreamController<SignalState>.broadcast();
  Stream<SignalState> get stateStream => _stateController.stream;

  Timer? _pollTimer;
  SignalState _currentState = const SignalState();
  // Each entry is (timestamp, rssi). Stored as records for zero-allocation access.
  final List<({DateTime ts, int rssi})> _signalWindow = [];
  DateTime? _lastScanTime;

  /// Starts the tracking process. Resolves target AP and begins polling.
  Future<void> start(String? initialBssid, String? initialSsid) async {
    _currentState = SignalState(
      targetBssid: initialBssid,
      targetSsid: initialSsid,
    );
    _signalWindow.clear();
    _lastScanTime = null;

    if (_currentState.targetBssid == null) {
      await _resolveTarget();
    }

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
    
    // Initial poll
    await _poll();
  }

  /// Stops tracking and clears resources.
  void stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _signalWindow.clear();
  }

  Future<void> _resolveTarget() async {
    try {
      final sample = await _connectedSignalService.getConnectedSignal();
      String? bssid = sample?.bssid.toUpperCase();
      String? ssid = sample?.ssid;

      bssid ??= (await _networkInfo.getWifiBSSID())?.toUpperCase();
      ssid ??= (await _networkInfo.getWifiName())?.replaceAll('"', '');

      _updateState(_currentState.copyWith(
        targetBssid: bssid,
        targetSsid: ssid,
      ));
    } catch (e) {
      AppLogger.e('Failed to resolve target AP', error: e);
    }
  }

  Future<void> _poll() async {
    final sample = await _connectedSignalService.getConnectedSignal();
    
    if (sample == null) {
      _signalWindow.clear();
      _updateState(_currentState.copyWith(clearRssi: true));
      return;
    }

    final normalizedBssid = sample.bssid.toUpperCase();
    if (_currentState.targetBssid == null) {
      _updateState(_currentState.copyWith(
        targetBssid: normalizedBssid,
        targetSsid: sample.ssid,
      ));
    } else if (normalizedBssid != _currentState.targetBssid) {
      _signalWindow.clear();
      _updateState(_currentState.copyWith(clearRssi: true));
      return;
    }

    _signalWindow.add((ts: sample.timestamp, rssi: sample.rssi));
    // BUG-16: Trim the window to size, then evict entries older than the
    // staleness threshold so a throttled scan rate doesn't hide real drops.
    if (_signalWindow.length > _signalWindowSize) {
      _signalWindow.removeAt(0);
    }
    final cutoff = DateTime.now().subtract(
      const Duration(seconds: _signalStalenessSeconds),
    );
    _signalWindow.removeWhere((e) => e.ts.isBefore(cutoff));

    final smoothed = _signalSmoother.smooth(
      _signalWindow.map((e) => e.rssi).toList(),
    );
    if (smoothed == null) {
      _updateState(_currentState.copyWith(clearRssi: true));
      return;
    }

    _updateState(_currentState.copyWith(
      currentRssi: smoothed.rssi,
      lastSignalAt: sample.timestamp,
      stdDev: smoothed.stdDev,
      sampleCount: smoothed.sampleCount,
      targetSsid: sample.ssid.isEmpty ? _currentState.targetSsid : sample.ssid,
    ));

    final now = DateTime.now();
    if (_lastScanTime == null || now.difference(_lastScanTime!) > _scanCooldown) {
      unawaited(runMetadataScan());
    }
  }

  Future<void> runMetadataScan() async {
    _lastScanTime = DateTime.now();
    final result = await _scanWifi(
      request: const ScanRequest(passes: 3, passIntervalMs: 300),
    );

    result.fold((_) {}, (snapshot) {
      final match = snapshot.networks.where(
        (n) => n.bssid.toUpperCase() == _currentState.targetBssid,
      ).firstOrNull;

      if (match != null) {
        _updateState(_currentState.copyWith(
          targetSsid: match.ssid.isEmpty ? _currentState.targetSsid : match.ssid,
          stdDev: match.signalStdDev > _currentState.stdDev ? match.signalStdDev : _currentState.stdDev,
        ));
      }
    });
  }

  void _updateState(SignalState newState) {
    _currentState = newState;
    _stateController.add(_currentState);
  }

  void dispose() {
    stop();
    _stateController.close();
  }
}
