import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/features/security/domain/entities/network_fingerprint.dart';
import 'package:torcav/features/security/domain/entities/security_event.dart';
import 'package:torcav/features/security/domain/entities/trusted_network_profile.dart';
import 'package:torcav/features/security/domain/services/gateway_drift_detector.dart';

void main() {
  const detector = GatewayDriftDetector();

  TrustedNetworkProfile profile({String? gateway}) {
    return TrustedNetworkProfile(
      ssid: 'Home',
      bssid: 'AA:BB:CC:DD:EE:01',
      gateway: gateway,
      fingerprint: const NetworkFingerprint(
        ssid: 'Home',
        bssid: 'AA:BB:CC:DD:EE:01',
        security: '',
        vendor: '',
        isHidden: false,
        channel: 0,
        frequency: 0,
        bandLabel: '',
      ),
      trustedAt: DateTime(2025),
      lastConfirmedAt: DateTime(2025),
    );
  }

  test('returns null when no trusted profile is supplied', () {
    expect(
      detector.check(currentGateway: '192.168.1.1', trusted: null),
      isNull,
    );
  });

  test('returns null when trusted profile has no gateway baseline', () {
    expect(
      detector.check(currentGateway: '192.168.1.1', trusted: profile()),
      isNull,
    );
  });

  test('returns null when current gateway matches baseline', () {
    expect(
      detector.check(
        currentGateway: '192.168.1.1',
        trusted: profile(gateway: '192.168.1.1'),
      ),
      isNull,
    );
  });

  test('emits a high-severity event when gateway differs', () {
    final event = detector.check(
      currentGateway: '10.0.0.1',
      trusted: profile(gateway: '192.168.1.1'),
    );
    expect(event, isNotNull);
    expect(event!.type, SecurityEventType.evilTwinDetected);
    expect(event.severity, SecurityEventSeverity.high);
    expect(event.evidence, contains('192.168.1.1'));
    expect(event.evidence, contains('10.0.0.1'));
  });
}
