import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/speed_test_result.dart';
import '../../domain/services/scheduled_speed_probe.dart';

/// Platform-channel-backed [ScheduledSpeedProbe]. Android schedules a
/// WorkManager periodic worker (see `SpeedProbeWorker.kt`); other platforms
/// are no-ops.
@LazySingleton(as: ScheduledSpeedProbe)
class ScheduledSpeedProbeImpl implements ScheduledSpeedProbe {
  static const _channel = MethodChannel('torcav/speed_probe');

  @override
  Future<bool> start({Duration interval = const Duration(hours: 12)}) async {
    if (!Platform.isAndroid) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('start', {
        'intervalMs': interval.inMilliseconds,
      });
      return ok ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> stop() async {
    if (!Platform.isAndroid) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('stop');
      return ok ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<List<SpeedTestResult>> drain() async {
    if (!Platform.isAndroid) return const [];
    try {
      final raw = await _channel.invokeMethod<String>('drain');
      if (raw == null || raw.isEmpty) return const [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final entry in decoded)
          if (entry is Map)
            SpeedTestResult(
              recordedAt: DateTime.fromMillisecondsSinceEpoch(
                (entry['recordedAtMs'] as num?)?.toInt() ?? 0,
              ),
              latencyMs: (entry['latencyMs'] as num?)?.toDouble() ?? 0,
              jitterMs: 0,
              downloadMbps: (entry['downloadMbps'] as num?)?.toDouble() ?? 0,
              // The probe has no upload leg — 0 marks "not measured" and
              // consumers (evidence text, bento) skip zero uploads.
              uploadMbps: 0,
            ),
      ];
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    } on FormatException {
      return const [];
    }
  }
}
