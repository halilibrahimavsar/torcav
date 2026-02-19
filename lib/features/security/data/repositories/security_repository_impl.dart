import 'package:injectable/injectable.dart';
import '../datasources/security_local_data_source.dart';
import '../../domain/entities/known_network.dart';
import '../../domain/entities/security_event.dart';
import '../../domain/repositories/security_repository.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

@LazySingleton(as: SecurityRepository)
class SecurityRepositoryImpl implements SecurityRepository {
  final SecurityLocalDataSource _localDataSource;

  SecurityRepositoryImpl(this._localDataSource);

  @override
  Future<List<KnownNetwork>> getKnownNetworks() =>
      _localDataSource.getKnownNetworks();

  @override
  Future<void> saveKnownNetwork(KnownNetwork network) =>
      _localDataSource.saveKnownNetwork(network);

  @override
  Future<List<SecurityEvent>> getSecurityEvents() =>
      _localDataSource.getSecurityEvents();

  @override
  Future<void> saveSecurityEvent(SecurityEvent event) =>
      _localDataSource.saveSecurityEvent(event);

  @override
  Future<void> saveSecurityEvents(List<SecurityEvent> events) =>
      _localDataSource.saveSecurityEvents(events);

  @override
  Future<List<SecurityEvent>> analyzeNetworks(
    List<WifiNetwork> networks,
  ) async {
    final knownNetworks = await getKnownNetworks();
    final alerts = <SecurityEvent>[];

    for (final network in networks) {
      if (network.ssid.isEmpty) continue;

      final known = knownNetworks.cast<KnownNetwork?>().firstWhere(
        (kn) => kn?.ssid == network.ssid,
        orElse: () => null,
      );

      if (known != null) {
        // Rogue AP Detection Logic
        bool isRogue = false;
        String evidence = '';

        // 1. Different BSSID for same SSID (Evil Twin check)
        if (known.bssid != network.bssid) {
          isRogue = true;
          evidence =
              'BSSID mismatch! Expected: ${known.bssid}, Found: ${network.bssid}. Possible Evil Twin attack.';
        }

        // 2. Security Downgrade check
        // (Simple string comparison for now, can be improved with security level weights)
        if (known.security != network.security.toString()) {
          // If the current security is weaker than known, it's suspicious
          // For now, any change is flagged
          isRogue = true;
          evidence +=
              ' Security profile changed! Expected: ${known.security}, Found: ${network.security}.';
        }

        if (isRogue) {
          alerts.add(
            SecurityEvent(
              type: SecurityEventType.rogueApSuspected,
              severity: SecurityEventSeverity.critical,
              ssid: network.ssid,
              bssid: network.bssid,
              timestamp: DateTime.now(),
              evidence: evidence,
            ),
          );
        }
      }
    }

    if (alerts.isNotEmpty) {
      await saveSecurityEvents(alerts);
    }

    return alerts;
  }
}
