import 'package:injectable/injectable.dart';

import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import '../entities/evil_twin_assessment.dart';
import '../entities/network_context_type.dart';
import '../entities/network_fingerprint.dart';
import '../entities/security_assessment.dart';
import '../entities/security_drift_finding.dart';
import '../entities/security_finding.dart';
import '../entities/trusted_network_profile.dart';
import '../entities/vulnerability.dart';
import '../entities/vulnerable_router.dart';
import '../services/evil_twin_classifier.dart';

@lazySingleton
class SecurityAnalyzer {
  final EvilTwinClassifier _evilTwinClassifier;

  SecurityAnalyzer(this._evilTwinClassifier);
  SecurityAssessment assess(
    WifiNetwork network, {
    List<WifiNetwork> localBaseline = const [],
    TrustedNetworkProfile? trustedProfile,
    List<VulnerableRouter> hardwareVulnerabilities = const [],
    bool isDeepScan = false,
    NetworkContextType context = NetworkContextType.unknown,
    Set<String> trustedBssids = const {},
  }) {
    int adjust(int base, String ruleId) =>
        _contextAdjustedDeduction(base, ruleId, context);
    final findings = <SecurityFinding>[];
    final riskFactors = <String>[];
    var score = 100;
    final now = DateTime.now();

    if (isDeepScan) {
      findings.add(
        SecurityFinding(
          ruleId: 'scan.deep_scan_active',
          category: SecurityFindingCategory.lanExposure,
          title: 'Active Probing Active',
          description:
              'Deep scan is enabled, performing more intrusive network tests.',
          severity: VulnerabilitySeverity.info,
          recommendation:
              'Use only on networks you own or have permission to scan.',
          confidence: SecurityFindingConfidence.observed,
          evidence: 'User-initiated deep scan (active probing) is enabled.',
          timestamp: now,
          subject: network.bssid,
        ),
      );
    }

    switch (network.security) {
      case SecurityType.open:
        findings.add(
          SecurityFinding(
            ruleId: 'wifi.open_network',
            category: SecurityFindingCategory.wifiConfiguration,
            title: 'Open Network',
            description:
                'No encryption detected. All traffic can be sniffed in plaintext.',
            severity: VulnerabilitySeverity.critical,
            recommendation:
                'Avoid sensitive activity. Prefer trusted VPN or different network.',
            confidence: SecurityFindingConfidence.observed,
            evidence:
                'The access point advertises no encryption for ${network.ssid.isEmpty ? network.bssid : network.ssid}.',
            timestamp: now,
            subject: network.bssid,
          ),
        );
        riskFactors.add('No encryption in use');
        score -= adjust(80, 'wifi.open_network');
        break;
      case SecurityType.wep:
        findings.add(
          SecurityFinding(
            ruleId: 'wifi.wep',
            category: SecurityFindingCategory.wifiConfiguration,
            title: 'WEP Encryption',
            description: 'WEP is deprecated and can be cracked quickly.',
            severity: VulnerabilitySeverity.critical,
            recommendation: 'Reconfigure AP to WPA2 or WPA3 immediately.',
            confidence: SecurityFindingConfidence.observed,
            evidence:
                'The beacon capabilities for ${network.bssid} advertise WEP.',
            timestamp: now,
            subject: network.bssid,
          ),
        );
        riskFactors.add('Deprecated encryption (WEP)');
        score -= adjust(70, 'wifi.wep');
        break;
      case SecurityType.wpa:
        findings.add(
          SecurityFinding(
            ruleId: 'wifi.legacy_wpa',
            category: SecurityFindingCategory.wifiConfiguration,
            title: 'Legacy WPA',
            description:
                'WPA/TKIP is older and weaker against modern attack techniques.',
            severity: VulnerabilitySeverity.high,
            recommendation: 'Upgrade AP and clients to WPA2/WPA3.',
            confidence: SecurityFindingConfidence.observed,
            evidence:
                'The access point reports a legacy WPA profile instead of WPA2/WPA3.',
            timestamp: now,
            subject: network.bssid,
          ),
        );
        riskFactors.add('Legacy WPA in use');
        score -= adjust(40, 'wifi.legacy_wpa');
        break;
      case SecurityType.wpa2:
      case SecurityType.wpa3:
      case SecurityType.unknown:
        break;
    }

    if (network.isHidden) {
      findings.add(
        SecurityFinding(
          ruleId: 'wifi.hidden_ssid',
          category: SecurityFindingCategory.wifiConfiguration,
          title: 'Hidden SSID',
          description:
              'Hidden SSIDs are still discoverable and may hurt compatibility.',
          severity: VulnerabilitySeverity.low,
          recommendation:
              'Hidden SSID alone is not protection. Focus on strong encryption.',
          confidence: SecurityFindingConfidence.observed,
          evidence:
              'The network is being advertised without a visible SSID value.',
          timestamp: now,
          subject: network.bssid,
        ),
      );
      riskFactors.add('Hidden SSID behavior');
      score -= adjust(5, 'wifi.hidden_ssid');
    }

    if (network.signalStrength < -85) {
      findings.add(
        SecurityFinding(
          ruleId: 'wifi.very_weak_signal',
          category: SecurityFindingCategory.wifiConfiguration,
          title: 'Very Weak Signal',
          description:
              'Weak signal can indicate unstable links and spoofing susceptibility.',
          severity: VulnerabilitySeverity.info,
          recommendation: 'Move closer to AP or validate BSSID consistency.',
          confidence: SecurityFindingConfidence.heuristic,
          evidence:
              'Observed RSSI is ${network.signalStrength} dBm, which is well below the recommended range.',
          timestamp: now,
          subject: network.bssid,
        ),
      );
      riskFactors.add('Weak signal environment');
      score -= adjust(5, 'wifi.very_weak_signal');
    }

    if (network.hasWps == true) {
      findings.add(
        SecurityFinding(
          ruleId: 'wifi.wps_enabled',
          category: SecurityFindingCategory.wifiConfiguration,
          title: 'WPS Enabled',
          description:
              'Wi-Fi Protected Setup (WPS) is enabled. The WPS PIN mode '
              'can be brute-forced in hours using publicly available tools '
              '(Pixie Dust attack), effectively bypassing any password.',
          severity: VulnerabilitySeverity.high,
          recommendation:
              'Disable WPS in your router admin panel. Use WPA2/WPA3 passphrase '
              'only.',
          confidence: SecurityFindingConfidence.observed,
          evidence:
              'The capabilities string for ${network.bssid} advertises WPS support.',
          timestamp: now,
          subject: network.bssid,
        ),
      );
      riskFactors.add('WPS PIN attack surface exposed');
      score -= adjust(30, 'wifi.wps_enabled');
    }

    final isWpa2OrBetter =
        network.security == SecurityType.wpa2 ||
        network.security == SecurityType.wpa3;
    if (isWpa2OrBetter && network.hasPmf == false) {
      findings.add(
        SecurityFinding(
          ruleId: 'wifi.pmf_not_enforced',
          category: SecurityFindingCategory.wifiConfiguration,
          title: 'Management Frames Unprotected',
          description:
              'This access point does not enforce Protected Management Frames '
              '(PMF / 802.11w). Unprotected management frames allow an attacker '
              'to forge deauthentication packets and disconnect clients.',
          severity: VulnerabilitySeverity.medium,
          recommendation:
              'Enable PMF in your router settings (often labelled "802.11w" '
              'or "Management Frame Protection"). WPA3 requires PMF by default.',
          confidence: SecurityFindingConfidence.observed,
          evidence:
              'The scan metadata did not report PMF support for a WPA2/WPA3 access point.',
          timestamp: now,
          subject: network.bssid,
        ),
      );
      riskFactors.add('PMF not enforced — deauth spoofing possible');
      score -= adjust(10, 'wifi.pmf_not_enforced');
    }

    final evilTwin = _evilTwinClassifier.assessAll(
      network,
      localBaseline,
      trustedBssids: trustedBssids,
    );
    if (evilTwin.isCandidate) {
      final severity =
          evilTwin.confidence >= 0.75
              ? VulnerabilitySeverity.critical
              : VulnerabilitySeverity.high;
      findings.add(
        SecurityFinding(
          ruleId: 'wifi.suspicious_sibling_ap',
          category: SecurityFindingCategory.trustedBaseline,
          title: 'Potential Evil Twin',
          description:
              'A nearby access point shares this SSID but its fingerprint '
              'doesn\'t match — that\'s the pattern an attacker uses to '
              'impersonate a real Wi-Fi.',
          severity: severity,
          recommendation:
              'Don\'t enter passwords on this network until you\'ve '
              'verified the BSSID printed on the back of your real router.',
          confidence: SecurityFindingConfidence.heuristic,
          evidence: _formatEvilTwinEvidence(evilTwin),
          timestamp: now,
          subject: network.ssid,
        ),
      );
      riskFactors.add(
        'Evil twin candidate (${(evilTwin.confidence * 100).round()}% '
        'confidence) sharing this SSID',
      );
      // Scale the score deduction with confidence: a low-confidence finding
      // costs ~15 points, a high-confidence one ~50.
      final deduction = (15 + (evilTwin.confidence - 0.5) * 70).round().clamp(
        15,
        50,
      );
      score -= adjust(deduction, 'wifi.suspicious_sibling_ap');
    }

    if (_isSuspiciousSsid(network.ssid)) {
      findings.add(
        SecurityFinding(
          ruleId: 'wifi.suspicious_ssid',
          category: SecurityFindingCategory.wifiConfiguration,
          title: 'Suspicious Network Name',
          description:
              'This SSID matches common honeypot/lure patterns used by '
              'attackers to trick users into connecting (e.g. "Free WiFi", '
              '"Airport WiFi"). Legitimate networks rarely use these names.',
          severity: VulnerabilitySeverity.medium,
          recommendation:
              'Verify this network with the venue operator before connecting. '
              'Use a VPN if you must connect to unknown networks.',
          confidence: SecurityFindingConfidence.heuristic,
          evidence:
              'The SSID "${network.ssid}" matches a common lure pattern seen in public hotspot impersonation.',
          timestamp: now,
          subject: network.ssid,
        ),
      );
      riskFactors.add('SSID matches known honeypot pattern');
      score -= adjust(15, 'wifi.suspicious_ssid');
    }

    final sameChannelCount =
        localBaseline
            .where(
              (n) => n.channel == network.channel && n.bssid != network.bssid,
            )
            .length;
    if (sameChannelCount >= 5) {
      findings.add(
        SecurityFinding(
          ruleId: 'wifi.high_channel_congestion',
          category: SecurityFindingCategory.wifiConfiguration,
          title: 'High Channel Congestion',
          description:
              '${sameChannelCount + 1} networks are broadcasting on channel '
              '${network.channel}. Heavy congestion degrades performance and '
              'increases packet retransmissions, making the connection less '
              'reliable and potentially easier to intercept.',
          severity: VulnerabilitySeverity.info,
          recommendation:
              'Ask the network admin to switch to a less congested channel. '
              'Use the Channel Rating screen to find optimal channels.',
          confidence: SecurityFindingConfidence.observed,
          evidence:
              '${sameChannelCount + 1} nearby networks were seen on channel ${network.channel}.',
          timestamp: now,
          subject: network.bssid,
        ),
      );
      riskFactors.add('Channel ${network.channel} is heavily congested');
      score -= adjust(5, 'wifi.high_channel_congestion');
    }

    if (network.frequency < 3000 && localBaseline.isNotEmpty) {
      final has5GhzSibling = localBaseline.any(
        (n) =>
            n.ssid == network.ssid &&
            n.bssid != network.bssid &&
            n.frequency >= 5000,
      );
      if (!has5GhzSibling && network.security != SecurityType.open) {
        findings.add(
          SecurityFinding(
            ruleId: 'wifi.only_24ghz',
            category: SecurityFindingCategory.wifiConfiguration,
            title: '2.4 GHz Only',
            description:
                'This network only broadcasts on the 2.4 GHz band, which is '
                'more crowded and susceptible to interference. 5 GHz offers '
                'better speed and less interference.',
            severity: VulnerabilitySeverity.info,
            recommendation:
                'Enable 5 GHz band on your router for better performance. '
                'Most modern devices support dual-band operation.',
            confidence: SecurityFindingConfidence.heuristic,
            evidence:
                'No 5 GHz sibling access point was detected for this SSID in the current scan.',
            timestamp: now,
            subject: network.ssid,
          ),
        );
        riskFactors.add('No 5 GHz band detected');
        score -= adjust(3, 'wifi.only_24ghz');
      }
    }

    if (trustedProfile != null) {
      final currentFingerprint = NetworkFingerprint.fromWifiNetwork(network);
      final drift = currentFingerprint.driftAgainst(trustedProfile.fingerprint);
      if (drift.isNotEmpty) {
        final severeAttributes = {'BSSID', 'Security', 'WPS', 'PMF', 'Vendor'};
        final severity =
            drift.any(severeAttributes.contains)
                ? VulnerabilitySeverity.high
                : VulnerabilitySeverity.medium;
        findings.add(
          SecurityDriftFinding(
            ruleId: 'trusted.baseline_drift',
            severity: severity,
            confidence: SecurityFindingConfidence.observed,
            title: 'Trusted Baseline Drift',
            description:
                'This access point no longer matches the fingerprint you previously trusted.',
            evidence:
                'Changed attributes: ${drift.join(', ')}. Baseline BSSID ${trustedProfile.bssid}, observed ${network.bssid}.',
            recommendation:
                'Re-validate the router configuration and only re-trust the network if the change was intentional.',
            timestamp: now,
            baselineBssid: trustedProfile.bssid,
            observedBssid: network.bssid,
            changedAttributes: drift,
            subject: network.ssid,
          ),
        );
        riskFactors.add('Trusted fingerprint drift: ${drift.join(', ')}');
        score -= adjust(
          severity == VulnerabilitySeverity.high ? 25 : 12,
          'trusted.baseline_drift',
        );
      }
    }

    for (final vulnerable in hardwareVulnerabilities) {
      final severity = _mapStringSeverity(vulnerable.severity);
      findings.add(
        SecurityFinding(
          ruleId: 'hardware.vulnerability',
          category: SecurityFindingCategory.hardwareVulnerability,
          title: 'Vulnerable Hardware: ${vulnerable.model}',
          description: vulnerable.vulnerability,
          severity: severity,
          recommendation: vulnerable.recommendation,
          confidence: SecurityFindingConfidence.strong,
          evidence:
              'BSSID prefix ${vulnerable.prefix} matches a known vulnerable hardware profile.',
          timestamp: now,
          subject: network.bssid,
        ),
      );
      riskFactors.add('Known vulnerability in ${vulnerable.model}');
      score -= adjust(
        _scoreDeductionForSeverity(severity),
        'hardware.vulnerability',
      );
    }

    score = score.clamp(0, 100);
    final status = _statusFromScore(score);

    return SecurityAssessment(
      score: score,
      status: status,
      evidenceFindings: findings,
      riskFactors: riskFactors,
    );
  }

