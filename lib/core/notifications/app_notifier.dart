import 'package:flutter/material.dart';
import 'package:torcav/core/logging/app_logger.dart';
import 'package:torcav/core/notifications/notification_severity.dart';

/// Merkezi in-app snackbar/toast servisi. Mevcut 22 ad-hoc
/// `ScaffoldMessenger.of(context).showSnackBar(...)` çağrısının yerini alır;
/// styling, throttling ve `BuildContext`'siz kullanım (örn. [BlocObserver])
/// için tek geçit.
///
/// [messengerKey] `MaterialApp.scaffoldMessengerKey`'e bağlanır; mount
/// olmadan önce yapılan çağrılar sessizce loglanıp düşürülür.
class AppNotifier {
  AppNotifier._();

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Throttling: aynı (severity, message) son [_dedupeWindow] içinde
  // gösterildiyse yeni snackbar'ı atla. BlocObserver onError + state-emit
  // gibi çift-tetiklemelerde spam'i önler.
  static final Map<String, DateTime> _recent = <String, DateTime>{};
  static const Duration _dedupeWindow = Duration(seconds: 3);

  /// Düşük seviye API; severity ile birlikte snackbar gösterir.
  static void show(
    String message, {
    required NotificationSeverity severity,
    Duration? duration,
    SnackBarAction? action,
  }) {
    if (message.isEmpty) return;

    final key = '${severity.name}:$message';
    final now = DateTime.now();
    final last = _recent[key];
    if (last != null && now.difference(last) < _dedupeWindow) return;
    _recent[key] = now;
    _pruneRecent(now);

    final messenger = messengerKey.currentState;
    if (messenger == null) {
      // Erken bootstrap (runApp öncesi) veya teardown sırası — sessizce logla.
      AppLogger.w(
        'AppNotifier.show before messenger ready: [${severity.name}] $message',
      );
      return;
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: severity.backgroundColor(),
        duration: duration ?? severity.defaultDuration(),
        action: action,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(severity.icon(), color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: severity.textStyle())),
          ],
        ),
      ),
    );
  }

  static void error(String message, {SnackBarAction? action}) =>
      show(message, severity: NotificationSeverity.error, action: action);

  static void warning(String message) =>
      show(message, severity: NotificationSeverity.warning);

  static void success(String message) =>
      show(message, severity: NotificationSeverity.success);

  static void info(String message) =>
      show(message, severity: NotificationSeverity.info);

  // Throttling cache boyutunu sınırlı tut — _dedupeWindow dolmuş kayıtları
  // her show çağrısında temizle. Uzun ömürlü app session'larda
  // kontrol edilmeyen sözlük büyümesini önler.
  static void _pruneRecent(DateTime now) {
    if (_recent.length < 32) return;
    _recent.removeWhere(
      (_, ts) => now.difference(ts) > _dedupeWindow * 4,
    );
  }
}
