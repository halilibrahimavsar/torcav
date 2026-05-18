import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torcav/core/errors/error_sanitizer.dart';
import 'package:torcav/core/logging/app_logger.dart';
import 'package:torcav/core/notifications/app_notifier.dart';

/// Tüm BLoC/Cubit'ler için merkezi gözlemci. `onError`, handler içinde
/// yakalanmamış (unexpected) throw'ları yakalar; AppLogger'a tam stack ile
/// yazar ve kullanıcıya sanitize edilmiş snackbar gösterir.
///
/// Beklenen failure path'leri zaten BLoC'ların kendi try-catch'i + emit
/// error state pattern'iyle ele alınır — bu observer son güvenlik ağı.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.e(
      'Unhandled error in ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
    // Localization context yok — sanitize generic mesaja düşer (release)
    // veya kısa repr verir (debug). Kategori-mesajı için BlocListener
    // bazlı page-level handler tercih edilir.
    AppNotifier.error(ErrorSanitizer.sanitize(error));
    super.onError(bloc, error, stackTrace);
  }
}
