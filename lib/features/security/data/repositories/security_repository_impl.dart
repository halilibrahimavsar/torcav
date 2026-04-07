import 'package:injectable/injectable.dart';
import '../../../../core/services/notification_service.dart';
import '../datasources/security_local_data_source.dart';
import '../../domain/entities/assessment_session.dart';
import '../../domain/entities/known_network.dart';
import '../../domain/entities/network_fingerprint.dart';
import '../../domain/entities/security_event.dart';
import '../../domain/entities/security_assessment.dart';
import '../../domain/entities/security_finding.dart';
import '../../domain/entities/trusted_network_profile.dart';
import '../../domain/entities/vulnerability.dart';
import '../../domain/repositories/security_repository.dart';
import '../../domain/usecases/deauth_detector.dart';
import '../../domain/usecases/security_analyzer.dart';
import '../datasources/dns_test_data_source.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

@LazySingleton(as: SecurityRepository)
class SecurityRepositoryImpl implements SecurityRepository {
  final SecurityLocalDataSource _localDataSource;
  final NotificationService _notificationService;
  final DeauthDetector _deauthDetector;
  final SecurityAnalyzer _securityAnalyzer;
  final DnsDataSource _dnsDataSource;

  SecurityRepositoryImpl(
    this._localDataSource,
    this._notificationService,
    this._deauthDetector,
    this._securityAnalyzer,
    this._dnsDataSource,
  );

  @override
  Future<List<KnownNetwork>> getKnownNetworks() =>
      _localDataSource.getKnownNetworks();

  @override
  Future<void> saveKnownNetwork(KnownNetwork network) async {
    await _localDataSource.saveKnownNetwork(network);
  }

