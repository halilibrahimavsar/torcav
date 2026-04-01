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
  Future<void> deleteKnownNetwork(String bssid) =>
      _localDataSource.deleteKnownNetwork(bssid);

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

      final known =
          knownNetworks.where((kn) => kn.ssid == network.ssid).firstOrNull;

      if (known != null) {
        // 1. Evil Twin detection (BSSID mismatch for same SSID)
        if (known.bssid != network.bssid) {
          final event = SecurityEvent(
            type: SecurityEventType.evilTwinDetected,
            severity: SecurityEventSeverity.critical,
            ssid: network.ssid,
            bssid: network.bssid,
            timestamp: DateTime.now(),
            evidence:
                'BSSID mismatch! Expected: ${known.bssid}, Found: ${network.bssid}. High probability of an Evil Twin Access Point.',
          );
          alerts.add(event);
          await _notificationService.showSecurityAlert(event);
        }
        // 2. Randomized MAC Detection (Suspicious for fixed APs)
        else if (OuiLookup.isSuspicious(network.bssid)) {
          final event = SecurityEvent(
            type: SecurityEventType.rogueApSuspected,
            severity: SecurityEventSeverity.high,
            ssid: network.ssid,
            bssid: network.bssid,
            timestamp: DateTime.now(),
            evidence:
                'Randomized/LAA MAC detected on known network! This is highly unusual for legitimate Access Points and may indicate a rogue device.',
          );
          alerts.add(event);
          await _notificationService.showSecurityAlert(event);
        }

        // 3. Security Downgrade check
        if (known.security != network.security.toString()) {
          final isDowngrade = _isDowngrade(
            known.security,
            network.security.toString(),
          );
          final event = SecurityEvent(
            type: SecurityEventType.encryptionDowngraded,
            severity:
                isDowngrade
                    ? SecurityEventSeverity.high
                    : SecurityEventSeverity.medium,
            ssid: network.ssid,
            bssid: network.bssid,
            timestamp: DateTime.now(),
            evidence:
                'Encryption profile changed from ${known.security} to ${network.security}. Possible downgrade attack.',
          );
          alerts.add(event);
          await _notificationService.showSecurityAlert(event);
        }
      }
    }

    if (alerts.isNotEmpty) {
      await saveSecurityEvents(alerts);
    }

    return alerts;
  }

  bool _isDowngrade(String oldSecurity, String newSecurity) {
    final oldRank = _getSecurityRank(oldSecurity);
    final newRank = _getSecurityRank(newSecurity);
    return newRank < oldRank;
  }

  int _getSecurityRank(String security) {
    final s = security.toLowerCase();
    if (s.contains('wpa3')) return 5;
    if (s.contains('wpa2')) return 4;
    if (s.contains('wpa')) return 3;
    if (s.contains('wep')) return 2;
    if (s.contains('open')) return 1;
    return 0;
  }
}
