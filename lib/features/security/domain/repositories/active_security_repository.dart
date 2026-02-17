import '../entities/security_event.dart';

abstract class ActiveSecurityRepository {
  Future<SecurityEvent> captureHandshake({
    required String ssid,
    required String bssid,
    required int channel,
    required String interfaceName,
  });

  Future<SecurityEvent> runActiveDefenseCheck({
    required String ssid,
    required String bssid,
    required String interfaceName,
  });
}
