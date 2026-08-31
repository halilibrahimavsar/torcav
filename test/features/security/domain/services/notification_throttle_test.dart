import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/security/domain/entities/security_event.dart';
import 'package:torcav/features/security/domain/services/notification_throttle.dart';

/// Without throttling, a network that keeps failing the same check alerts on
/// every scan tick — which trains the user to swipe security alerts away
/// without reading them.
void main() {
  late NotificationThrottle throttle;
  final t0 = DateTime(2026, 8, 31, 12);

  setUp(() => throttle = NotificationThrottle());

  test('the first alert for a finding is allowed', () {
    expect(
      throttle.allow(SecurityEventType.deauthBurstDetected, 'AA:BB', t0),
      isTrue,
    );
  });

  test('a repeat inside the cooldown is suppressed', () {
    throttle.allow(SecurityEventType.deauthBurstDetected, 'AA:BB', t0);

    expect(
      throttle.allow(
        SecurityEventType.deauthBurstDetected,
        'AA:BB',
        t0.add(const Duration(minutes: 14, seconds: 59)),
      ),
      isFalse,
    );
  });

  test('a repeat after the cooldown is allowed again', () {
    throttle.allow(SecurityEventType.deauthBurstDetected, 'AA:BB', t0);

    expect(
      throttle.allow(
        SecurityEventType.deauthBurstDetected,
        'AA:BB',
        t0.add(NotificationThrottle.cooldown),
      ),
      isTrue,
    );
  });

  test('the same problem on a different network is news', () {
    throttle.allow(SecurityEventType.deauthBurstDetected, 'AA:BB', t0);

    expect(
      throttle.allow(SecurityEventType.deauthBurstDetected, 'CC:DD', t0),
      isTrue,
    );
  });

  test('a different problem on the same network is news', () {
    throttle.allow(SecurityEventType.deauthBurstDetected, 'AA:BB', t0);

    expect(
      throttle.allow(SecurityEventType.evilTwinDetected, 'AA:BB', t0),
      isTrue,
    );
  });

  test('BSSID casing does not create a second channel', () {
    throttle.allow(SecurityEventType.deauthBurstDetected, 'aa:bb', t0);

    expect(
      throttle.allow(SecurityEventType.deauthBurstDetected, 'AA:BB', t0),
      isFalse,
    );
  });

  test('two calls in the same instant do not both pass', () {
    expect(throttle.allow(SecurityEventType.evilTwinDetected, 'AA:BB', t0), isTrue);
    expect(throttle.allow(SecurityEventType.evilTwinDetected, 'AA:BB', t0), isFalse);
  });

  test('reset lets a dismissed finding alert again', () {
    throttle.allow(SecurityEventType.evilTwinDetected, 'AA:BB', t0);
    throttle.reset();

    expect(
      throttle.allow(SecurityEventType.evilTwinDetected, 'AA:BB', t0),
      isTrue,
    );
  });
}
