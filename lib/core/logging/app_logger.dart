import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Lightweight logging wrapper.
///
/// In release builds, only [e] (errors) actually emit output. Verbose levels
/// ([d], [i], [w]) are compiled out to avoid leaking debug context — including
/// file paths, IDs, and other potential PII — into shipped binaries.
class AppLogger {
  const AppLogger._();

  static void d(String message) {
    if (kReleaseMode) return;
    developer.log('DEBUG: $message');
  }

  static void i(String message) {
    if (kReleaseMode) return;
    developer.log('INFO: $message');
  }

  static void w(String message) {
    if (kReleaseMode) return;
    developer.log('WARNING: $message');
  }

  static void e(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log('ERROR: $message', error: error, stackTrace: stackTrace);
  }
}
