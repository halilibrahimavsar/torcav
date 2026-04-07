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

    // Suspicious SSID names — common honeypot lures
    if (_isSuspiciousSsid(network.ssid)) {
      vulnerabilities.add(
        const Vulnerability(
          title: 'Suspicious Network Name',
          description:
              'This SSID matches common honeypot/lure patterns used by '
              'attackers to trick users into connecting (e.g. "Free WiFi", '
              '"Airport WiFi"). Legitimate networks rarely use these names.',
          severity: VulnerabilitySeverity.medium,
          recommendation:
              'Verify this network with the venue operator before connecting. '
              'Use a VPN if you must connect to unknown networks.',
        ),
      );
      riskFactors.add('SSID matches known honeypot pattern');
      score -= 15;
    }

    // Channel congestion — many APs sharing the same channel
    final sameChannelCount = localBaseline
        .where((n) => n.channel == network.channel && n.bssid != network.bssid)
        .length;
    if (sameChannelCount >= 5) {
      vulnerabilities.add(
        Vulnerability(
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
        ),
      );
      riskFactors.add('Channel ${network.channel} is heavily congested');
      score -= 5;
    }

    // 2.4 GHz only — no 5 GHz counterpart detected
    if (network.frequency < 3000 && localBaseline.isNotEmpty) {
      final has5GhzSibling = localBaseline.any(
        (n) =>
            n.ssid == network.ssid &&
            n.bssid != network.bssid &&
            n.frequency >= 5000,
      );
      if (!has5GhzSibling && network.security != SecurityType.open) {
        vulnerabilities.add(
          const Vulnerability(
            title: '2.4 GHz Only',
            description:
                'This network only broadcasts on the 2.4 GHz band, which is '
                'more crowded and susceptible to interference. 5 GHz offers '
                'better speed and less interference.',
            severity: VulnerabilitySeverity.info,
            recommendation:
                'Enable 5 GHz band on your router for better performance. '
                'Most modern devices support dual-band operation.',
          ),
        );
        riskFactors.add('No 5 GHz band detected');
        score -= 3;
      }
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
    return _honeypotPatterns.any((pattern) => lower == pattern || lower.contains(pattern));
  }

  bool _isPotentialEvilTwin(WifiNetwork target, List<WifiNetwork> baseline) {
    final sameSsid =
        baseline
            .where(
              (entry) =>
                  entry.ssid.isNotEmpty &&
                  entry.ssid == target.ssid &&
                  entry.bssid != target.bssid,
            )
            .toList();
    if (sameSsid.isEmpty) {
      return false;
    }

    // Check each peer with the same SSID
    for (final peer in sameSsid) {
      // Skip if this is a legitimate multi-band/multi-radio sibling
      if (_isLegitimateMultiBandSibling(target, peer)) continue;

      // Flag 1: Conflicting security type (e.g. WPA2 vs Open)
      if (peer.security != target.security) return true;

      // Flag 2: Heavy channel drift *within the same frequency band*
      if (_isSameBand(target.frequency, peer.frequency)) {
        if ((peer.channel - target.channel).abs() >= 6) return true;
      }
    }

    return false;
  }

  /// Determines whether two APs with the same SSID are likely from the
  /// same physical router broadcasting on different bands (2.4/5/6 GHz).
  bool _isLegitimateMultiBandSibling(WifiNetwork a, WifiNetwork b) {
    // If on the same band, they are NOT multi-band siblings
    if (_isSameBand(a.frequency, b.frequency)) return false;

    // Wi-Fi 7 MLD: if both share the same AP MLD MAC, they are the same device
    if (a.apMldMac != null &&
        a.apMldMac!.isNotEmpty &&
        a.apMldMac == b.apMldMac) {
      return true;
    }

    // BSSID proximity: manufacturers typically assign sequential MACs
    // to radios on the same device (e.g. AA:BB:CC:DD:EE:01 and :02)
    if (_areBssidsClose(a.bssid, b.bssid)) return true;

    // Same vendor + same security across different bands is very likely
    // a legitimate dual-band router
    if (a.vendor == b.vendor &&
        a.vendor != 'Unknown' &&
        a.security == b.security) {
      return true;
    }

    return false;
  }

  /// Returns true if two frequencies belong to the same Wi-Fi band.
  bool _isSameBand(int freqA, int freqB) {
    return _bandOf(freqA) == _bandOf(freqB);
  }

  /// Maps a frequency (MHz) to its band identifier.
  int _bandOf(int freq) {
    if (freq < 3000) return 2;  // 2.4 GHz
    if (freq < 5900) return 5;  // 5 GHz
    return 6;                    // 6 GHz
  }

  /// Checks if two BSSIDs differ by at most 3 in the last octet,
  /// with identical prefix — a strong indicator of same physical device.
  bool _areBssidsClose(String bssidA, String bssidB) {
    final partsA = bssidA.split(':');
    final partsB = bssidB.split(':');
    if (partsA.length != 6 || partsB.length != 6) return false;

    // First 5 octets must match exactly
    for (int i = 0; i < 5; i++) {
      if (partsA[i].toLowerCase() != partsB[i].toLowerCase()) return false;
    }

    // Last octet should be within 3 (covers up to 4 radios: 2.4, 5L, 5H, 6)
    final lastA = int.tryParse(partsA[5], radix: 16) ?? -1;
    final lastB = int.tryParse(partsB[5], radix: 16) ?? -1;
    if (lastA < 0 || lastB < 0) return false;

    return (lastA - lastB).abs() <= 3;
  }
}
