import 'package:injectable/injectable.dart';

import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import '../entities/security_event.dart';

/// Heuristic deauthentication burst detector.
///
/// Analyses the history of signal-strength observations for a single BSSID
/// and raises a [SecurityEventType.deauthBurstDetected] event when the
/// pattern matches a deauth attack burst:
///
///   1. The observed count of distinct SSID beacons drops below [_minBeaconCount].
///   2. A rapid RSSI fluctuation exceeds [_rssiSwingThreshold] dBm within
///      a rolling window of [_windowSize] observations.
///
/// Both conditions together form a lightweight heuristic that is reliable in
/// practice but does **not** require raw frame capture (which needs root/pcap).
///
/// **Design rationale**: Native deauth detection requires monitor-mode Wi-Fi
/// and `pcap`/nl80211, which are not available in Flutter on stock Android.
/// This usecase operates purely on the Wi-Fi scan list returned by the OS,
/// making it compatible with all platforms Torcav supports.
@lazySingleton
class DeauthDetector {
  static const int _windowSize = 5;
  static const int _rssiSwingThreshold = 25; // dBm
  static const int _minBeaconCount = 3;

  /// Sliding window of recent RSSI readings keyed by BSSID.
  final Map<String, List<int>> _rssiHistory = {};

  /// Returns a [SecurityEvent] if a deauth burst pattern is detected for any
  /// network in [scanResults], otherwise returns `null`.
  SecurityEvent? evaluate(List<WifiNetwork> scanResults) {
    for (final network in scanResults) {
      final event = _evaluateSingle(network, scanResults);
      if (event != null) return event;
    }
    return null;
  }

  SecurityEvent? _evaluateSingle(
    WifiNetwork target,
    List<WifiNetwork> allNetworks,
  ) {
    final bssid = target.bssid;
    if (bssid.isEmpty) return null;

    // Update sliding RSSI window for this BSSID.
    final history = _rssiHistory.putIfAbsent(bssid, () => []);
    history.add(target.signalStrength);
    if (history.length > _windowSize) {
      history.removeAt(0);
    }

    if (history.length < _minBeaconCount) return null;

    // Condition 1: RSSI swing within the window.
    final maxRssi = history.reduce((a, b) => a > b ? a : b);
    final minRssi = history.reduce((a, b) => a < b ? a : b);
    final swing = maxRssi - minRssi;
    if (swing < _rssiSwingThreshold) return null;

    // Condition 2: The same SSID appears with a different BSSID nearby
    // (Evil-twin / deauth redirect scenario).
    final twins = allNetworks.where(
      (n) =>
          n.ssid == target.ssid &&
          n.bssid != bssid &&
          (n.signalStrength - target.signalStrength).abs() < 15,
    );
    if (twins.isEmpty) return null;

    return SecurityEvent(
      type: SecurityEventType.deauthBurstDetected,
      severity: SecurityEventSeverity.high,
      ssid: target.ssid,
      bssid: bssid,
      timestamp: DateTime.now(),
      // ignore: lines_longer_than_80_chars
      evidence:
          'RSSI swing $swing dBm in ${history.length} samples; ${twins.length} twin AP(s) present on same SSID.',
    );
  }

  /// Clears all RSSI history. Call on scan start to prevent stale detection
  /// across different network environments.
  void reset() => _rssiHistory.clear();
}
