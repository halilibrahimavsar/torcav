import 'package:injectable/injectable.dart';

import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';
import '../entities/evil_twin_assessment.dart';
import 'mesh_vendor_database.dart';

/// Multi-signal evil-twin classifier.
///
/// Replaces single-signal binary checks. The pipeline is:
///   1. **Early dismissal.** If the pair is unmistakably the same physical
///      router across bands (shared MLD MAC, sequential BSSID, or cross-
///      band same-vendor + same-security), confidence is forced to zero
///      and `dismissedAsLegitimate = true`. This is the *first line of
///      defense against false positives* on dual-band / tri-band /
///      mesh routers.
///   2. **Suspicion scoring.** For pairs not dismissed, every observable
///      mismatch (vendor OUI, security downgrade, channel drift, width,
///      WPS, PMF, hidden vs visible) contributes its weight.
///   3. **Soft mitigation.** Some signals (close-but-not-sequential
///      BSSIDs, etc.) lower the score without short-circuiting it.
///   4. **Clamp & threshold.** Confidence is clamped to [0, 1]; values
///      ≥ 0.5 are flagged as candidates.
@lazySingleton
class EvilTwinClassifier {
  /// Confidence threshold above which a pair is flagged as a candidate.
  static const double candidateThreshold = 0.5;

  final MeshVendorDatabase _meshDb;

  const EvilTwinClassifier({MeshVendorDatabase meshDb = const MeshVendorDatabase()})
    : _meshDb = meshDb;

  /// Walk every peer with the same SSID and return the highest-confidence
  /// assessment. If every same-SSID peer is dismissed as legitimate, the
  /// returned assessment carries `dismissedAsLegitimate = true` so the
  /// caller can suppress alerts without losing the audit trail.
  ///
  /// [trustedBssids] short-circuits the check for any peer whose BSSID has
  /// already been explicitly trusted by the user — the user has vouched
  /// for that radio, so it shouldn't trigger a twin alert.
  EvilTwinAssessment assessAll(
    WifiNetwork target,
    List<WifiNetwork> baseline, {
    Set<String> trustedBssids = const {},
  }) {
    final lowerTrusted = trustedBssids.map((b) => b.toLowerCase()).toSet();

    final peers = baseline.where(
      (n) =>
          n.ssid.isNotEmpty &&
          n.ssid == target.ssid &&
          n.bssid.toLowerCase() != target.bssid.toLowerCase(),
    );

    if (peers.isEmpty) return EvilTwinAssessment.none(target.ssid);

    EvilTwinAssessment? best;
    EvilTwinAssessment? lastDismissal;
    for (final peer in peers) {
      // User has explicitly trusted this peer → treat as legitimate.
      if (lowerTrusted.contains(peer.bssid.toLowerCase())) {
        lastDismissal = EvilTwinAssessment.legitimate(
          ssid: target.ssid,
          peerBssid: peer.bssid,
          mitigations: const [],
        );
        continue;
      }
      final result = assess(target, peer);
      if (result.dismissedAsLegitimate) {
        lastDismissal = result;
        continue;
      }
      if (best == null || result.confidence > best.confidence) {
        best = result;
      }
    }

    return best ?? lastDismissal ?? EvilTwinAssessment.none(target.ssid);
  }

