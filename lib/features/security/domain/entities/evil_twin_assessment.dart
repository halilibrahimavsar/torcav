import 'package:equatable/equatable.dart';

import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

/// One observable signal that either raises or lowers suspicion that two
/// access points sharing an SSID are an evil-twin pairing rather than a
/// legitimate dual-band / mesh sibling.
///
/// Suspicion signals push confidence up; mitigation signals push it down.
/// Final confidence is `clamp(suspicions − mitigations, 0, 1)`.
enum EvilTwinSignal {
  // ── Suspicion (pushes confidence up) ──────────────────────────────────
  /// Different OUI prefix → different hardware vendor → unlikely siblings.
  ouiMismatch,

  /// One AP advertises a stronger crypto suite than the other (e.g.
  /// WPA3 vs WPA2 / Open). Classic downgrade-attack pattern.
  securityDowngrade,

  /// Same band, far apart on the channel grid (≥4 channels). Real radios
  /// rarely jump that far on the fly.
  sameBandChannelDrift,

  /// Channel widths disagree (e.g. 80 MHz vs 20 MHz). Cheap rogue APs
  /// often run a narrower width than the device they're impersonating.
  channelWidthMismatch,

  /// One advertises WPS / has WPS enabled, the other doesn't.
  wpsToggleMismatch,

  /// Protected Management Frames (PMF / 802.11w) toggle differs.
  pmfToggleMismatch,

  /// One side is hidden, the other is broadcast.
  hiddenVsVisible,

  // ── Mitigation (pushes confidence down) ───────────────────────────────
  /// Wi-Fi 7 multi-link: both rows share the AP MLD MAC.
  sharedMldMac,

  /// BSSIDs identical except for the last octet (≤3 step). Manufacturers
  /// hand out sequential MACs to radios on the same physical device.
  bssidProximity,

  /// Different bands, same vendor, same security suite — a textbook
  /// dual-band / tri-band router.
  crossBandSibling,

  /// Both BSSIDs belong to a known consumer mesh-router OUI prefix
  /// family (Eero, Google Nest, Asus AiMesh, etc.). Mesh nodes often
  /// don't have sequential MACs but should still be treated as siblings.
  knownMeshVendor,
}

/// Numeric weight applied to each signal when computing confidence.
extension EvilTwinSignalWeight on EvilTwinSignal {
  double get weight => switch (this) {
    EvilTwinSignal.ouiMismatch => 0.40,
    EvilTwinSignal.securityDowngrade => 0.40,
    EvilTwinSignal.sameBandChannelDrift => 0.30,
    EvilTwinSignal.channelWidthMismatch => 0.20,
    EvilTwinSignal.wpsToggleMismatch => 0.20,
    EvilTwinSignal.pmfToggleMismatch => 0.20,
    EvilTwinSignal.hiddenVsVisible => 0.20,
    EvilTwinSignal.sharedMldMac => 0.60,
    EvilTwinSignal.bssidProximity => 0.40,
    EvilTwinSignal.crossBandSibling => 0.40,
    EvilTwinSignal.knownMeshVendor => 0.50,
  };
}

/// Result of comparing one [WifiNetwork] against one peer carrying the
/// same SSID. A `confidence ≥ 0.5` is treated as a candidate evil twin.
class EvilTwinAssessment extends Equatable {
  /// 0..1 — how strongly the multi-signal scoring suggests an evil twin.
  /// 0 means the pair was either unrelated or *clearly legitimate* (early
  /// dismissal short-circuited scoring).
  final double confidence;

  /// True iff [confidence] meets the trigger threshold.
  final bool isCandidate;

  /// True when the pair was discarded by the early dismissal check (e.g.
  /// shared MLD, BSSID proximity, or cross-band same-vendor pairing).
  /// In that case the UI should NOT raise an alert — these are dual-band
  /// / mesh siblings that look the same on purpose.
  final bool dismissedAsLegitimate;

  /// Signals that fired in the suspicion direction.
  final List<EvilTwinSignal> suspicions;

  /// Signals that fired as mitigations (only relevant when not dismissed).
  final List<EvilTwinSignal> mitigations;

  /// BSSID of the peer that triggered the highest score. Empty if none.
  final String peerBssid;

  /// SSID being assessed (same on both sides).
  final String ssid;

  const EvilTwinAssessment({
    required this.confidence,
    required this.isCandidate,
    required this.dismissedAsLegitimate,
    required this.suspicions,
    required this.mitigations,
    required this.peerBssid,
    required this.ssid,
  });

  /// A "no-finding" assessment — used when no peer with the same SSID
  /// exists (the most common case in normal scans).
  const EvilTwinAssessment.none(this.ssid)
    : confidence = 0,
      isCandidate = false,
      dismissedAsLegitimate = false,
      suspicions = const [],
      mitigations = const [],
      peerBssid = '';

  /// A "clearly legitimate" assessment — same physical router across bands
  /// or sequential mesh radios. Confidence is forced to zero.
  const EvilTwinAssessment.legitimate({
    required this.ssid,
    required this.peerBssid,
    required this.mitigations,
  }) : confidence = 0,
       isCandidate = false,
       dismissedAsLegitimate = true,
       suspicions = const [];

  @override
  List<Object?> get props => [
    confidence,
    isCandidate,
    dismissedAsLegitimate,
    suspicions,
    mitigations,
    peerBssid,
    ssid,
  ];
}
