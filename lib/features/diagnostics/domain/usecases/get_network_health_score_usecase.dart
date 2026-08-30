import 'package:injectable/injectable.dart';

import '../../../security/domain/entities/security_assessment.dart';
import '../../../security/domain/entities/vulnerability.dart';
import '../entities/diagnosis_result.dart';
import '../entities/network_health_score.dart';

@lazySingleton
class GetNetworkHealthScoreUseCase {
  NetworkHealthScore call({
    required SecurityAssessment securityAssessment,
    required DiagnosisResult diagnosisResult,
  }) {
    final int securityScore = securityAssessment.score;

    double performancePenalty = 0;
    for (final evidence in diagnosisResult.allEvidence) {
      // severity is 0.0 to 1.0. 
      // We subtract up to 40 points based on severity per issue, so that 
      // multiple small issues or one big issue degrade the performance score.
      performancePenalty += (evidence.severity * 40);
    }
    
    int performanceScore = (100 - performancePenalty).round().clamp(0, 100);

    // Total score is weighted: 50% security, 50% performance.
    int totalScore = ((securityScore * 0.5) + (performanceScore * 0.5)).round();

    final tasks = <GamificationTask>[];

    // Security tasks
    for (final finding in securityAssessment.evidenceFindings) {
      // Calculate point value based on severity
      int points = 10;
      switch (finding.severity) {
        case VulnerabilitySeverity.critical:
          points = 25;
          break;
        case VulnerabilitySeverity.high:
          points = 15;
          break;
        case VulnerabilitySeverity.medium:
          points = 10;
          break;
        case VulnerabilitySeverity.low:
        case VulnerabilitySeverity.info:
          points = 5;
          break;
      }
      
      // A rule with no honest next step produces no task. Previously every
      // unmapped rule fell back to "harden your router" pointing at the
      // hardening wizard, so an ARP-spoofing or DNS-hijacking victim was
      // sent to a wizard that does nothing about their problem.
      final action = _taskForRule(finding.ruleId);
      if (action == null) continue;

      tasks.add(
        GamificationTask(
          titleKey: action.titleKey,
          pointValue: points,
          deepLinkRoute: action.route,
        ),
      );
    }

    // Diagnostics tasks
    for (final evidence in diagnosisResult.allEvidence) {
      int points = (evidence.severity * 20).round().clamp(5, 20);
      
      for (final action in evidence.actions) {
        tasks.add(
          GamificationTask(
            titleKey: action.labelKey,
            pointValue: points,
            deepLinkRoute: action.deepLinkRoute,
          ),
        );
      }
    }

    // Sort tasks by point value descending to show the highest impact tasks first.
    tasks.sort((a, b) => b.pointValue.compareTo(a.pointValue));

    return NetworkHealthScore(
      totalScore: totalScore,
      securityScore: securityScore,
      performanceScore: performanceScore,
      recommendedTasks: tasks.take(5).toList(), // Limit to top 5 tasks
    );
  }

  /// The dashboard action a security rule earns, or `null` when the rule has
  /// no step the user can take.
  ///
  /// `titleKey` is resolved by `TaskLabelHelper`; `route` must be a
  /// destination `AppShellPage._navigateTo` actually handles, or the tap is a
  /// silent no-op.
  ///
  /// Returning `null` is the point of this method. A finding the user cannot
  /// act on (an informational one, or a threat whose only answer is "leave
  /// this network", which no screen automates) should show no task rather
  /// than a plausible-looking wrong one.
  ({String titleKey, String? route})? _taskForRule(String ruleId) {
    return switch (ruleId) {
      // ── Router configuration: the hardening wizard genuinely covers these ──
      'wifi.wps_enabled' => (
        titleKey: 'disable_wps',
        route: 'router-hardening',
      ),
      'wifi.wep' ||
      'wifi.legacy_wpa' ||
      'wifi.open_network' ||
      'wifi.pmf_not_enforced' => (
        titleKey: 'enable_wpa3',
        route: 'router-hardening',
      ),
      'lan.gateway_ports_open' => (
        titleKey: 'harden_router',
        route: 'router-hardening',
      ),
      'hardware.vulnerability' => (
        titleKey: 'speedDoctorActionUpdateFirmware',
        route: 'router-hardening',
      ),

      // ── Radio: the spectrum page shows the alternative channels ──
      'wifi.high_channel_congestion' || 'wifi.only_24ghz' => (
        titleKey: 'optimize_channel',
        route: 'monitor/channels',
      ),

      // ── Coverage: the heatmap is where "where do I move it" is answered ──
      'wifi.very_weak_signal' => (
        titleKey: 'speedDoctorActionMoveCloser',
        route: 'heatmap',
      ),

      // ── DNS: the stabilizer is the screen that changes the resolver ──
      'dns_hijacking' => (
        titleKey: 'speedDoctorActionChangeDns',
        route: 'ping_stabilizer',
      ),

      // ── LAN exposure: the answer is to look at what is on the network ──
      'lan.port_open' || 'lan.device_discovered' || 'lan_discovery' => (
        titleKey: 'review_lan_devices',
        route: 'lan',
      ),

      // ── Trust drift: review the profile that changed ──
      'trusted.baseline_drift' => (
        titleKey: 'review_trusted_network',
        route: 'security',
      ),

      // ── Active interception: no setting fixes this; get off the network ──
      'arp_spoofing' ||
      'wifi.suspicious_ssid' ||
      'wifi.suspicious_sibling_ap' => (
        titleKey: 'leave_network',
        route: 'security',
      ),

      // ── No task. Not oversights: ──
      // wifi.hidden_ssid       — hiding an SSID is not a security control,
      //                          so there is nothing to recommend.
      // scan.deep_scan_active  — reports a mode the user turned on.
      // dns.check_unavailable  — reports that a probe could not run.
      _ => null,
    };
  }
}
