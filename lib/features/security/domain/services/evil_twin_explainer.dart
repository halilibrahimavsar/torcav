import 'package:injectable/injectable.dart';

import '../entities/evil_twin_assessment.dart';

/// Plain-language summary attached to an [EvilTwinAssessment] for the UI.
///
/// Built so a non-technical user can answer four questions:
///   1. **What is this?** — what an evil-twin attack actually is.
///   2. **Why does it matter?** — what an attacker can do with it.
///   3. **What did we see?** — which signals fired, in human language.
///   4. **What should I do?** — concrete next steps, ranked by urgency.
class EvilTwinExplanation {
  final String headline;
  final String whatIs;
  final String whyItMatters;
  final List<String> observedSignals;
  final List<String> mitigationSignals;
  final List<String> recommendedActions;
  final String confidenceLabel; // "Low", "Medium", "High"
  final String confidencePhrase; // "We're not sure …", "Looks suspicious …"

  const EvilTwinExplanation({
    required this.headline,
    required this.whatIs,
    required this.whyItMatters,
    required this.observedSignals,
    required this.mitigationSignals,
    required this.recommendedActions,
    required this.confidenceLabel,
    required this.confidencePhrase,
  });
}

@lazySingleton
class EvilTwinExplainer {
  const EvilTwinExplainer();

  EvilTwinExplanation explain(EvilTwinAssessment assessment) {
    if (assessment.dismissedAsLegitimate) {
      return EvilTwinExplanation(
        headline: 'Looks like the same router on different bands',
        whatIs:
            'Most home routers broadcast the same Wi-Fi name (SSID) over '
            '2.4 GHz, 5 GHz and sometimes 6 GHz. Your phone sees them as '
            'separate access points even though they\'re one device. '
            'Mesh systems work the same way — every node uses one shared '
            'name.',
        whyItMatters:
            'This pairing is normal and expected — no action needed. We '
            'show this here only so you know we checked and ruled it out.',
        observedSignals: const [],
        mitigationSignals: _mitigationLabels(assessment.mitigations),
        recommendedActions: const [
          'Nothing to do. This is the same router or part of your mesh.',
        ],
        confidenceLabel: 'Safe',
        confidencePhrase:
            'We checked this pair and it matches the pattern of a normal '
            'dual-band router or mesh — not an attack.',
      );
    }

    if (!assessment.isCandidate) {
      return EvilTwinExplanation(
        headline: 'No evil-twin pattern detected',
        whatIs: _whatIs,
        whyItMatters: _whyItMatters,
        observedSignals: _suspicionLabels(assessment.suspicions),
        mitigationSignals: _mitigationLabels(assessment.mitigations),
        recommendedActions: const [
          'Nothing urgent. Re-run a scan if you suspect something has '
              'changed in your environment.',
        ],
        confidenceLabel: 'Low',
        confidencePhrase:
            'Some minor differences exist between the access points '
            'sharing this name, but not enough to look like an attack.',
      );
    }

    final level = _level(assessment.confidence);
    return EvilTwinExplanation(
      headline: _headline(level),
      whatIs: _whatIs,
      whyItMatters: _whyItMatters,
      observedSignals: _suspicionLabels(assessment.suspicions),
      mitigationSignals: _mitigationLabels(assessment.mitigations),
      recommendedActions: _actionsFor(assessment, level),
      confidenceLabel: _label(level),
      confidencePhrase: _phrase(level, assessment),
    );
  }

  // ── Static copy ────────────────────────────────────────────────────

  static const String _whatIs =
      'An "evil twin" is a fake Wi-Fi network that copies the name of a '
      'real one — usually your home or workplace network, or a popular '
      'café hotspot. The goal is to make your phone connect to the '
      'attacker\'s router instead of the real one.';

  static const String _whyItMatters =
      'Once your device is on the attacker\'s Wi-Fi, they can read or '
      'tamper with traffic that isn\'t encrypted, push fake login pages, '
      'redirect you to look-alike websites, or capture passwords typed '
      'into apps that don\'t use HTTPS properly. Banking, email and '
      'messaging are the usual targets.';

  // ── Confidence levels ─────────────────────────────────────────────

  _Level _level(double c) {
    if (c >= 0.75) return _Level.high;
    if (c >= 0.6) return _Level.medium;
    return _Level.low;
  }

  String _label(_Level lvl) => switch (lvl) {
    _Level.high => 'High',
    _Level.medium => 'Medium',
    _Level.low => 'Low',
  };

