import 'package:injectable/injectable.dart';

import '../../../security/domain/entities/network_context_type.dart';
import '../../../wifi_scan/domain/entities/wifi_network.dart';
import '../../../wifi_scan/domain/services/channel_rating_engine.dart';
import '../entities/diagnosis_evidence.dart';
import '../entities/diagnosis_inputs.dart';
import '../entities/diagnosis_result.dart';
import '../entities/diagnostic_action.dart';
import '../entities/root_cause_category.dart';
import 'thresholds.dart';

/// Pure decision function. Maps [DiagnosisInputs] → [DiagnosisResult] by
/// scoring each [RootCauseCategory] independently and returning the highest-
/// severity category as the primary cause.
@lazySingleton
class DiagnoseUseCase {
  final ChannelRatingEngine _ratingEngine;

  DiagnoseUseCase(this._ratingEngine);

  DiagnosisResult call(DiagnosisInputs inputs) {
    final evidence = <DiagnosisEvidence>[];

    final signal = _evaluateWeakSignal(inputs.connectedNetwork);
    if (signal != null) evidence.add(signal);

    final channel = _evaluateCrowdedChannel(inputs);
    if (channel != null) evidence.add(channel);

    final bufferbloat = _evaluateBufferbloat(inputs.speedTest);
    if (bufferbloat != null) evidence.add(bufferbloat);

    final dns = _evaluateSlowDns(inputs.dnsBenchmark);
    if (dns != null) evidence.add(dns);

    // ISP suppressed on public/guest networks — the user does not own the
    // upstream link, so suggesting "call your ISP" would be misleading.
    if (inputs.context != NetworkContextType.public &&
        inputs.context != NetworkContextType.guest) {
      final isp = _evaluateIspSlow(inputs);
      if (isp != null) evidence.add(isp);
    }

    evidence.sort((a, b) => b.severity.compareTo(a.severity));

    final primary =
        (evidence.isEmpty ||
                evidence.first.severity <
                    DiagnosticThresholds.primaryCauseSeverityFloor)
            ? RootCauseCategory.healthy
            : evidence.first.category;

    return DiagnosisResult(
      timestamp: DateTime.now(),
      primaryCause: primary,
      allEvidence: List.unmodifiable(evidence),
      inputs: inputs,
    );
  }

  DiagnosisEvidence? _evaluateWeakSignal(WifiNetwork? connected) {
    if (connected == null) return null;
    final rssi = connected.signalStrength;
    final span =
        (DiagnosticThresholds.rssiHealthyDbm -
                DiagnosticThresholds.rssiSevereDbm)
            .toDouble(); // 20
    final raw = (DiagnosticThresholds.rssiHealthyDbm - rssi) / span;
    final severity = raw.clamp(0.0, 1.0);
    return DiagnosisEvidence(
      category: RootCauseCategory.weakSignal,
      severity: severity,
      metricLabel: 'RSSI: $rssi dBm',
      thresholdLabel:
          'Healthy ≥ ${DiagnosticThresholds.rssiHealthyDbm} dBm · '
          'Severe ≤ ${DiagnosticThresholds.rssiSevereDbm} dBm',
      actions: const [
        DiagnosticAction(labelKey: 'speedDoctorActionMoveCloser'),
        DiagnosticAction(labelKey: 'speedDoctorActionAddMesh'),
        DiagnosticAction(labelKey: 'speedDoctorActionSwitchTo5Ghz'),
      ],
    );
  }

  DiagnosisEvidence? _evaluateCrowdedChannel(DiagnosisInputs inputs) {
    final connected = inputs.connectedNetwork;
    if (connected == null || inputs.visibleNetworks.isEmpty) return null;

    final ratings = _ratingEngine.calculateRatings(inputs.visibleNetworks);
    if (ratings.isEmpty) return null;

    // Find the rating row matching the connected network's frequency.
    // Channel-number alone collides between 2.4 and 6 GHz so we match by
    // frequency, the same key the rating engine uses internally.
    final connectedRating = ratings.firstWhere(
      (r) => r.frequency == connected.frequency,
      orElse: () => ratings.first,
    );

    final score = connectedRating.rating; // 0..10
    final span =
        DiagnosticThresholds.channelHealthyScore -
        DiagnosticThresholds.channelSevereScore;
    final raw = (DiagnosticThresholds.channelHealthyScore - score) / span;
    final severity = raw.clamp(0.0, 1.0);

    return DiagnosisEvidence(
      category: RootCauseCategory.crowdedChannel,
      severity: severity,
      metricLabel:
          'Channel ${connectedRating.channel} · score '
          '${score.toStringAsFixed(1)}/10',
      thresholdLabel:
          'Healthy ≥ ${DiagnosticThresholds.channelHealthyScore.toStringAsFixed(1)} · '
          'Severe ≤ ${DiagnosticThresholds.channelSevereScore.toStringAsFixed(1)}',
      actions: const [
        DiagnosticAction(labelKey: 'speedDoctorActionChangeChannel'),
        DiagnosticAction(labelKey: 'speedDoctorActionMoveTo5Ghz'),
      ],
    );
  }