  @override
  Future<void> trustNetwork(WifiNetwork network) async {
    await _localDataSource.saveTrustedNetworkProfile(
      TrustedNetworkProfile(
        ssid: network.ssid,
        bssid: network.bssid,
        fingerprint: NetworkFingerprint.fromWifiNetwork(network),
        trustedAt: DateTime.now(),
        lastConfirmedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> deleteKnownNetwork(String bssid) async {
    await _localDataSource.deleteKnownNetwork(bssid);
  }

  @override
  Future<List<TrustedNetworkProfile>> getTrustedNetworkProfiles() =>
      _localDataSource.getTrustedNetworkProfiles();

  @override
  Future<void> saveTrustedNetworkProfile(TrustedNetworkProfile profile) =>
      _localDataSource.saveTrustedNetworkProfile(profile);

  @override
  Future<void> deleteTrustedNetworkProfile(String bssid) =>
      _localDataSource.deleteTrustedNetworkProfile(bssid);

  @override
  Future<List<SecurityEvent>> getSecurityEvents() =>
      _localDataSource.getSecurityEvents();

  @override
  Future<void> saveSecurityEvent(SecurityEvent event) =>
      _localDataSource.saveSecurityEvent(event);

  @override
  Future<void> saveSecurityEvents(List<SecurityEvent> events) =>
      _localDataSource.saveSecurityEvents(events);

  @override
  Future<void> markSecurityEventAsRead(int id) =>
      _localDataSource.markSecurityEventAsRead(id);

  @override
  Future<void> markAllSecurityEventsAsRead() =>
      _localDataSource.markAllSecurityEventsAsRead();

  @override
  Future<void> clearAllSecurityEvents() =>
      _localDataSource.clearAllSecurityEvents();

  @override
  Future<AssessmentSession?> getLatestAssessmentSession() =>
      _localDataSource.getLatestAssessmentSession();

  @override
  Future<void> saveAssessmentSession(AssessmentSession session) =>
      _localDataSource.saveAssessmentSession(session);

  @override
  Future<List<SecurityEvent>> analyzeNetworks(List<WifiNetwork> networks) async {
    final trustedProfiles = await getTrustedNetworkProfiles();
    final knownNetworks = await getKnownNetworks();
    final dnsResult = await _dnsDataSource.performTest();
    final alerts = <SecurityEvent>[];
    final allFindings = <SecurityFinding>[];
    var worstScore = 100;
    final now = DateTime.now();

    for (final network in networks) {
      if (network.ssid.isEmpty) continue;

      final exactTrusted = trustedProfiles
          .where((profile) => profile.bssid == network.bssid)
          .firstOrNull;
      final trustedBySsid = trustedProfiles
          .where((profile) => profile.ssid == network.ssid)
          .toList();

      final assessment = _securityAnalyzer.assess(
        network,
        localBaseline: networks,
        trustedProfile: exactTrusted ?? trustedBySsid.firstOrNull,
      );

      allFindings.addAll(assessment.evidenceFindings);
      if (assessment.score < worstScore) {
        worstScore = assessment.score;
      }

      // Map critical findings to SecurityEvents (Notifications)
      for (final finding in assessment.evidenceFindings) {
        final eventType = _mapRuleIdToEventType(finding.ruleId);
        if (eventType != null && (finding.severity == VulnerabilitySeverity.high || finding.severity == VulnerabilitySeverity.critical)) {
          final event = SecurityEvent(
            type: eventType,
            severity: _mapSeverity(finding.severity),
            ssid: network.ssid,
            bssid: network.bssid,
            timestamp: now,
            evidence: finding.evidence,
          );
          
          // Avoid duplicate alerts in same session
          if (!alerts.any((a) => a.type == eventType && a.bssid == network.bssid)) {
            alerts.add(event);
            await _notificationService.showSecurityAlert(event);
          }
        }
      }

      // Update trust confirmation if no drift detected
      if (exactTrusted != null) {
        final drift = NetworkFingerprint.fromWifiNetwork(network).driftAgainst(
          exactTrusted.fingerprint,
        );
        if (drift.isEmpty) {
          await saveTrustedNetworkProfile(
            exactTrusted.copyWith(lastConfirmedAt: now),
          );
        }
      } else {
        // Auto-trust Logic: Track network stability
        await _handleAutoTrust(network, knownNetworks);
      }
    }

    if (alerts.isNotEmpty) {
      await saveSecurityEvents(alerts);
    }

    // Deauth burst detection (heuristic)
    final deauthEvent = _deauthDetector.evaluate(networks);
    if (deauthEvent != null) {
      alerts.add(deauthEvent);
      await saveSecurityEvent(deauthEvent);
      await _notificationService.showSecurityAlert(deauthEvent);
    }

    final dedupedFindings = <String, SecurityFinding>{};
    for (final finding in allFindings) {
      final key = '${finding.ruleId}:${finding.subject}:${finding.evidence}';
      dedupedFindings[key] = finding;
    }

    await saveAssessmentSession(
      AssessmentSession(
        sessionKey: 'assessment_${now.microsecondsSinceEpoch}',
        createdAt: now,
        overallScore: worstScore,
        overallStatus: _statusFromScore(worstScore),
        wifiFindings: dedupedFindings.values.toList(),
        lanFindings: const [],
        dnsResult: dnsResult,
        trustedProfileCount: trustedProfiles.length,
      ),
    );

    return alerts;
  }

  Future<void> _handleAutoTrust(WifiNetwork network, List<KnownNetwork> knowns) async {
    final known = knowns.where((k) => k.bssid == network.bssid).firstOrNull;
    if (known == null) {
      await saveKnownNetwork(KnownNetwork(
        ssid: network.ssid,
        bssid: network.bssid,
        security: network.security.name,
        firstSeen: DateTime.now(),
        lastSeen: DateTime.now(),
        seenCount: 1,
      ));
    } else {
      await incrementSeenCount(network.bssid);
      // Promote to trusted if seen 3 times and security is not OPEN
      if (known.seenCount >= 2 && network.security != SecurityType.open) {
        await trustNetwork(network);
      }
    }
  }

  @override
  Future<void> incrementSeenCount(String bssid) => 
      _localDataSource.incrementSeenCount(bssid);

  SecurityEventType? _mapRuleIdToEventType(String ruleId) {
    return switch (ruleId) {
      'wifi.suspicious_sibling_ap' => SecurityEventType.evilTwinDetected,
      'trusted.baseline_drift' => SecurityEventType.evilTwinDetected,
      'wifi.legacy_wpa' || 'wifi.wep' => SecurityEventType.encryptionDowngraded,
      'wifi.open_network' => SecurityEventType.encryptionDowngraded,
      _ => null,
    };
  }

  SecurityEventSeverity _mapSeverity(VulnerabilitySeverity severity) {
    return switch (severity) {
      VulnerabilitySeverity.critical => SecurityEventSeverity.critical,
      VulnerabilitySeverity.high => SecurityEventSeverity.high,
      VulnerabilitySeverity.medium => SecurityEventSeverity.medium,
      VulnerabilitySeverity.low => SecurityEventSeverity.low,
      VulnerabilitySeverity.info => SecurityEventSeverity.info,
    };
  }

  SecurityStatus _statusFromScore(int score) {
    if (score < 40) {
      return SecurityStatus.critical;
    }
    if (score < 70) {
      return SecurityStatus.atRisk;
    }
    if (score < 90) {
      return SecurityStatus.moderate;
    }
    return SecurityStatus.secure;
  }
}
