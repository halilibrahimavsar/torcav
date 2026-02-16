import 'package:injectable/injectable.dart';
import '../../../wifi_scan/domain/entities/wifi_network.dart';
import '../entities/vulnerability.dart';
import '../entities/security_report.dart'; // Assuming SecurityReport is in this path

@lazySingleton
class SecurityAnalyzer {
  SecurityReport analyze(WifiNetwork network) {
    final vulnerabilities = <Vulnerability>[];
    int score = 100;

    if (network.security == SecurityType.open) {
      vulnerabilities.add(
        const Vulnerability(
          title: 'Open Network',
          description:
              'This network has no encryption. Traffic can be intercepted easily.',
          severity: VulnerabilitySeverity.critical,
          recommendation:
              'Avoid using this network for sensitive data. Use a VPN.',
        ),
      );
      score -= 80;
    }

    if (network.security == SecurityType.wep) {
      vulnerabilities.add(
        const Vulnerability(
          title: 'Weak Encryption (WEP)',
          description:
              'WEP is extremely insecure and can be cracked in minutes.',
          severity: VulnerabilitySeverity.critical,
          recommendation: 'Do not use. Switch router to WPA2/3.',
        ),
      );
      score -= 70;
    }

    if (network.security == SecurityType.wpa) {
      vulnerabilities.add(
        const Vulnerability(
          title: 'Outdated Encryption (WPA)',
          description: 'WPA is vulnerable to improved attacks.',
          severity: VulnerabilitySeverity.high,
          recommendation: 'Switch router to WPA2 or WPA3.',
        ),
      );
      score -= 40;
    }

    // Check for Hidden SSID
    if (network.isHidden) {
      vulnerabilities.add(
        const Vulnerability(
          title: 'Hidden SSID',
          description:
              'Hidden SSIDs do not provide real security and can be discovered.',
          severity: VulnerabilitySeverity.low,
          recommendation: 'Enable SSID broadcasting for better compatibility.',
        ),
      );
      score -= 5;
    }

    if (score < 0) score = 0;

    String status = 'Secure';
    if (score < 40)
      status = 'Critical';
    else if (score < 70)
      status = 'At Risk';
    else if (score < 90)
      status = 'Moderate';

    // Weak Signal can be a security consistency issue (Evil Twin far away?)
    // But mostly a quality issue. Let's skip for now unless very weak.

    return SecurityReport(
      score: score,
      vulnerabilities: vulnerabilities,
      overallStatus: status,
    );
  }
}