  /// Adjusts a base score deduction based on the network context.
  ///
  /// `home` networks are held to a stricter standard (router-side issues
  /// like WPS, missing PMF and trusted-baseline drift weigh more heavily).
  /// `public` networks accept that the user does not control the router,
  /// so router-config issues weigh less, but lure SSIDs and unencrypted
  /// links weigh slightly more — the dominant risk there is impersonation.
  /// `guest` accepts natural drift on a known network. `unknown` keeps the
  /// neutral baseline so existing behaviour does not regress.
  int _contextAdjustedDeduction(
    int base,
    String ruleId,
    NetworkContextType context,
  ) {
    final multiplier = switch (context) {
      NetworkContextType.home => switch (ruleId) {
        'wifi.wps_enabled' => 1.5,
        'wifi.pmf_not_enforced' => 1.5,
        'trusted.baseline_drift' => 1.5,
        _ => 1.0,
      },
      NetworkContextType.public => switch (ruleId) {
        'wifi.suspicious_ssid' => 1.5,
        'wifi.suspicious_sibling_ap' => 1.3,
        'wifi.wps_enabled' => 0.5,
        'wifi.pmf_not_enforced' => 0.5,
        'trusted.baseline_drift' => 0.5,
        _ => 1.0,
      },
      NetworkContextType.guest => switch (ruleId) {
        'trusted.baseline_drift' => 0.4,
        _ => 1.0,
      },
      NetworkContextType.unknown => 1.0,
    };
    if (multiplier == 1.0) return base;
    return (base * multiplier).round();
  }

