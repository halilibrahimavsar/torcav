import 'package:flutter/material.dart';
import 'package:torcav/core/errors/error_sanitizer.dart';
import 'package:torcav/core/extensions/context_extensions.dart';
import 'package:torcav/core/notifications/app_notifier.dart';

/// Sayfa/widget'lerde `context.showError(...)` gibi ergonomik kısayollar.
/// Hepsi [AppNotifier]'a delege; context throttling ve l10n aware sanitize
/// için bir wrapper katmanı sağlar.
extension NotificationContextX on BuildContext {
  void showError(String message, {SnackBarAction? action}) =>
      AppNotifier.error(message, action: action);

  void showWarning(String message) => AppNotifier.warning(message);

  void showSuccess(String message) => AppNotifier.success(message);

  void showInfo(String message) => AppNotifier.info(message);

  /// Bir [Failure] veya exception'ı doğrudan göstermek için —
  /// [ErrorSanitizer] ile lokalize/sanitize edilmiş şekilde snackbar'lanır.
  void showFailure(Object failure) =>
      AppNotifier.error(ErrorSanitizer.sanitize(failure, l10n: l10n));
}
