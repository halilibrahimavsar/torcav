import 'package:injectable/injectable.dart';

import '../entities/security_event.dart';

/// Rate-limits repeat notifications for the same finding on the same network.
///
/// Without it, a network that keeps failing the same check produces a
/// notification on every scan tick — which is how a security app trains its
/// user to swipe its alerts away without reading them.
///
/// Keyed by event type *and* BSSID: the same problem on a different network is
/// news, the same problem on the same network is not.
@lazySingleton
class NotificationThrottle {
  NotificationThrottle();

  /// How long the same finding stays quiet on the same network.
  static const cooldown = Duration(minutes: 15);

  final Map<String, DateTime> _lastNotifiedAt = {};

  /// Whether this finding may notify now. Records the time when it may, so
  /// two calls in the same instant do not both pass.
  bool allow(SecurityEventType type, String bssid, DateTime now) {
    final key = '${type.name}:${bssid.toLowerCase()}';
    final last = _lastNotifiedAt[key];
    if (last != null && now.difference(last) < cooldown) return false;
    _lastNotifiedAt[key] = now;
    return true;
  }

  /// Forgets all history. Used when the user clears their event log, so a
  /// finding they just dismissed can alert again if it recurs.
  void reset() => _lastNotifiedAt.clear();
}
