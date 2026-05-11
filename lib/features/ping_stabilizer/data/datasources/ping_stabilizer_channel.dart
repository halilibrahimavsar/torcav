import 'dart:async';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/dns_candidate.dart';
import '../../domain/entities/jitter_sample.dart';
import '../../domain/entities/stabilization_profile.dart';

/// Dart-side bridge to the `torcav/ping_stabilizer` method channel and the
/// `torcav/ping_stabilizer/stats` event channel implemented by
/// [PingStabilizerVpnService] on Android. On platforms without an
/// implementation the methods return safe defaults so the rest of the app
/// keeps working in tests / on desktop until phase 3.
@lazySingleton
class PingStabilizerChannel {
  static const _method = MethodChannel('torcav/ping_stabilizer');
  static const _events = EventChannel('torcav/ping_stabilizer/stats');

  // Single underlying EventChannel subscription, fanned out to two
  // broadcast streams: jitter samples and tunnel-lifecycle events.
  StreamSubscription? _eventSub;
  final StreamController<JitterSample> _samplesCtrl =
      StreamController.broadcast();
  final StreamController<void> _stoppedCtrl = StreamController.broadcast();

  Future<bool> isPrepared() async {
    try {
      final ok = await _method.invokeMethod<bool>('isPrepared');
      return ok ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> requestPermission() async {
    try {
      final ok = await _method.invokeMethod<bool>('prepare');
      return ok ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> start(StabilizationProfile profile) async {
    try {
      final ok = await _method.invokeMethod<bool>('start', {
        'id': profile.id,
        'displayName': profile.displayName,
        'gameKey': profile.gameKey,
        'qosRules': profile.qosRules.map((r) => r.toMap()).toList(),
        'dualInterface': profile.dualInterface,
      });
      return ok ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _method.invokeMethod<void>('stop');
    } on PlatformException {
      // Best effort — service may already be torn down.
    } on MissingPluginException {
      // No native impl on this platform.
    }
  }

  Future<void> setDns(String ip) async {
    try {
      await _method.invokeMethod<void>('setDns', {'ip': ip});
    } on PlatformException {
      // Ignored: surfaced as repo Failure upstream when needed.
    } on MissingPluginException {
      // No native impl.
    }
  }

  Future<List<DnsCandidate>> benchmarkDns(List<DnsCandidate> candidates) async {
    try {
      final raw = await _method.invokeMethod<List<dynamic>>('benchmarkDns', {
        'candidates':
            candidates.map((c) => {'ip': c.ip, 'label': c.label}).toList(),
      });
      if (raw == null) return candidates;
      return raw.whereType<Map>().map((m) {
        return DnsCandidate(
          ip: (m['ip'] as String?) ?? '',
          label: (m['label'] as String?) ?? '',
          lastRttMs: (m['rttMs'] as num?)?.toDouble(),
        );
      }).toList();
    } on PlatformException {
      return candidates;
    } on MissingPluginException {
      return candidates;
    }
  }

  Stream<JitterSample> samples() {
    _ensureListening();
    return _samplesCtrl.stream;
  }

  /// Fires when the native tunnel tears down — including via the
  /// notification "Stop" action or the system VPN revoke flow. The Cubit
  /// listens to this so the UI returns to idle without the user having to
  /// re-open the app and toggle off.
  Stream<void> tunnelStopped() {
    _ensureListening();
    return _stoppedCtrl.stream;
  }

  void _ensureListening() {
    _eventSub ??= _events.receiveBroadcastStream().listen(
      (event) {
        final m = (event as Map?) ?? const {};
        if (m['stopped'] == true) {
          _stoppedCtrl.add(null);
          return;
        }
        _samplesCtrl.add(
          JitterSample(
            ts: DateTime.fromMillisecondsSinceEpoch(
              (m['tsMs'] as num?)?.toInt() ??
                  DateTime.now().millisecondsSinceEpoch,
            ),
            latencyMs: (m['latencyMs'] as num?)?.toDouble() ?? 0,
            jitterMs: (m['jitterMs'] as num?)?.toDouble() ?? 0,
            lossPct: (m['lossPct'] as num?)?.toDouble() ?? 0,
          ),
        );
      },
      onError: (_) {
        // Swallow — UI keeps last known sample.
      },
    );
  }
}
