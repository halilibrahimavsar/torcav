import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:torcav/features/security/domain/entities/security_event.dart';
import 'package:torcav/features/security/domain/services/captive_portal_detector.dart';

class _MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late _MockNetworkInfo networkInfo;

  setUp(() {
    networkInfo = _MockNetworkInfo();
    when(() => networkInfo.getWifiName()).thenAnswer((_) async => '"CafeNet"');
    when(
      () => networkInfo.getWifiBSSID(),
    ).thenAnswer((_) async => 'aa:bb:cc:dd:ee:ff');
  });

  CaptivePortalDetector detector(Future<int?> Function() probe) =>
      CaptivePortalDetector.withProbe(networkInfo, probe);

  test('204 means the network is clean', () async {
    final result = await detector(() async => 204).check();

    expect(result.status, CaptivePortalStatus.clean);
    expect(result.event, isNull);
  });

  test('a redirect means a portal is intercepting traffic', () async {
    final result = await detector(() async => 302).check();

    expect(result.status, CaptivePortalStatus.detected);
    expect(result.event, isNotNull);
    expect(result.event!.type, SecurityEventType.captivePortalDetected);
    expect(result.event!.evidence, contains('302'));
  });

  test('the SSID is unquoted and the BSSID upper-cased for the event', () async {
    final result = await detector(() async => 200).check();

    expect(result.event!.ssid, 'CafeNet');
    expect(result.event!.bssid, 'AA:BB:CC:DD:EE:FF');
  });

  // The distinction the three-state result exists for: a probe that could not
  // run tells us nothing, and must not be reported as "no portal".
  test('no answer is unknown, not clean', () async {
    final result = await detector(() async => null).check();

    expect(result.status, CaptivePortalStatus.unknown);
    expect(result.event, isNull);
  });

  test('a throwing probe is unknown, not clean', () async {
    final result = await detector(() async => throw Exception('offline')).check();

    expect(result.status, CaptivePortalStatus.unknown);
  });

  test('event is non-null exactly when a portal was detected', () async {
    for (final code in [204, 302, 200, 511, null]) {
      final result = await detector(() async => code).check();
      expect(
        result.event != null,
        result.status == CaptivePortalStatus.detected,
        reason: 'contract broken for status code $code',
      );
    }
  });
}
