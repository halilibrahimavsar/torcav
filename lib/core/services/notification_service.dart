import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../../features/security/domain/entities/security_event.dart';

@lazySingleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> showSecurityAlert(SecurityEvent event) async {
    if (!_initialized) await initialize();

    final title = _getTitleForEvent(event.type);
    final body =
        event.evidence.isNotEmpty
            ? event.evidence
            : '${event.ssid} (${event.bssid})';

    await _plugin.show(
      event.hashCode,
      title,
      body,
      _buildNotificationDetails(event.severity),
      payload: '${event.type.name}|${event.bssid}',
    );
  }

  Future<void> showScanComplete(int networkCount, Duration duration) async {
    if (!_initialized) await initialize();

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Scan Complete',
      'Found $networkCount networks in ${duration.inSeconds}s',
      _buildNotificationDetails(SecurityEventSeverity.info),
    );
  }

  Future<void> showAttackDetected(String attackType, String details) async {
    if (!_initialized) await initialize();

    await _plugin.show(
      999999,
      '⚠️ Attack Detected: $attackType',
      details,
      _buildNotificationDetails(SecurityEventSeverity.critical),
    );
  }

  NotificationDetails _buildNotificationDetails(
    SecurityEventSeverity severity,
  ) {
    final channelId = switch (severity) {
      SecurityEventSeverity.critical => 'security_critical',
      SecurityEventSeverity.high => 'security_high',
      SecurityEventSeverity.warning => 'security_warning',
      SecurityEventSeverity.info => 'security_info',
    };

    final channelName = switch (severity) {
      SecurityEventSeverity.critical => 'Critical Alerts',
      SecurityEventSeverity.high => 'High Priority',
      SecurityEventSeverity.warning => 'Warnings',
      SecurityEventSeverity.info => 'Information',
    };

    final importance = switch (severity) {
      SecurityEventSeverity.critical => Importance.max,
      SecurityEventSeverity.high => Importance.high,
      SecurityEventSeverity.warning => Importance.defaultImportance,
      SecurityEventSeverity.info => Importance.low,
    };

    final priority = switch (severity) {
      SecurityEventSeverity.critical => Priority.max,
      SecurityEventSeverity.high => Priority.high,
      SecurityEventSeverity.warning => Priority.defaultPriority,
      SecurityEventSeverity.info => Priority.low,
    };

    final color = switch (severity) {
      SecurityEventSeverity.critical => const Color(0xFFFF0000),
      SecurityEventSeverity.high => const Color(0xFFFF6B6B),
      SecurityEventSeverity.warning => const Color(0xFFFFAB40),
      SecurityEventSeverity.info => const Color(0xFF32E6A1),
    };

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Security alert notifications',
        importance: importance,
        priority: priority,
        color: color,
        enableVibration: severity != SecurityEventSeverity.info,
        playSound: true,
        icon: '@mipmap/ic_launcher',
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
    );
  }

  String _getTitleForEvent(SecurityEventType type) {
    return switch (type) {
      SecurityEventType.rogueApSuspected => '🚨 Rogue AP Detected',
      SecurityEventType.deauthBurstDetected => '⚡ Deauth Attack Detected',
      SecurityEventType.handshakeCaptureStarted =>
        '🔐 Handshake Capture Started',
      SecurityEventType.handshakeCaptureCompleted => '✅ Handshake Captured',
      SecurityEventType.captivePortalDetected => '🌐 Captive Portal Detected',
      SecurityEventType.unsupportedOperation => '⚠️ Operation Not Supported',
    };
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return _plugin.pendingNotificationRequests();
  }
}
