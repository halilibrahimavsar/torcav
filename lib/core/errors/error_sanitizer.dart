import 'package:flutter/foundation.dart';
import 'package:torcav/core/errors/failures.dart';
import 'package:torcav/core/l10n/app_localizations.dart';

/// Raw [Object]/[Failure] hatalarını kullanıcıya gösterilebilir mesaja
/// dönüştürür. Stack trace, dosya yolu, `Exception:` prefix gibi developer
/// noise temizlenir; release modda bilinmeyen hatalar generic mesaja düşer
/// (PII / debug detay sızıntısını önler).
class ErrorSanitizer {
  ErrorSanitizer._();

  /// Failure subtype'larını known kategorilere maple; bilinmeyen
  /// exception'lar için release'de generic, debug'da kısa repr döner.
  static String sanitize(Object error, {AppLocalizations? l10n}) {
    if (error is Failure) return _sanitizeFailure(error, l10n);

    // Tanınmayan exception — release'de generic mesaj.
    if (kReleaseMode) {
      return l10n?.genericErrorMessage ?? 'Bir hata oluştu.';
    }

    // Debug: kısa, sanitize edilmiş repr ver.
    final raw = error.toString();
    return _truncate(
      raw
          .replaceAll(_pathPattern, '<path>')
          .replaceFirst(_exceptionPrefix, ''),
    );
  }

  static String _sanitizeFailure(Failure f, AppLocalizations? l10n) {
    final categoryMessage = switch (f) {
      PermissionFailure() => l10n?.permissionDeniedMessage,
      DatabaseFailure() || CacheFailure() => l10n?.storageErrorMessage,
      ScanFailure() || ServerFailure() => l10n?.networkErrorMessage,
      SecurityFailure() => l10n?.securityErrorMessage,
      _ => null,
    };
    // Kategori mesajı varsa onu döndür; yoksa Failure'ın kendi mesajını
    // (already kullanıcıya gösterilebilir formatta) sanitize edip dön.
    if (categoryMessage != null) return categoryMessage;
    return _truncate(f.message.replaceAll(_pathPattern, '<path>'));
  }

  /// Dosya yollarını silen regex — `/lib/foo/bar.dart` ya da
  /// `/home/user/.../baz.dart` gibi pattern'leri `<path>` ile değiştirir.
  static final RegExp _pathPattern = RegExp(r'(/[\w.\-]+)+\.dart');

  /// `Exception: ` / `_TypeError: ` gibi başlangıç prefix'lerini siler.
  static final RegExp _exceptionPrefix = RegExp(r'^_?\w+(?:Error|Exception):\s*');

  static String _truncate(String s, [int max = 150]) =>
      s.length <= max ? s : '${s.substring(0, max - 3)}...';
}