  /// Score a single (target, peer) pair. Caller is expected to have
  /// already filtered to same-SSID + different-BSSID rows.
  EvilTwinAssessment assess(WifiNetwork target, WifiNetwork peer) {
    // ── Early dismissal — clearly the same physical router ───────────
    final earlyMitigations = <EvilTwinSignal>[];
    if (_sharesMldMac(target, peer)) {
      earlyMitigations.add(EvilTwinSignal.sharedMldMac);
    }
    if (_bssidProximity(target.bssid, peer.bssid)) {
      earlyMitigations.add(EvilTwinSignal.bssidProximity);
    }
    if (_isCrossBandSibling(target, peer)) {
      earlyMitigations.add(EvilTwinSignal.crossBandSibling);
    }
    if (_meshDb.sameMeshFamily(target.bssid, peer.bssid)) {
      earlyMitigations.add(EvilTwinSignal.knownMeshVendor);
    }

    if (earlyMitigations.isNotEmpty) {
      // Cross-band sibling alone is "soft": only honour it as a hard
      // dismissal when paired with one more legitimacy signal OR when the
      // suspicion profile is weak (no security downgrade, no OUI flip).
      // knownMeshVendor counts as hard because mesh nodes legitimately
      // share an SSID across non-adjacent BSSIDs.
      final hasHardLegit = earlyMitigations.any(
        (s) =>
            s == EvilTwinSignal.sharedMldMac ||
            s == EvilTwinSignal.bssidProximity ||
            s == EvilTwinSignal.knownMeshVendor,
      );
      final wouldHaveSeriousSuspicion =
          _securityRank(peer.security) != _securityRank(target.security) ||
          _ouiPrefix(peer.bssid) != _ouiPrefix(target.bssid);
      if (hasHardLegit || !wouldHaveSeriousSuspicion) {
        return EvilTwinAssessment.legitimate(
          ssid: target.ssid,
          peerBssid: peer.bssid,
          mitigations: List.unmodifiable(earlyMitigations),
        );
      }
    }

    // ── Suspicion scoring ────────────────────────────────────────────
    final suspicions = <EvilTwinSignal>[];

    if (_ouiPrefix(target.bssid) != _ouiPrefix(peer.bssid) &&
        _ouiPrefix(target.bssid).isNotEmpty &&
        _ouiPrefix(peer.bssid).isNotEmpty) {
      suspicions.add(EvilTwinSignal.ouiMismatch);
    }

    if (_securityRank(target.security) != _securityRank(peer.security)) {
      suspicions.add(EvilTwinSignal.securityDowngrade);
    }

    if (_isSameBand(target.frequency, peer.frequency) &&
        (target.channel - peer.channel).abs() >= 4 &&
        target.channel > 0 &&
        peer.channel > 0) {
      suspicions.add(EvilTwinSignal.sameBandChannelDrift);
    }

    if (target.channelWidthMhz != null &&
        peer.channelWidthMhz != null &&
        target.channelWidthMhz != peer.channelWidthMhz) {
      suspicions.add(EvilTwinSignal.channelWidthMismatch);
    }

    if (target.hasWps != null &&
        peer.hasWps != null &&
        target.hasWps != peer.hasWps) {
      suspicions.add(EvilTwinSignal.wpsToggleMismatch);
    }

    if (target.hasPmf != null &&
        peer.hasPmf != null &&
        target.hasPmf != peer.hasPmf) {
      suspicions.add(EvilTwinSignal.pmfToggleMismatch);
    }

    if (target.isHidden != peer.isHidden) {
      suspicions.add(EvilTwinSignal.hiddenVsVisible);
    }

    final mitigations = List.of(earlyMitigations);
    final suspicionScore = suspicions.fold<double>(
      0,
      (acc, s) => acc + s.weight,
    );
    final mitigationScore = mitigations.fold<double>(
      0,
      (acc, s) => acc + s.weight,
    );
    final confidence =
        (suspicionScore - mitigationScore).clamp(0.0, 1.0).toDouble();

    return EvilTwinAssessment(
      confidence: confidence,
      isCandidate: confidence >= candidateThreshold,
      dismissedAsLegitimate: false,
      suspicions: List.unmodifiable(suspicions),
      mitigations: List.unmodifiable(mitigations),
      peerBssid: peer.bssid,
      ssid: target.ssid,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────

  bool _sharesMldMac(WifiNetwork a, WifiNetwork b) {
    final aMld = a.apMldMac;
    final bMld = b.apMldMac;
    if (aMld == null || bMld == null) return false;
    if (aMld.isEmpty || bMld.isEmpty) return false;
    return aMld.toLowerCase() == bMld.toLowerCase();
  }

  /// True when the first five octets match exactly and the last differs by
  /// at most 3. Sequential radio MACs on the same physical device.
  bool _bssidProximity(String a, String b) {
    final pa = a.split(':');
    final pb = b.split(':');
    if (pa.length != 6 || pb.length != 6) return false;
    for (var i = 0; i < 5; i++) {
      if (pa[i].toLowerCase() != pb[i].toLowerCase()) return false;
    }
    final la = int.tryParse(pa[5], radix: 16);
    final lb = int.tryParse(pb[5], radix: 16);
    if (la == null || lb == null) return false;
    return (la - lb).abs() <= 3;
  }

  bool _isCrossBandSibling(WifiNetwork a, WifiNetwork b) {
    if (_isSameBand(a.frequency, b.frequency)) return false;
    if (a.vendor.isEmpty ||
        b.vendor.isEmpty ||
        a.vendor.toLowerCase() == 'unknown' ||
        b.vendor.toLowerCase() == 'unknown') {
      // Vendor field unreliable — fall back to OUI prefix match.
      return _ouiPrefix(a.bssid) == _ouiPrefix(b.bssid) &&
          _ouiPrefix(a.bssid).isNotEmpty &&
          _securityRank(a.security) == _securityRank(b.security);
    }
    return a.vendor == b.vendor &&
        _securityRank(a.security) == _securityRank(b.security);
  }

  bool _isSameBand(int a, int b) => _bandOf(a) == _bandOf(b);

  int _bandOf(int freq) {
    if (freq < 3000) return 2;
    if (freq < 5900) return 5;
    return 6;
  }

  /// First 3 octets of the BSSID — the OUI assigned to the manufacturer.
  /// Empty when the BSSID is malformed.
  String _ouiPrefix(String bssid) {
    final parts = bssid.split(':');
    if (parts.length < 3) return '';
    return parts.take(3).join(':').toLowerCase();
  }

  /// Maps each [SecurityType] to a comparable rank. Different ranks across
  /// peers indicates a downgrade-style mismatch (e.g. WPA3 vs Open).
  int _securityRank(SecurityType s) => switch (s) {
    SecurityType.open => 0,
    SecurityType.wep => 1,
    SecurityType.wpa => 2,
    SecurityType.wpa2 => 3,
    SecurityType.wpa3 => 4,
    SecurityType.unknown => -1,
  };
}
