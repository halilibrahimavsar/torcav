import 'package:injectable/injectable.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/oui_lookup.dart';
import '../datasources/security_local_data_source.dart';
import '../../domain/entities/known_network.dart';
import '../../domain/entities/security_event.dart';
import '../../domain/repositories/security_repository.dart';
import 'package:torcav/features/wifi_scan/domain/entities/wifi_network.dart';

@LazySingleton(as: SecurityRepository)
class SecurityRepositoryImpl implements SecurityRepository {
  final SecurityLocalDataSource _localDataSource;
  final NotificationService _notificationService;

  SecurityRepositoryImpl(this._localDataSource, this._notificationService);

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
  Future<void> markSecurityEventAsRead(int id) =>
      _localDataSource.markSecurityEventAsRead(id);

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

        // 2. Randomized MAC Detection (Suspicious for fixed APs)
        if (OuiLookup.isSuspicious(network.bssid)) {
          isRogue = true;
          evidence += ' Randomized/LAA MAC detected on known network! This is highly unusual for legitimate Access Points.';
        }

        // 3. Security Downgrade check
        if (known.security != network.security.toString()) {
          isRogue = true;
          evidence +=
              ' Security profile changed! Expected: ${known.security}, Found: ${network.security}.';
        }

        if (isRogue) {
          final event = SecurityEvent(
            type: SecurityEventType.rogueApSuspected,
            severity: SecurityEventSeverity.critical,
            ssid: network.ssid,
            bssid: network.bssid,
            timestamp: DateTime.now(),
            evidence: evidence,
          );
          alerts.add(event);
          // Trigger local notification
          await _notificationService.showSecurityAlert(event);
        }
      }
    }

    if (alerts.isNotEmpty) {
      await saveSecurityEvents(alerts);
    }

    return alerts;
  }
}
