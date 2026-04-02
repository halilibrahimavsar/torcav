import 'package:injectable/injectable.dart';

import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import '../entities/security_assessment.dart';
import '../entities/security_report.dart';
import '../entities/vulnerability.dart';

@lazySingleton
class SecurityAnalyzer {
  SecurityAssessment assess(
    WifiNetwork network, {
    List<WifiNetwork> localBaseline = const [],
  }) {
    final vulnerabilities = <Vulnerability>[];
    final riskFactors = <String>[];
    var score = 100;

    switch (network.security) {
      case SecurityType.open:
        vulnerabilities.add(
          const Vulnerability(
            title: 'Open Network',
            description:
                'No encryption detected. All traffic can be sniffed in plaintext.',
            severity: VulnerabilitySeverity.critical,
            recommendation:
                'Avoid sensitive activity. Prefer trusted VPN or different network.',
          ),
        );
        riskFactors.add('No encryption in use');
        score -= 80;
        break;
      case SecurityType.wep:
        vulnerabilities.add(
          const Vulnerability(
            title: 'WEP Encryption',
            description: 'WEP is deprecated and can be cracked quickly.',
            severity: VulnerabilitySeverity.critical,
            recommendation: 'Reconfigure AP to WPA2 or WPA3 immediately.',
          ),
        );
        riskFactors.add('Deprecated encryption (WEP)');
        score -= 70;
        break;
      case SecurityType.wpa:
        vulnerabilities.add(
          const Vulnerability(
            title: 'Legacy WPA',
            description:
                'WPA/TKIP is older and weaker against modern attack techniques.',
            severity: VulnerabilitySeverity.high,
            recommendation: 'Upgrade AP and clients to WPA2/WPA3.',
          ),
        );
        riskFactors.add('Legacy WPA in use');
        score -= 40;
        break;
      case SecurityType.wpa2:
      case SecurityType.wpa3:
      case SecurityType.unknown:
        break;
    }

    if (network.isHidden) {
      vulnerabilities.add(
        const Vulnerability(
          title: 'Hidden SSID',
          description:
              'Hidden SSIDs are still discoverable and may hurt compatibility.',
          severity: VulnerabilitySeverity.low,
          recommendation:
              'Hidden SSID alone is not protection. Focus on strong encryption.',
        ),
      );
      riskFactors.add('Hidden SSID behavior');
      score -= 5;
    }

    if (network.signalStrength < -85) {
      vulnerabilities.add(
        const Vulnerability(
          title: 'Very Weak Signal',
          description:
              'Weak signal can indicate unstable links and spoofing susceptibility.',
          severity: VulnerabilitySeverity.info,
          recommendation: 'Move closer to AP or validate BSSID consistency.',
        ),
      );
      riskFactors.add('Weak signal environment');
      score -= 5;
    }

    // WPS vulnerability (A3)
    if (network.hasWps == true) {
      vulnerabilities.add(
        const Vulnerability(
          title: 'WPS Enabled',
          description:
              'Wi-Fi Protected Setup (WPS) is enabled. The WPS PIN mode '
              'can be brute-forced in hours using publicly available tools '
              '(Pixie Dust attack), effectively bypassing any password.',
          severity: VulnerabilitySeverity.high,
          recommendation:
              'Disable WPS in your router admin panel. Use WPA2/WPA3 passphrase '
              'only.',
        ),
      );
      riskFactors.add('WPS PIN attack surface exposed');
      score -= 30;
    }

    // PMF (Protected Management Frames) check (B1)
    final isWpa2OrBetter = network.security == SecurityType.wpa2 ||
        network.security == SecurityType.wpa3;
    if (isWpa2OrBetter && network.hasPmf == false) {
      vulnerabilities.add(
        const Vulnerability(
          title: 'Management Frames Unprotected',
          description:
              'This access point does not enforce Protected Management Frames '
              '(PMF / 802.11w). Unprotected management frames allow an attacker '
              'to forge deauthentication packets and disconnect clients.',
          severity: VulnerabilitySeverity.medium,
          recommendation:
              'Enable PMF in your router settings (often labelled "802.11w" '
              'or "Management Frame Protection"). WPA3 requires PMF by default.',
        ),
      );
      riskFactors.add('PMF not enforced — deauth spoofing possible');
      score -= 10;
    }

    if (_isPotentialEvilTwin(network, localBaseline)) {
      vulnerabilities.add(
        const Vulnerability(
          title: 'Potential Evil Twin',
          description:
              'SSID appears with conflicting security/channel fingerprint nearby.',
          severity: VulnerabilitySeverity.high,
          recommendation:
              'Verify BSSID and certificate before authentication or data exchange.',
        ),
      );
      riskFactors.add('SSID fingerprint drift detected');
      score -= 35;
    }

    score = score.clamp(0, 100);
    final status = _statusFromScore(score);

    return SecurityAssessment(
      score: score,
      status: status,
      findings: vulnerabilities,
      riskFactors: riskFactors,
    );
  }

  SecurityReport analyze(WifiNetwork network) {
    final assessment = assess(network);
    return SecurityReport(
      score: assessment.score,
      vulnerabilities: assessment.findings,
      overallStatus: assessment.statusLabel,
    );
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

  bool _isPotentialEvilTwin(WifiNetwork target, List<WifiNetwork> baseline) {
    final sameSsid =
        baseline
            .where(
              (entry) => entry.ssid.isNotEmpty && entry.ssid == target.ssid,
            )
            .toList();
    if (sameSsid.isEmpty) {
      return false;
    }

    final conflictingSecurity = sameSsid.any(
      (entry) => entry.security != target.security,
    );
    final heavyChannelDrift = sameSsid.any(
      (entry) => (entry.channel - target.channel).abs() >= 8,
    );

    return conflictingSecurity || heavyChannelDrift;
  }
}
