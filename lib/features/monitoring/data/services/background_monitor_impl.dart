import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../domain/services/background_monitor.dart';

/// Platform-channel-backed [BackgroundMonitor]. Android calls
/// `MonitoringService.start/stop` (see `MonitoringService.kt`); iOS
/// schedules a `BGAppRefreshTask`. Other platforms are no-ops.
@LazySingleton(as: BackgroundMonitor)
class BackgroundMonitorImpl implements BackgroundMonitor {
  static const _channel = MethodChannel('torcav/background_monitor');

  @override
  Future<bool> start({
    Duration tickInterval = const Duration(minutes: 30),
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('start', {
        'tickMs': tickInterval.inMilliseconds,
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
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('stop');
      return ok ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