  DiagnosisEvidence? _evaluateBufferbloat(speedTest) {
    if (speedTest == null) return null;
    final induced = speedTest.loadedLatencyMs - speedTest.latencyMs;
    if (induced.isNaN || induced.isInfinite) return null;
    final span =
        DiagnosticThresholds.bufferbloatSevereMs -
        DiagnosticThresholds.bufferbloatHealthyMs;
    final raw = (induced - DiagnosticThresholds.bufferbloatHealthyMs) / span;
    final severity = raw.clamp(0.0, 1.0).toDouble();
    return DiagnosisEvidence(
      category: RootCauseCategory.bufferbloat,
      severity: severity,
      metricLabel:
          'Loaded latency Δ: ${induced.toStringAsFixed(0)} ms '
          '(${speedTest.latencyMs.toStringAsFixed(0)} → '
          '${speedTest.loadedLatencyMs.toStringAsFixed(0)})',
      thresholdLabel:
          'Healthy ≤ ${DiagnosticThresholds.bufferbloatHealthyMs.toStringAsFixed(0)} ms · '
          'Severe ≥ ${DiagnosticThresholds.bufferbloatSevereMs.toStringAsFixed(0)} ms',
      actions: const [
        DiagnosticAction(
          labelKey: 'speedDoctorActionEnableQos',
          deepLinkRoute: 'router-hardening',
        ),
        DiagnosticAction(labelKey: 'speedDoctorActionUpdateFirmware'),
      ],
    );
  }

  DiagnosisEvidence? _evaluateIspSlow(DiagnosisInputs inputs) {
    final speed = inputs.speedTest;
    final connected = inputs.connectedNetwork;
    if (speed == null) return null;

    final phy = connected?.estimatedMaxThroughputMbps;
    final download = speed.downloadMbps;

    // We only blame the ISP when the radio link is clearly capable of more.
    // If we don't know PHY (no Android extended fields), require the
    // absolute floor alone.
    final phyHeadroomOk =
        phy == null
            ? true
            : (download / phy) <= DiagnosticThresholds.ispSlowPhyRatioCeiling;
    if (!phyHeadroomOk) return null;

    final shortfall =
        (DiagnosticThresholds.ispSlowAbsoluteMbps - download) /
        DiagnosticThresholds.ispSlowAbsoluteMbps;
    final severity = shortfall.clamp(0.0, 1.0).toDouble();
    if (severity <= 0) return null;

    return DiagnosisEvidence(
      category: RootCauseCategory.ispSlow,
      severity: severity,
      metricLabel:
          phy == null
              ? 'Download: ${download.toStringAsFixed(1)} Mbps'
              : 'Download: ${download.toStringAsFixed(1)} Mbps · '
                  'PHY: ${phy.toStringAsFixed(0)} Mbps',
      thresholdLabel:
          'Healthy ≥ ${DiagnosticThresholds.ispSlowAbsoluteMbps.toStringAsFixed(0)} Mbps '
          'when radio is uncongested',
      actions: const [
        DiagnosticAction(labelKey: 'speedDoctorActionCallIsp'),
        DiagnosticAction(labelKey: 'speedDoctorActionRunWiredTest'),
      ],
    );
  }

  DiagnosisEvidence? _evaluateSlowDns(dnsBenchmark) {
    if (dnsBenchmark == null) return null;
    final latency = dnsBenchmark.latencyMs;
    if (latency < 0) return null; // -1 marks a failed probe
    final span =
        (DiagnosticThresholds.dnsSevereMs -
                DiagnosticThresholds.dnsHealthyMs)
            .toDouble();
    final raw = (latency - DiagnosticThresholds.dnsHealthyMs) / span;
    final severity = raw.clamp(0.0, 1.0).toDouble();
    return DiagnosisEvidence(
      category: RootCauseCategory.slowDns,
      severity: severity,
      metricLabel:
          'Best resolver: ${dnsBenchmark.name} · $latency ms',
      thresholdLabel:
          'Healthy ≤ ${DiagnosticThresholds.dnsHealthyMs} ms · '
          'Severe ≥ ${DiagnosticThresholds.dnsSevereMs} ms',
      actions: const [
        DiagnosticAction(labelKey: 'speedDoctorActionChangeDns'),
        DiagnosticAction(labelKey: 'speedDoctorActionEnableDoh'),
      ],
    );
  }
}
