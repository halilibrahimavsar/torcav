import 'package:injectable/injectable.dart';

import '../entities/host_scan_result.dart';
import '../entities/host_trust_assessment.dart';
import '../entities/vulnerability_finding.dart';

/// Maps a [HostScanResult] (raw exposureScore + finding list + service
/// fingerprints) into a user-facing safe / caution / risky verdict and a
/// short reason list explaining why.
///
/// The UI shows [HostTrustAssessment.level] as a coloured badge and
/// surfaces [HostTrustAssessment.reasons] as a "Why is this risky?" panel.
@lazySingleton
class HostTrustClassifier {
  const HostTrustClassifier();

  HostTrustAssessment classify(HostScanResult host) {
    final reasons = <HostTrustReason>[];
    var level = HostTrustLevel.safe;

    void escalateTo(HostTrustLevel candidate) {
      if (candidate.index > level.index) level = candidate;
    }

    // 1. Roll up the exposure findings.
    for (final finding in host.exposureFindings) {
      reasons.add(
        HostTrustReason(
          summary: finding.summary,
          remediation: finding.remediation,
        ),
      );
      switch (finding.risk) {
        case VulnerabilityRisk.critical:
        case VulnerabilityRisk.high:
          escalateTo(HostTrustLevel.risky);
        case VulnerabilityRisk.medium:
          escalateTo(HostTrustLevel.caution);
        case VulnerabilityRisk.low:
        case VulnerabilityRisk.info:
          // Doesn't move the dial alone.
          break;
      }
    }

    // 2. exposureScore is an aggregate — anything above 60 is concerning
    //    even without an individual finding pinning the cause.
    if (host.exposureScore >= 80) {
      escalateTo(HostTrustLevel.risky);
      reasons.add(
        HostTrustReason(
          summary:
              'Aggregate exposure score is ${host.exposureScore.toStringAsFixed(0)}/100 — '
              'this device has multiple weak signals stacked together.',
        ),
      );
    } else if (host.exposureScore >= 60) {
      escalateTo(HostTrustLevel.caution);
    }

    // 3. Suspicious flag (set by AI/heuristics during scan).
    if (host.isSuspicious) {
      escalateTo(HostTrustLevel.caution);
      reasons.add(
        const HostTrustReason(
          summary:
              'Device looks unusual for this network — vendor or naming '
              'doesn\'t match the rest of your home gear.',
          remediation:
              'If you don\'t recognise this device, change your Wi-Fi '
              'password and check the router\'s admin page.',
        ),
      );
    }

    final headline = _headlineFor(host, level, reasons);
    return HostTrustAssessment(
      level: level,
      headline: headline,
      reasons: List.unmodifiable(reasons),
    );
  }

  String _headlineFor(
    HostScanResult host,
    HostTrustLevel level,
    List<HostTrustReason> reasons,
  ) {
    switch (level) {
      case HostTrustLevel.risky:
        if (reasons.isNotEmpty) return reasons.first.summary;
        return 'Multiple issues detected on this device.';
      case HostTrustLevel.caution:
        if (host.isSuspicious) {
          return 'This device looks unfamiliar — double-check it\'s yours.';
        }
        if (reasons.isNotEmpty) return reasons.first.summary;
        return 'Some weak signals — worth a look but not urgent.';
      case HostTrustLevel.safe:
        if (host.isGateway) return 'Your router. No issues found.';
        return 'Looks normal. No risky services exposed.';
    }
  }
}
