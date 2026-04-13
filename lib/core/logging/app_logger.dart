import 'dart:developer';

/// A simple logging wrapper as required by the project rules.
class AppLogger {
  const AppLogger._();

  static void d(String message) {
    log('DEBUG: $message');
  }

  static void i(String message) {
    log('INFO: $message');
  }

  static void w(String message) {
    log('WARNING: $message');
  }

  static void e(String message, {Object? error, StackTrace? stackTrace}) {
    log('ERROR: $message', error: error, stackTrace: stackTrace);
  }
}