  int _scoreDeductionForSeverity(VulnerabilitySeverity severity) {
    return switch (severity) {
      VulnerabilitySeverity.critical => 50,
      VulnerabilitySeverity.high => 30,
      VulnerabilitySeverity.medium => 15,
      VulnerabilitySeverity.low => 5,
      VulnerabilitySeverity.info => 1,
    };
  }

  VulnerabilitySeverity _mapStringSeverity(String severity) {
    return switch (severity.toLowerCase()) {
      'critical' => VulnerabilitySeverity.critical,
      'high' => VulnerabilitySeverity.high,
      'medium' => VulnerabilitySeverity.medium,
      'low' => VulnerabilitySeverity.low,
      _ => VulnerabilitySeverity.info,
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

  static const _honeypotPatterns = [
    'free wifi', 'free internet', 'free wi-fi',
    'airport wifi', 'airport free',
    'hotel wifi', 'hotel free',
    'starbucks free', 'mcdonalds free',
    'open wifi', 'open network',
    'public wifi', 'public free',
    'guest free', 'free hotspot',
    'wifi free', 'internet free',
    'xfinity wifi', // commonly spoofed
  ];

  bool _isSuspiciousSsid(String ssid) {
    if (ssid.isEmpty) return false;
    final lower = ssid.toLowerCase().trim();
    return _honeypotPatterns.any(
      (pattern) => lower == pattern || lower.contains(pattern),
    );
  }

  String _formatEvilTwinEvidence(EvilTwinAssessment a) {
    final parts = <String>[
      'Confidence ${(a.confidence * 100).round()}% '
          '(threshold ${(EvilTwinClassifier.candidateThreshold * 100).round()}%)',
      'Peer BSSID: ${a.peerBssid}',
    ];
    if (a.suspicions.isNotEmpty) {
      parts.add(
        'Suspicion signals: ${a.suspicions.map((s) => s.name).join(', ')}',
      );
    }
    if (a.mitigations.isNotEmpty) {
      parts.add(
        'Mitigations applied: ${a.mitigations.map((s) => s.name).join(', ')}',
      );
    }
    return parts.join(' · ');
  }
}
