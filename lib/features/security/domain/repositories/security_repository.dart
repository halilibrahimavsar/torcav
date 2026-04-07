import '../entities/assessment_session.dart';
import '../entities/known_network.dart';
import '../entities/security_event.dart';
import '../entities/trusted_network_profile.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

abstract class SecurityRepository {
  Future<List<KnownNetwork>> getKnownNetworks();
  /// Saves a network as known (historical record), but does NOT implicitly trust it.
  Future<void> saveKnownNetwork(KnownNetwork network);

  Future<void> deleteKnownNetwork(String bssid);

  Future<List<TrustedNetworkProfile>> getTrustedNetworkProfiles();

  /// Explicitly adds a network to the trusted baseline for fingerprint-and-drift monitoring.
  Future<void> trustNetwork(WifiNetwork network);

  Future<void> saveTrustedNetworkProfile(TrustedNetworkProfile profile);

  Future<void> deleteTrustedNetworkProfile(String bssid);
  Future<List<SecurityEvent>> getSecurityEvents();
  Future<void> saveSecurityEvent(SecurityEvent event);
  Future<void> saveSecurityEvents(List<SecurityEvent> events);
  Future<void> markSecurityEventAsRead(int id);
  Future<void> markAllSecurityEventsAsRead();
  Future<void> clearAllSecurityEvents();
  Future<AssessmentSession?> getLatestAssessmentSession();
  Future<void> saveAssessmentSession(AssessmentSession session);

  /// Compares current scan results with known networks to identify Rogue APs.
  Future<List<SecurityEvent>> analyzeNetworks(List<WifiNetwork> networks);

  Future<void> incrementSeenCount(String bssid);
}
