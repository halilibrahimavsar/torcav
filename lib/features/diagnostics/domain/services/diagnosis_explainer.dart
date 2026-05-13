import 'package:injectable/injectable.dart';

import '../entities/category_explanation.dart';
import '../entities/diagnosis_evidence.dart';
import '../entities/diagnosis_inputs.dart';
import '../entities/root_cause_category.dart';

/// Builds a human-readable [CategoryExplanation] for each [DiagnosisEvidence].
///
/// Kept separate from [DiagnoseUseCase] so the scoring logic stays a pure
/// numeric function. Estimates are deliberately conservative — the goal is
/// to set realistic expectations rather than promise a specific Mbps gain.
@lazySingleton
class DiagnosisExplainer {
  const DiagnosisExplainer();

  CategoryExplanation explain(
    DiagnosisEvidence evidence,
    DiagnosisInputs inputs,
  ) {
    switch (evidence.category) {
      case RootCauseCategory.weakSignal:
        return _weakSignal(evidence, inputs);
      case RootCauseCategory.crowdedChannel:
        return _crowdedChannel(evidence, inputs);
      case RootCauseCategory.bufferbloat:
        return _bufferbloat(evidence, inputs);
      case RootCauseCategory.ispSlow:
        return _ispSlow(evidence, inputs);
      case RootCauseCategory.slowDns:
        return _slowDns(evidence, inputs);
      case RootCauseCategory.healthy:
        return _healthy();
    }
  }

  // ── Weak signal ─────────────────────────────────────────────────────────
  CategoryExplanation _weakSignal(
    DiagnosisEvidence ev,
    DiagnosisInputs inputs,
  ) {
    final download = inputs.speedTest?.downloadMbps;
    String? estimate;
    double? finalGain;
    if (download != null && download > 1) {
      // Wi-Fi throughput scales roughly with SNR: a strong-signal link can
      // sustain its PHY rate, while a weak link is forced into lower MCS
      // indices. Conservative model: full fix recovers 50% × severity of
      // current download, capped at the radio's headroom.
      final phy = inputs.connectedNetwork?.estimatedMaxThroughputMbps;
      var gain = download * 0.5 * ev.severity;
      if (phy != null) {
        final headroom = (phy * 0.7) - download;
        if (headroom > 0 && gain > headroom) gain = headroom;
      }
      if (gain >= 5) {
        finalGain = gain;
        estimate =
            'Estimated gain: up to +${gain.toStringAsFixed(0)} Mbps download '
            'if you can pull the device closer to the router.';
      }
    }
    return CategoryExplanation(
      whatIsKey: 'sdWeakSignalWhatIs',
      whyItMattersKey: 'sdWeakSignalWhyItMatters',
      howToFixKeys: const [
        'sdWeakSignalHowToFix1',
        'sdWeakSignalHowToFix2',
        'sdWeakSignalHowToFix3',
        'sdWeakSignalHowToFix4',
      ],
      estimatedImprovementKey: estimate != null ? 'sdWeakSignalEstimate' : null,
      estimatedImprovementParams:
          finalGain != null ? {'gain': finalGain.toStringAsFixed(0)} : null,
      whatIs:
          'Signal strength (RSSI) measures how loudly your device hears the '
          'router. Below about −70 dBm, Wi-Fi has to drop to slower, more '
          'redundant encodings to stay reliable.',
      whyItMatters:
          'A weak signal forces the radio into low-rate modes. Even if your '
          'internet plan is fast, the Wi-Fi link itself becomes the ceiling '
          '— downloads stall, video calls drop, and pages take longer.',
      howToFix: const [
        'Move closer to the router or to a less obstructed spot.',
        'Add a mesh node / Wi-Fi extender in this area.',
        'If your router supports 5 GHz or 6 GHz on this SSID, use that band '
            'when you are in line-of-sight of it.',
        'Check that the router is not buried inside a cabinet, behind a TV, '
            'or next to a microwave.',
      ],
      estimatedImprovement: estimate,
    );
  }

