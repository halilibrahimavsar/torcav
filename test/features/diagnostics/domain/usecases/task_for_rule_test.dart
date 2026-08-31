import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/core/l10n/task_label_helper.dart';
import 'package:torcav/features/diagnostics/domain/entities/diagnosis_inputs.dart';
import 'package:torcav/features/diagnostics/domain/entities/diagnosis_result.dart';
import 'package:torcav/features/diagnostics/domain/entities/network_health_score.dart';
import 'package:torcav/features/diagnostics/domain/entities/root_cause_category.dart';
import 'package:torcav/features/diagnostics/domain/usecases/get_network_health_score_usecase.dart';
import 'package:torcav/core/network/network_context_type.dart';
import 'package:torcav/features/security/domain/entities/security_assessment.dart';
import 'package:torcav/features/security/domain/entities/security_finding.dart';
import 'package:torcav/features/security/domain/entities/vulnerability.dart';

/// Every ruleId `SecurityAnalyzer` and `SecurityRepositoryImpl` can emit.
/// Listed explicitly so a rule that ships without a task decision fails here
/// rather than silently inheriting a fallback.
const _allRuleIds = <String>[
  'arp_spoofing',
  'dns_hijacking',
  'dns.check_unavailable',
  'hardware.vulnerability',
  'lan.device_discovered',
  'lan.gateway_ports_open',
  'lan.port_open',
  'lan_discovery',
  'scan.deep_scan_active',
  'trusted.baseline_drift',
  'wifi.hidden_ssid',
  'wifi.high_channel_congestion',
  'wifi.legacy_wpa',
  'wifi.only_24ghz',
  'wifi.open_network',
  'wifi.pmf_not_enforced',
  'wifi.suspicious_sibling_ap',
  'wifi.suspicious_ssid',
  'wifi.very_weak_signal',
  'wifi.wep',
  'wifi.wps_enabled',
];

/// Rules that deliberately produce no task — informational findings with no
/// user action. See `_taskForRule`.
const _intentionallyTaskless = <String>{
  'dns.check_unavailable',
  'scan.deep_scan_active',
  'wifi.hidden_ssid',
};

/// Destinations `AppShellPage._navigateTo` handles. A route outside this set
/// makes the task's tap a silent no-op.
const _navigableRoutes = <String>{
  'dashboard',
  'wifi',
  'lan',
  'operations',
  'monitor/topology',
  'monitor/channels',
  'monitor/signal',
  'performance',
  'heatmap',
  'security',
  'reports',
  'settings',
  'profile',
  'ping_stabilizer',
  'router-hardening',
};

SecurityFinding _finding(String ruleId) => SecurityFinding(
  ruleId: ruleId,
  category: SecurityFindingCategory.wifiConfiguration,
  severity: VulnerabilitySeverity.medium,
  confidence: SecurityFindingConfidence.observed,
  title: 'title',
  description: 'description',
  evidence: 'evidence',
  recommendation: 'recommendation',
  timestamp: DateTime(2026, 8, 30),
);

DiagnosisResult _healthyDiagnosis() => DiagnosisResult(
  timestamp: DateTime(2026, 8, 30),
  primaryCause: RootCauseCategory.healthy,
  allEvidence: const [],
  inputs: const DiagnosisInputs(
    connectedNetwork: null,
    visibleNetworks: [],
    speedTest: null,
    gatewayPingMs: null,
    dnsBenchmark: null,
    context: NetworkContextType.home,
  ),
);

void main() {
  final usecase = GetNetworkHealthScoreUseCase();

  List<GamificationTask> tasksFor(String ruleId) {
    return usecase(
      securityAssessment: SecurityAssessment(
        score: 50,
        status: SecurityStatus.moderate,
        evidenceFindings: [_finding(ruleId)],
        riskFactors: const [],
      ),
      diagnosisResult: _healthyDiagnosis(),
    ).recommendedTasks;
  }

  test('informational rules produce no task at all', () {
    for (final ruleId in _intentionallyTaskless) {
      expect(
        tasksFor(ruleId),
        isEmpty,
        reason: '$ruleId has no user action, so it must produce no task',
      );
    }
  });

  test('actionable rules no longer collapse onto the generic router task', () {
    // Before this change 13 of the rules fell through to 'harden_router'
    // pointing at a wizard that could not address them — an ARP-spoofing
    // victim was told to harden their router.
    final collapsed = <String>[];
    for (final ruleId in _allRuleIds) {
      if (_intentionallyTaskless.contains(ruleId)) continue;

      final tasks = tasksFor(ruleId);
      expect(
        tasks,
        hasLength(1),
        reason: '$ruleId produced ${tasks.length} tasks',
      );

      // lan.gateway_ports_open is the one rule the hardening wizard really
      // does answer, so it is allowed to use the generic key.
      if (tasks.single.titleKey == 'harden_router' &&
          ruleId != 'lan.gateway_ports_open') {
        collapsed.add(ruleId);
      }
    }
    expect(
      collapsed,
      isEmpty,
      reason: 'these rules still fall back to the generic router task',
    );
  });

  test('every emitted route is one the app shell can navigate to', () {
    // 'router-hardening' used to be produced but had no case in
    // _navigateTo, so tapping any security task did nothing.
    for (final ruleId in _allRuleIds) {
      for (final task in tasksFor(ruleId)) {
        final route = task.deepLinkRoute;
        expect(
          route == null || _navigableRoutes.contains(route),
          isTrue,
          reason: '$ruleId → route "$route" is not navigable',
        );
      }
    }
  });

  testWidgets('every emitted task key resolves to a localized title', (
    tester,
  ) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context)!;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    for (final ruleId in _allRuleIds) {
      for (final task in tasksFor(ruleId)) {
        expect(
          TaskLabelHelper.title(l10n, task.titleKey),
          isNotNull,
          reason: '$ruleId → "${task.titleKey}" has no localized title',
        );
      }
    }
  });

  test('the task list is capped where it is computed, not where it is drawn', () {
    // Four findings, three tasks: the cap lives here so the card can render
    // whatever it is handed. Slicing in both places meant work was done and
    // thrown away.
    final assessment = SecurityAssessment(
      score: 20,
      status: SecurityStatus.atRisk,
      evidenceFindings: [
        _finding('wifi.wps_enabled'),
        _finding('wifi.wep'),
        _finding('lan.port_open'),
        _finding('arp_spoofing'),
      ],
      riskFactors: const [],
    );

    final tasks =
        usecase(
          securityAssessment: assessment,
          diagnosisResult: _healthyDiagnosis(),
        ).recommendedTasks;

    expect(tasks, hasLength(3));
  });
}