  String _headline(_Level lvl) => switch (lvl) {
    _Level.high =>
      'Strong evil-twin pattern — treat this network as untrusted',
    _Level.medium => 'Suspicious twin pattern — verify before connecting',
    _Level.low => 'Weak twin signal — keep an eye on this',
  };

  String _phrase(_Level lvl, EvilTwinAssessment a) {
    final pct = (a.confidence * 100).round();
    return switch (lvl) {
      _Level.high =>
        'Confidence: $pct%. Multiple strong mismatches between the two '
            'access points using this name. This is the pattern an '
            'attacker creates when impersonating a Wi-Fi.',
      _Level.medium =>
        'Confidence: $pct%. Several details don\'t line up between the '
            'access points sharing this name. It might be benign, but '
            'verify before trusting it.',
      _Level.low =>
        'Confidence: $pct%. A couple of small mismatches noticed. Most '
            'likely benign — flagged so you can double-check.',
    };
  }

  // ── Recommended actions ───────────────────────────────────────────

  List<String> _actionsFor(EvilTwinAssessment a, _Level lvl) {
    final base = <String>[
      'Don\'t enter passwords, payment details, or two-factor codes while '
          'connected to this Wi-Fi.',
      'If you\'re at home, check the actual MAC (BSSID) printed under '
          'your router and compare it with the BSSIDs shown for this '
          'network.',
      'Forget the network in your phone\'s Wi-Fi settings and only '
          'reconnect by hand to the BSSID you\'ve verified.',
    ];

    if (a.suspicions.contains(EvilTwinSignal.securityDowngrade)) {
      base.insert(
        0,
        'One of the two access points uses weaker encryption than the '
            'other. Always pick the stronger one (WPA3 over WPA2 over Open).',
      );
    }

    if (lvl == _Level.high) {
      base.insert(
        0,
        'Disconnect from this Wi-Fi now and switch to mobile data until '
            'you can verify which BSSID is the real one.',
      );
    }

    if (a.suspicions.contains(EvilTwinSignal.ouiMismatch)) {
      base.add(
        'The two routers come from different hardware vendors — your '
            'real router shouldn\'t suddenly change manufacturer.',
      );
    }

    return base;
  }

  // ── Signal label tables ───────────────────────────────────────────

  List<String> _suspicionLabels(List<EvilTwinSignal> signals) {
    return signals.map(_describe).toList(growable: false);
  }

  List<String> _mitigationLabels(List<EvilTwinSignal> signals) {
    return signals.map(_describe).toList(growable: false);
  }

  String _describe(EvilTwinSignal s) => switch (s) {
    EvilTwinSignal.ouiMismatch =>
      'The two access points come from different hardware vendors '
          '(MAC prefixes don\'t match).',
    EvilTwinSignal.securityDowngrade =>
      'The pair advertises different encryption — typical of a downgrade '
          'attack (e.g. real network = WPA3, fake = WPA2 or Open).',
    EvilTwinSignal.sameBandChannelDrift =>
      'Both broadcast on the same frequency band but on very different '
          'channels — real radios rarely jump that far.',
    EvilTwinSignal.channelWidthMismatch =>
      'They use different channel widths (e.g. 80 MHz vs 20 MHz). Cheap '
          'rogue hardware often runs narrower than the device it\'s copying.',
    EvilTwinSignal.wpsToggleMismatch =>
      'WPS is enabled on one access point but not the other.',
    EvilTwinSignal.pmfToggleMismatch =>
      'Protected Management Frames (802.11w) are enabled on one side '
          'but not the other.',
    EvilTwinSignal.hiddenVsVisible =>
      'One access point is hidden, the other broadcasts its name openly.',
    EvilTwinSignal.sharedMldMac =>
      'Both share the same Wi-Fi 7 multi-link MAC — they are literally '
          'the same physical access point.',
    EvilTwinSignal.bssidProximity =>
      'Their MAC addresses differ only in the last digits — manufacturers '
          'use that pattern for radios on the same router.',
    EvilTwinSignal.crossBandSibling =>
      'They sit on different Wi-Fi bands (2.4 / 5 / 6 GHz) but share the '
          'same vendor and security — classic dual-band router pattern.',
    EvilTwinSignal.knownMeshVendor =>
      'Both MAC addresses belong to a known mesh-router family '
          '(Eero, Google Nest, Asus AiMesh, Netgear Orbi, TP-Link Deco, '
          'or Linksys Velop). Mesh nodes share the same Wi-Fi name on '
          'purpose.',
  };
}

enum _Level { low, medium, high }
