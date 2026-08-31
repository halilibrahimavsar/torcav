import 'package:injectable/injectable.dart';

import '../../../network_scan/domain/entities/host_scan_result.dart';
import '../../../network_scan/domain/entities/host_trust_assessment.dart';
import '../../../network_scan/domain/services/host_trust_classifier.dart';
import '../../../performance/domain/entities/speed_test_result.dart';
import '../../../wifi_scan/domain/entities/wifi_network.dart';
import '../entities/home_health_report.dart';

/// Pure build function that composes a [HomeHealthReport] from whatever
/// inputs the caller has on hand. Every input is nullable — when a
/// signal is missing the corresponding dial scores 50 (neutral).
@lazySingleton
class HomeHealthReportBuilder {
  final HostTrustClassifier _trust;

  const HomeHealthReportBuilder(this._trust);

  HomeHealthReport build({
    required String connectedSsid,
    WifiNetwork? connectedNetwork,
    SpeedTestResult? speedTest,
    int? securityScore,
    List<HostScanResult> lanHosts = const [],
  }) {
    final wifiScore = _wifiScore(connectedNetwork);
    final internetScore = _internetScore(speedTest, connectedNetwork);
    final security = securityScore ?? 50;
    final lanScore = _lanScore(lanHosts);

    final stats = <String, int>{
      'lanDeviceCount': lanHosts.length,
      'lanRiskyDevices':
          lanHosts
              .where((h) => _trust.classify(h).level == HostTrustLevel.risky)
              .length,
      'connectedRssiDbm': connectedNetwork?.signalStrength ?? -100,
      'downloadMbps': speedTest?.downloadMbps.round() ?? 0,
    };

    final scores = {
      HealthDial.wifi: wifiScore,
      HealthDial.security: security,
      HealthDial.internet: internetScore,
      HealthDial.lanExposure: lanScore,
    };
    final worstEntry = scores.entries.reduce(
      (a, b) => a.value <= b.value ? a : b,
    );

    final actions = _topActions(
      worst: worstEntry.key,
      worstScore: worstEntry.value,
      lanHosts: lanHosts,
    );

    return HomeHealthReport(
      generatedAt: DateTime.now(),
      connectedSsid: connectedSsid,
      wifiScore: wifiScore,
      securityScore: security,
      internetScore: internetScore,
      lanScore: lanScore,
      headlineKey: _headlineKey(worstEntry.value),
      worstDial: worstEntry.key,
      topActions: actions,
      stats: stats,
    );
  }

  int _wifiScore(WifiNetwork? n) {
    if (n == null) return 50;
    final rssi = n.signalStrength;
    // -55 dBm or stronger → 100, -90 dBm or weaker → 0, linear in between.
    final clamped = rssi.clamp(-90, -55);
    return (((clamped + 90) / 35) * 100).round();
  }

  int _internetScore(SpeedTestResult? speed, WifiNetwork? net) {
    if (speed == null) return 50;
    // Bufferbloat penalty: induced latency above 30 ms costs up to 40 pts.
    final induced = speed.loadedLatencyMs - speed.latencyMs;
    final bufferbloatPenalty = ((induced - 30) / 200 * 40).clamp(0.0, 40.0);

    // Throughput vs PHY: at >= 50% of PHY → full marks. Below that,
    // proportional. Without a PHY estimate we score by absolute Mbps.
    final phy = net?.estimatedMaxThroughputMbps;
    var throughputScore = 60.0;
    if (phy != null && phy > 1) {
      // Real Wi-Fi rarely exceeds ~25% of PHY. Treat that ratio as a
      // full pass; downscale linearly below.
      final ratio = (speed.downloadMbps / phy).clamp(0.0, 1.0);
      throughputScore = (ratio / 0.25).clamp(0.0, 1.0) * 60;
    } else if (speed.downloadMbps >= 50) {
      throughputScore = 60;
    } else {
      throughputScore = (speed.downloadMbps / 50 * 60).clamp(0.0, 60.0);
    }

    final score = (throughputScore + (40 - bufferbloatPenalty));
    return score.round().clamp(0, 100);
  }

  int _lanScore(List<HostScanResult> hosts) {
    if (hosts.isEmpty) return 80; // neutral-positive when nothing scanned
    var penalty = 0;
    for (final host in hosts) {
      final trust = _trust.classify(host);
      switch (trust.level) {
        case HostTrustLevel.risky:
          penalty += 25;
        case HostTrustLevel.caution:
          penalty += 8;
        case HostTrustLevel.safe:
          break;
      }
    }
    return (100 - penalty).clamp(0, 100);
  }

  /// The headline key. The dial it refers to travels separately as
  /// [HomeHealthReport.worstDial] so the sentence can be assembled in the
  /// reader's language rather than by string concatenation here.
  String _headlineKey(int worstScore) {
    if (worstScore >= 80) return 'healthHeadlineGreat';
    if (worstScore >= 60) return 'healthHeadlineFocus';
    return 'healthHeadlineAttention';
  }

  List<HealthAction> _topActions({
    required HealthDial worst,
    required int worstScore,
    required List<HostScanResult> lanHosts,
  }) {
    if (worstScore >= 80) {
      return const [HealthAction('healthActionMonthlyRecheck')];
    }

    final actions = <HealthAction>[];
    switch (worst) {
      case HealthDial.wifi:
        actions.add(const HealthAction('healthActionWifi'));
      case HealthDial.security:
        actions.add(const HealthAction('healthActionSecurity'));
      case HealthDial.internet:
        actions.add(const HealthAction('healthActionInternet'));
      case HealthDial.lanExposure:
        final risky = lanHosts.where(
          (h) => _trust.classify(h).level == HostTrustLevel.risky,
        );
        if (risky.isNotEmpty) {
          final first = risky.first;
          actions.add(
            HealthAction(
              'healthActionLanRisky',
              deviceIp: first.ip,
              deviceVendor: first.vendor,
            ),
          );
        } else {
          actions.add(const HealthAction('healthActionLanCaution'));
        }
    }

    actions.add(const HealthAction('healthActionShare'));
    return actions;
  }
}
