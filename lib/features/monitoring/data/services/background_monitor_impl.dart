import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/l10n/locale_cubit.dart';
import '../../domain/services/background_monitor.dart';

/// Platform-channel-backed [BackgroundMonitor]. Android schedules a
/// WorkManager periodic worker (see `MonitoringWorker.kt`); iOS schedules a
/// `BGAppRefreshTask`. Other platforms are no-ops.
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
        // The worker fires with no Dart isolate around, so it can't ask us
        // for translations at notification time — ship them up-front in the
        // user's in-app language. `{from}`/`{to}` are substituted natively.
        'strings': _notificationStrings(),
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

  Map<String, String> _notificationStrings() {
    final l10n = lookupAppLocalizations(getIt<LocaleCubit>().state);
    return {
      'channelName': l10n.monitorChannelName,
      'channelDesc': l10n.monitorChannelDesc,
      'bssidChangedTitle': l10n.monitorBssidChangedTitle,
      'bssidChangedBody': l10n.monitorBssidChangedBody,
      'envChangedTitle': l10n.monitorEnvironmentChangedTitle,
      'envChangedBody': l10n.monitorEnvironmentChangedBody('{from}', '{to}'),
    };
  }
}