  // ── Crowded channel ────────────────────────────────────────────────────
  CategoryExplanation _crowdedChannel(
    DiagnosisEvidence ev,
    DiagnosisInputs inputs,
  ) {
    final download = inputs.speedTest?.downloadMbps;
    String? estimate;
    double? finalGain;
    if (download != null && download > 1 && ev.severity > 0.4) {
      // Channel contention costs airtime. A clean channel typically
      // recovers ~30–50% of contention loss. Conservative: severity × 0.4.
      final gain = download * 0.4 * ev.severity;
      if (gain >= 3) {
        finalGain = gain;
        estimate =
            'Estimated gain: up to +${gain.toStringAsFixed(0)} Mbps download '
            'after switching to a quieter channel.';
      }
    }
    return CategoryExplanation(
      whatIsKey: 'sdCrowdedChannelWhatIs',
      whyItMattersKey: 'sdCrowdedChannelWhyItMatters',
      howToFixKeys: const [
        'sdCrowdedChannelHowToFix1',
        'sdCrowdedChannelHowToFix2',
        'sdCrowdedChannelHowToFix3',
        'sdCrowdedChannelHowToFix4',
      ],
      estimatedImprovementKey:
          estimate != null ? 'sdCrowdedChannelEstimate' : null,
      estimatedImprovementParams:
          finalGain != null ? {'gain': finalGain.toStringAsFixed(0)} : null,
      whatIs:
          'Wi-Fi channels are shared spectrum. When several nearby access '
          'points transmit on the same channel, they have to take turns — '
          'air-time is split between all of them, including yours.',
      whyItMatters:
          'On a crowded channel your throughput drops even when no one in '
          'your home is using the network. The radio is healthy, but it has '
          'to wait for its turn to talk.',
      howToFix: const [
        'Open the router admin page and switch the Wi-Fi channel manually '
            '(Channel Rating in the app suggests the cleanest one).',
        'On 2.4 GHz, prefer channels 1 / 6 / 11 — they do not overlap.',
        'If your router supports 5 GHz or 6 GHz, move the device to that '
            'band: there are far more clean channels available.',
        'For dual-band routers, give each band its own SSID so devices stop '
            'flipping back to a crowded 2.4 GHz channel.',
      ],
      estimatedImprovement: estimate,
    );
  }

  // ── Bufferbloat ────────────────────────────────────────────────────────
  CategoryExplanation _bufferbloat(
    DiagnosisEvidence ev,
    DiagnosisInputs inputs,
  ) {
    String? estimate;
    final speed = inputs.speedTest;
    double? finalReduction;
    if (speed != null) {
      final induced = speed.loadedLatencyMs - speed.latencyMs;
      // A working SQM/QoS implementation typically pulls induced latency
      // back under 30 ms. Project the latency reduction, not throughput.
      if (induced > 50) {
        final reduction = (induced - 30).clamp(0, induced).toDouble();
        finalReduction = reduction;
        estimate =
            'Estimated gain: about −${reduction.toStringAsFixed(0)} ms loaded '
            'latency. Calls and gaming will feel responsive even during '
            'large downloads.';
      }
    }
    return CategoryExplanation(
      whatIsKey: 'sdBufferbloatWhatIs',
      whyItMattersKey: 'sdBufferbloatWhyItMatters',
      howToFixKeys: const [
        'sdBufferbloatHowToFix1',
        'sdBufferbloatHowToFix2',
        'sdBufferbloatHowToFix3',
        'sdBufferbloatHowToFix4',
      ],
      estimatedImprovementKey:
          estimate != null ? 'sdBufferbloatEstimate' : null,
      estimatedImprovementParams:
          finalReduction != null
              ? {'reduction': finalReduction.toStringAsFixed(0)}
              : null,
      whatIs:
          'Bufferbloat is the latency that builds up inside your router\'s '
          'send buffers when the link is fully loaded — typical packets '
          'have to queue behind a backlog of bulk traffic.',
      whyItMatters:
          'Your download speed can look great while a file is in flight, '
          'but voice calls jitter, video conferences freeze, and games lag '
          '— anything time-sensitive is held up behind the queue.',
      howToFix: const [
        'Enable QoS / SQM (sometimes called "Smart Queue Management" or '
            '"Adaptive QoS") in your router admin page.',
        'Update the router firmware — modern firmware ships better queue '
            'discipline by default.',
        'If the router is many years old and lacks SQM, replacing it with '
            'a recent model is often the only real fix.',
        'Cap upload bandwidth in the router slightly below your real plan '
            '(e.g. 90%) so the queue lives on the router, not at the ISP.',
      ],
      estimatedImprovement: estimate,
    );
  }

