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
      
      tasks.add(
        GamificationTask(
          // Map the rule to a stable, localizable task key (see GamificationTaskX).
          titleKey: _taskKeyForRule(finding.ruleId),
          pointValue: points,
          deepLinkRoute: 'router-hardening',
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

  /// Maps a [SecurityFinding.ruleId] to a stable, localizable task key that
  /// [GamificationTaskX] can resolve into a title and description.
  String _taskKeyForRule(String ruleId) {
    switch (ruleId) {
      case 'wifi.wps_enabled':
        return 'disable_wps';
      case 'wifi.wep':
      case 'wifi.legacy_wpa':
      case 'wifi.open_network':
      case 'wifi.pmf_not_enforced':
        return 'enable_wpa3';
      case 'wifi.high_channel_congestion':
      case 'wifi.only_24ghz':
        return 'optimize_channel';
      default:
        return 'harden_router';
    }
  }
}
