import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../../features/security/domain/entities/security_event.dart';
import '../l10n/app_localizations.dart';
import '../l10n/locale_cubit.dart';
import '../l10n/security_localization_helper.dart';
import '../logging/app_logger.dart';
import '../di/injection.dart';

bool get defaultTargetPlatformIsAndroid =>
    defaultTargetPlatform == TargetPlatform.android;

@lazySingleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    // Monochrome status icon: @mipmap/ic_launcher was still the stock
    // Flutter template art (the real launcher icon is @mipmap/launcher_icon)
    // and full-color bitmaps render as a flat square in the status bar.
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_stat_torcav',
    );
    const iosSettings = DarwinInitializationSettings();
    final linuxSettings = LinuxInitializationSettings(
      defaultActionName: _l10n.notificationOpenAction,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    _initialized = true;
  }

  /// Requests the Android 13+ `POST_NOTIFICATIONS` runtime permission.
  /// On older Android, iOS and other platforms this is a no-op that resolves
  /// to `true`. Call this AFTER showing a prominent disclosure to the user
  /// (per Google Play notification policy).
  Future<bool> requestAndroidNotificationPermission() async {
    if (!_initialized) await initialize();
    if (kIsWeb || !defaultTargetPlatformIsAndroid) return true;
    final granted =
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
    return granted ?? false;
  }

  void _onNotificationTapped(NotificationResponse response) {
    AppLogger.d('Notification tapped: ${response.payload}');
  }

  AppLocalizations get _l10n =>
      lookupAppLocalizations(getIt<LocaleCubit>().state);

  Future<void> showSecurityAlert(SecurityEvent event) async {
    if (!_initialized) await initialize();

    final title = _getTitleForEvent(event.type);
    final body =
        event.evidence.isNotEmpty
            ? SecurityLocalizationHelper.translateEvidence(
              _l10n,
              event.evidence,
            )
            : '${event.ssid} (${event.bssid})';

    await _plugin.show(
      event.hashCode,
      title,
      body,
      _buildNotificationDetails(event.severity),
      payload: '${event.type.name}|${event.bssid}',
    );
  }

  // Recommendation alerts (Ping Stabilizer, spectrum quality) intentionally
  // have no Dart-side notification path: stabilizer alerts are posted by the
  // native StabilizerAlertEngine so they keep firing after this isolate is
  // killed, and live pages surface their advice in-app instead.

  NotificationDetails _buildNotificationDetails(
    SecurityEventSeverity severity,
  ) {
    final channelId = switch (severity) {
      SecurityEventSeverity.critical => 'security_critical',
      SecurityEventSeverity.high => 'security_high',
      SecurityEventSeverity.medium => 'security_medium',
      SecurityEventSeverity.warning => 'security_warning',
      SecurityEventSeverity.low => 'security_low',
      SecurityEventSeverity.info => 'security_info',
    };

    final channelName = switch (severity) {
      SecurityEventSeverity.critical =>
        _l10n.notificationChannelSecurityCritical,
      SecurityEventSeverity.high => _l10n.notificationChannelSecurityHigh,
      SecurityEventSeverity.medium => _l10n.notificationChannelSecurityMedium,
      SecurityEventSeverity.warning => _l10n.notificationChannelSecurityWarning,
      SecurityEventSeverity.low => _l10n.notificationChannelSecurityLow,
      SecurityEventSeverity.info => _l10n.notificationChannelSecurityInfo,
    };

    final importance = switch (severity) {
      SecurityEventSeverity.critical => Importance.max,
      SecurityEventSeverity.high => Importance.high,
      SecurityEventSeverity.medium => Importance.defaultImportance,
      SecurityEventSeverity.warning => Importance.defaultImportance,
      SecurityEventSeverity.low => Importance.low,
      SecurityEventSeverity.info => Importance.low,
    };

    final priority = switch (severity) {
      SecurityEventSeverity.critical => Priority.max,
      SecurityEventSeverity.high => Priority.high,
      SecurityEventSeverity.medium => Priority.defaultPriority,
      SecurityEventSeverity.warning => Priority.defaultPriority,
      SecurityEventSeverity.low => Priority.low,
      SecurityEventSeverity.info => Priority.low,
    };

    final color = switch (severity) {
      SecurityEventSeverity.critical => const Color(0xFFFF0000),
      SecurityEventSeverity.high => const Color(0xFFFF6B6B),
      SecurityEventSeverity.medium => const Color(0xFF00E5FF),
      SecurityEventSeverity.warning => const Color(0xFFFFAB40),
      SecurityEventSeverity.low => const Color(0xFF32E6A1),
      SecurityEventSeverity.info => const Color(0xFF32E6A1),
    };

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: _l10n.notificationChannelSecurityDescription,
        importance: importance,
        priority: priority,
        color: color,
        enableVibration: severity != SecurityEventSeverity.info,
        icon: '@drawable/ic_stat_torcav',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: switch (severity) {
          SecurityEventSeverity.critical => InterruptionLevel.critical,
          SecurityEventSeverity.high => InterruptionLevel.timeSensitive,
          _ => InterruptionLevel.active,
        },
      ),
      linux: LinuxNotificationDetails(
        urgency: switch (severity) {
          SecurityEventSeverity.critical => LinuxNotificationUrgency.critical,
          SecurityEventSeverity.high => LinuxNotificationUrgency.critical,
          SecurityEventSeverity.medium => LinuxNotificationUrgency.normal,
          SecurityEventSeverity.warning => LinuxNotificationUrgency.normal,
          SecurityEventSeverity.low => LinuxNotificationUrgency.low,
          SecurityEventSeverity.info => LinuxNotificationUrgency.low,
        },
      ),
    );
  }

  String _getTitleForEvent(SecurityEventType type) {
    return _l10n.securityEventType(type.name);
  }
}
