import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:torcav/core/logging/app_logger.dart';
import 'package:torcav/core/notifications/app_notifier.dart';
import 'package:torcav/core/notifications/notification_severity.dart';
import 'package:torcav/features/ping_stabilizer/data/datasources/ping_stabilizer_channel.dart';

/// Uygulama ön plandayken native uyarı motorlarının (MonitoringWorker,
/// StabilizerAlertEngine) sistem bildirimi yerine gönderdiği in-app
/// event'leri dinler ve [AppNotifier] snackbar'ı olarak gösterir.
///
/// Başlık/gövde/aksiyon etiketi native tarafa Dart'tan itilen lokalize
/// string şablonlarından gelir — burada yeniden çeviri yapılmaz. Uygulama
/// arka plandayken native taraf bugünkü gibi sistem bildirimi atar; bu
/// dinleyici o yolu hiç görmez (bkz. InAppAlertBridge.kt).
@lazySingleton
class InAppAlertListener {
  InAppAlertListener(this._stabilizer);

  static const _events = EventChannel('torcav/in_app_alerts');

  final PingStabilizerChannel _stabilizer;
  StreamSubscription<dynamic>? _sub;

  void start() {
    _sub ??= _events.receiveBroadcastStream().listen(
      _onAlert,
      // Android dışı platformlarda kanal yok — sessizce devre dışı kal.
      onError: (Object e) => AppLogger.w('In-app alert stream error: $e'),
    );
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }

  void _onAlert(dynamic event) {
    if (event is! Map) return;
    final title = event['title'] as String? ?? '';
    final body = event['body'] as String? ?? '';
    if (title.isEmpty && body.isEmpty) return;

    final severity = switch (event['severity'] as String?) {
      'info' => NotificationSeverity.info,
      'error' => NotificationSeverity.error,
      _ => NotificationSeverity.warning,
    };

    SnackBarAction? action;
    if (event['action'] == 'cycleTunnel') {
      final label = event['actionLabel'] as String? ?? '';
      if (label.isNotEmpty) {
        action = SnackBarAction(
          label: label,
          textColor: Colors.white,
          onPressed: () => unawaited(_stabilizer.cycle()),
        );
      }
    }

    AppNotifier.show(
      [title, body].where((s) => s.isNotEmpty).join('\n'),
      severity: severity,
      // Bildirim yerine geçiyor + aksiyon içerebiliyor: okunacak kadar kalsın.
      duration: const Duration(seconds: 6),
      action: action,
    );
  }
}
