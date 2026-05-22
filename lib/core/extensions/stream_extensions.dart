import 'dart:async';

/// Extensions on [Stream] to provide null-safe access to elements.
extension StreamX<T> on Stream<T> {
  /// Returns the last element of the stream, or `null` if the stream is empty.
  ///
  /// This is a safer alternative to [Stream.last] which throws a [StateError]
  /// if the stream contains no elements.
  Future<T?> get lastOrNull async {
    T? lastValue;
    bool found = false;
    await for (final value in this) {
      lastValue = value;
      found = true;
    }
    return found ? lastValue : null;
  }
}