  // ── ISP slow ───────────────────────────────────────────────────────────
  CategoryExplanation _ispSlow(DiagnosisEvidence ev, DiagnosisInputs inputs) {
    String? estimate;
    final download = inputs.speedTest?.downloadMbps;
    final phy = inputs.connectedNetwork?.estimatedMaxThroughputMbps;
    if (download != null && phy != null) {
      // Radio headroom is generous. Real ceiling is whatever the user's ISP
      // plan delivers — we cannot know it, so show the radio capacity as
      // the upper bound.
      estimate =
          'Your Wi-Fi can carry up to ~${phy.toStringAsFixed(0)} Mbps; you '
          'are currently getting ${download.toStringAsFixed(1)} Mbps. The '
          'gap is upstream of the router.';
    }
    return CategoryExplanation(
      whatIsKey: 'sdIspSlowWhatIs',
      whyItMattersKey: 'sdIspSlowWhyItMatters',
      howToFixKeys: const [
        'sdIspSlowHowToFix1',
        'sdIspSlowHowToFix2',
        'sdIspSlowHowToFix3',
        'sdIspSlowHowToFix4',
      ],
      estimatedImprovementKey: estimate != null ? 'sdIspSlowEstimate' : null,
      estimatedImprovementParams:
          estimate != null
              ? {
                'phy': phy?.toStringAsFixed(0),
                'download': download?.toStringAsFixed(1),
              }
              : null,
      whatIs:
          'Your Wi-Fi link is healthy and the radio could carry far more '
          'than what is actually flowing through it. The bottleneck sits '
          'upstream of the router.',
      whyItMatters:
          'No amount of router or Wi-Fi tuning will help — the link from '
          'your ISP to the router is the ceiling. Treat this as data for a '
          'plan-upgrade or support call, not as a Wi-Fi problem.',
      howToFix: const [
        'Re-run the test with a wired Ethernet cable to confirm the radio '
            'is not at fault.',
        'Check the ISP plan you are paying for — the test result should '
            'match it within ~80% on a good day.',
        'Try at different times of day. If only evenings are slow, the '
            'ISP segment may be congested.',
        'If the result is consistently far below your plan, contact the '
            'ISP with the speed test output.',
      ],
      estimatedImprovement: estimate,
    );
  }

  // ── Slow DNS ───────────────────────────────────────────────────────────
  CategoryExplanation _slowDns(DiagnosisEvidence ev, DiagnosisInputs inputs) {
    final benchmark = inputs.dnsBenchmark;
    String? estimate;
    num? finalReduction;
    if (benchmark != null && benchmark.latencyMs > 50) {
      final reduction = (benchmark.latencyMs - 30).clamp(0, 9999);
      finalReduction = reduction;
      estimate =
          'Estimated gain: about −$reduction ms per name lookup. Page '
          'loads usually feel 5–20% snappier because each page kicks off '
          'a dozen lookups.';
    }
    return CategoryExplanation(
      whatIsKey: 'sdSlowDnsWhatIs',
      whyItMattersKey: 'sdSlowDnsWhyItMatters',
      howToFixKeys: const [
        'sdSlowDnsHowToFix1',
        'sdSlowDnsHowToFix2',
        'sdSlowDnsHowToFix3',
      ],
      estimatedImprovementKey: estimate != null ? 'sdSlowDnsEstimate' : null,
      estimatedImprovementParams:
          finalReduction != null ? {'reduction': finalReduction} : null,
      whatIs:
          'DNS turns names like example.com into the IP addresses your '
          'device actually connects to. Every page load fires off a handful '
          'of these lookups before any data flows.',
      whyItMatters:
          'Slow DNS does not lower your download speed — it adds a delay at '
          'the start of every connection. The web feels "laggy" even when '
          'speed tests look fine.',
      howToFix: const [
        'Switch your device or router DNS to a fast public resolver — '
            '1.1.1.1 (Cloudflare), 8.8.8.8 (Google), or 9.9.9.9 (Quad9).',
        'Enable DNS-over-HTTPS (DoH) or DNS-over-TLS (DoT) in your OS or '
            'browser to also encrypt the lookups.',
        'If your ISP\'s DNS is slow, set the resolver on the router so the '
            'whole household benefits, not just one device.',
      ],
      estimatedImprovement: estimate,
    );
  }

  CategoryExplanation _healthy() {
    return const CategoryExplanation(
      whatIsKey: 'sdHealthyWhatIs',
      whyItMattersKey: 'sdHealthyWhyItMatters',
      whatIs:
          'Speed Doctor checks five things: signal strength, channel '
          'congestion, speed-under-load (bufferbloat), download throughput '
          'vs Wi-Fi capacity, and DNS resolution time.',
      whyItMatters:
          'None of those crossed an alert threshold this run. Your link is '
          'in good shape right now — re-run the test if you start noticing '
          'a problem to see whether anything shifted.',
    );
  }
}
