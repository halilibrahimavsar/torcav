import '../entities/known_network.dart';
import '../entities/security_event.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

abstract class SecurityRepository {
  Future<List<KnownNetwork>> getKnownNetworks();
  Future<void> saveKnownNetwork(KnownNetwork network);
  Future<void> deleteKnownNetwork(String bssid);
  Future<List<SecurityEvent>> getSecurityEvents();
  Future<void> saveSecurityEvent(SecurityEvent event);
  Future<void> saveSecurityEvents(List<SecurityEvent> events);
  Future<void> markSecurityEventAsRead(int id);
  Future<void> markAllSecurityEventsAsRead();
  Future<void> clearAllSecurityEvents();

  /// Compares current scan results with known networks to identify Rogue APs.
  Future<List<SecurityEvent>> analyzeNetworks(List<WifiNetwork> networks);
}
