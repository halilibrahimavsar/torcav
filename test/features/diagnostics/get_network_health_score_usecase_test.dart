import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/diagnostics/domain/entities/diagnosis_evidence.dart';
import 'package:torcav/features/diagnostics/domain/entities/diagnosis_inputs.dart';
import 'package:torcav/features/diagnostics/domain/entities/diagnosis_result.dart';
import 'package:torcav/features/diagnostics/domain/entities/diagnostic_action.dart';
import 'package:torcav/features/diagnostics/domain/entities/root_cause_category.dart';
import 'package:torcav/features/diagnostics/domain/usecases/get_network_health_score_usecase.dart';
import 'package:torcav/core/network/network_context_type.dart';
import 'package:torcav/features/security/domain/entities/security_assessment.dart';
import 'package:torcav/features/security/domain/entities/security_finding.dart';
import 'package:torcav/features/security/domain/entities/vulnerability.dart';

void main() {
  late GetNetworkHealthScoreUseCase useCase;

  setUp(() {
    useCase = GetNetworkHealthScoreUseCase();
  });

  group('GetNetworkHealthScoreUseCase', () {
    test('returns 100/100 when network is perfectly secure and fast', () {
      const securityAssessment = SecurityAssessment(
        score: 100,
        status: SecurityStatus.secure,
        evidenceFindings: [],
        riskFactors: [],
      );

      final diagnosisResult = DiagnosisResult(
        timestamp: DateTime.now(),
        primaryCause: RootCauseCategory.healthy,
        allEvidence: const [],
        inputs: const DiagnosisInputs(
          connectedNetwork: null,
          visibleNetworks: [],
          speedTest: null,
          gatewayPingMs: null,
          dnsBenchmark: null,
          context: NetworkContextType.unknown,
        ),
      );

      final result = useCase(
        securityAssessment: securityAssessment,
        diagnosisResult: diagnosisResult,
      );

      expect(result.securityScore, 100);
      expect(result.performanceScore, 100);
      expect(result.totalScore, 100);
      expect(result.recommendedTasks, isEmpty);
    });

    test('deducts points and generates tasks based on security and performance issues', () {
      final now = DateTime.now();
      
      final securityAssessment = SecurityAssessment(
        score: 60,
        status: SecurityStatus.atRisk,
        evidenceFindings: [
          SecurityFinding(
            ruleId: 'wifi.wps_enabled',
            category: SecurityFindingCategory.wifiConfiguration,
            title: 'WPS Enabled',
            description: 'WPS is enabled',
            severity: VulnerabilitySeverity.high,
            recommendation: 'Disable WPS',
            confidence: SecurityFindingConfidence.observed,
            evidence: 'WPS is enabled',
            timestamp: now,
            subject: 'router',
          ),
        ],
        riskFactors: const ['WPS enabled'],
      );

      final diagnosisResult = DiagnosisResult(
        timestamp: now,
        primaryCause: RootCauseCategory.weakSignal,
        allEvidence: const [
          DiagnosisEvidence(
            category: RootCauseCategory.weakSignal,
            severity: 0.5,
            metricKey: 'rssi',
            metricParams: {},
            thresholdKey: 'rssi_threshold',
            thresholdParams: {},
            actions: [
              DiagnosticAction(labelKey: 'move_closer'),
            ],
          ),
        ],
        inputs: const DiagnosisInputs(
          connectedNetwork: null,
          visibleNetworks: [],
          speedTest: null,
          gatewayPingMs: null,
          dnsBenchmark: null,
          context: NetworkContextType.unknown,
        ),
      );

      final result = useCase(
        securityAssessment: securityAssessment,
        diagnosisResult: diagnosisResult,
      );

      expect(result.securityScore, 60);
      
      // Performance penalty is severity (0.5) * 40 = 20.
      // Performance score should be 100 - 20 = 80.
      expect(result.performanceScore, 80);
      
      // Total score = (60 * 0.5) + (80 * 0.5) = 30 + 40 = 70.
      expect(result.totalScore, 70);
      
      expect(result.recommendedTasks.length, 2);
      
      // The high severity security task gives 15 points.
      // The 'wifi.wps_enabled' rule maps to the stable 'disable_wps' task key.
      // The 0.5 severity performance task gives 10 points.
      expect(result.recommendedTasks[0].titleKey, 'disable_wps');
      expect(result.recommendedTasks[0].pointValue, 15);
      
      expect(result.recommendedTasks[1].titleKey, 'move_closer');
      expect(result.recommendedTasks[1].pointValue, 10);
    });
  });
}
