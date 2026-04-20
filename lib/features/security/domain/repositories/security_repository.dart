import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/assessment_session.dart';
import '../entities/known_network.dart';
import '../entities/security_event.dart';
import '../entities/trusted_network_profile.dart';
import '../entities/security_assessment.dart';
import '../entities/vulnerable_router.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

abstract class SecurityRepository {
  Future<Either<Failure, List<KnownNetwork>>> getKnownNetworks();

  /// Saves a network as known (historical record), but does NOT implicitly trust it.
  Future<Either<Failure, void>> saveKnownNetwork(KnownNetwork network);

  Future<Either<Failure, void>> deleteKnownNetwork(String bssid);

  Future<Either<Failure, List<TrustedNetworkProfile>>>
  getTrustedNetworkProfiles();

  /// Explicitly adds a network to the trusted baseline for fingerprint-and-drift monitoring.
  Future<Either<Failure, void>> trustNetwork(WifiNetwork network);

  Future<Either<Failure, void>> saveTrustedNetworkProfile(
    TrustedNetworkProfile profile,
  );

  Future<Either<Failure, void>> deleteTrustedNetworkProfile(String bssid);

  Future<Either<Failure, List<SecurityEvent>>> getSecurityEvents();

  Future<Either<Failure, void>> saveSecurityEvent(SecurityEvent event);

  Future<Either<Failure, void>> saveSecurityEvents(List<SecurityEvent> events);

  Future<Either<Failure, void>> markSecurityEventAsRead(int id);

  Future<Either<Failure, void>> markAllSecurityEventsAsRead();

  Future<Either<Failure, void>> deleteSecurityEvent(int id);

  Future<Either<Failure, void>> clearAllSecurityEvents();

  Future<Either<Failure, AssessmentSession?>> getLatestAssessmentSession();

  Future<Either<Failure, void>> saveAssessmentSession(
    AssessmentSession session,
  );

  /// Compares current scan results with known networks to identify Rogue APs.
  Future<Either<Failure, List<SecurityEvent>>> analyzeNetworks(
    List<WifiNetwork> networks, {
    bool isDeepScan = false,
  });

  /// Performs a full security assessment of a single network, including hardware vulnerability checks.
  Future<Either<Failure, SecurityAssessment>> analyzeNetwork(
    WifiNetwork network, {
    List<WifiNetwork> localBaseline = const [],
    TrustedNetworkProfile? trustedProfile,
    bool isDeepScan = false,
  });

  Future<Either<Failure, void>> incrementSeenCount(String bssid);

  /// Matches a BSSID against known hardware vulnerabilities.
  Future<Either<Failure, List<VulnerableRouter>>> findVulnerabilities(
    String bssid,
  );
}
