import 'dart:collection';

import 'package:equatable/equatable.dart';

import 'dns_candidate.dart';
import 'jitter_sample.dart';

/// Rolling tunnel statistics with EWMA smoothing.
///
/// EWMA (exponentially weighted moving average) gives recent samples more
/// weight than older ones — well-suited for jitter where a few-second-old
/// value already misrepresents the current path.
class LiveStats extends Equatable {
  static const int windowSize = 60; // 60 samples ≈ 1 minute @ 1 Hz
  static const double alpha = 0.25; // EWMA smoothing factor

  final UnmodifiableListView<JitterSample> samples;
  final double ewmaLatencyMs;
  final double ewmaJitterMs;
  final double lossPct;
  final DnsCandidate? activeDns;
  final int packetsAccepted;
  final int packetsDeprioritized;

  LiveStats._({
    required List<JitterSample> samples,
    required this.ewmaLatencyMs,
    required this.ewmaJitterMs,
    required this.lossPct,
    required this.activeDns,
    required this.packetsAccepted,
    required this.packetsDeprioritized,
  }) : samples = UnmodifiableListView(samples);

  factory LiveStats.empty() => LiveStats._(
    samples: const [],
    ewmaLatencyMs: 0,
    ewmaJitterMs: 0,
    lossPct: 0,
    activeDns: null,
    packetsAccepted: 0,
    packetsDeprioritized: 0,
  );

  LiveStats add(
    JitterSample s, {
    DnsCandidate? activeDns,
    int packetsAccepted = 0,
    int packetsDeprioritized = 0,
  }) {
    final next = List<JitterSample>.from(samples)..add(s);
    if (next.length > windowSize) {
      next.removeRange(0, next.length - windowSize);
    }
    final newEwmaLatency =
        samples.isEmpty
            ? s.latencyMs
            : alpha * s.latencyMs + (1 - alpha) * ewmaLatencyMs;
    final newEwmaJitter =
        samples.isEmpty
            ? s.jitterMs
            : alpha * s.jitterMs + (1 - alpha) * ewmaJitterMs;
    return LiveStats._(
      samples: next,
      ewmaLatencyMs: newEwmaLatency,
      ewmaJitterMs: newEwmaJitter,
      lossPct: s.lossPct,
      activeDns: activeDns ?? this.activeDns,
      packetsAccepted: this.packetsAccepted + packetsAccepted,
      packetsDeprioritized: this.packetsDeprioritized + packetsDeprioritized,
    );
  }

  /// Returns true when the rolling jitter has crossed the supplied threshold
  /// for at least [consecutiveSamples] samples — used by the recommendation
  /// engine to trigger a tunnel reconnect.
  bool jitterBreached(double thresholdMs, int consecutiveSamples) {
    if (samples.length < consecutiveSamples) return false;
    final tail = samples.sublist(samples.length - consecutiveSamples);
    return tail.every((s) => s.jitterMs > thresholdMs);
  }

  @override
  List<Object?> get props => [
    samples,
    ewmaLatencyMs,
    ewmaJitterMs,
    lossPct,
    activeDns,
    packetsAccepted,
    packetsDeprioritized,
  ];
}
