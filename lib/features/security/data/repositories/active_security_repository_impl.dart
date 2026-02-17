import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/services/privilege_service.dart';
import '../../../../core/services/process_runner.dart';
import '../../domain/entities/authorized_target.dart';
import '../../domain/entities/security_event.dart';
import '../../domain/repositories/active_security_repository.dart';
import '../../domain/services/consent_guard.dart';
import '../../domain/services/security_event_store.dart';

@LazySingleton(as: ActiveSecurityRepository)
class ActiveSecurityRepositoryImpl implements ActiveSecurityRepository {
  final ConsentGuard _consentGuard;
  final PrivilegeService _privilegeService;
  final ProcessRunner _processRunner;
  final SecurityEventStore _eventStore;

  ActiveSecurityRepositoryImpl(
    this._consentGuard,
    this._privilegeService,
    this._processRunner,
    this._eventStore,
  );

  @override
  Future<SecurityEvent> captureHandshake({
    required String ssid,
    required String bssid,
    required int channel,
    required String interfaceName,
  }) async {
    final denied = _consentGuard.validateActiveOperation(
      bssid: bssid,
      operation: AuthorizedOperation.handshakeCapture,
    );
    if (denied != null) {
      return _emit(
        SecurityEvent(
          type: SecurityEventType.unsupportedOperation,
          severity: SecurityEventSeverity.warning,
          ssid: ssid,
          bssid: bssid,
          timestamp: DateTime.now(),
          evidence: denied.message,
        ),
      );
    }

    if (!Platform.isLinux) {
      return _unsupportedEvent(
        ssid,
        bssid,
        'Active capture currently supports Linux only',
      );
    }

    final isRoot = await _privilegeService.isRoot();
    if (!isRoot) {
      return _unsupportedEvent(
        ssid,
        bssid,
        'Root privileges required for handshake capture',
      );
    }

    final result = await _processRunner.run('which', ['airodump-ng']);
    if (result.exitCode != 0) {
      return _unsupportedEvent(
        ssid,
        bssid,
        'aircrack-ng suite not found. Install `aircrack-ng`.',
      );
    }

    return _emit(
      SecurityEvent(
        type: SecurityEventType.handshakeCaptureStarted,
        severity: SecurityEventSeverity.info,
        ssid: ssid,
        bssid: bssid,
        timestamp: DateTime.now(),
        evidence:
            'Ready to capture on $interfaceName (ch $channel). '
            'Execution hook validated.',
      ),
    );
  }

  @override
  Future<SecurityEvent> runActiveDefenseCheck({
    required String ssid,
    required String bssid,
    required String interfaceName,
  }) async {
    final denied = _consentGuard.validateActiveOperation(
      bssid: bssid,
      operation: AuthorizedOperation.activeDefense,
    );
    if (denied != null) {
      return _emit(
        SecurityEvent(
          type: SecurityEventType.unsupportedOperation,
          severity: SecurityEventSeverity.warning,
          ssid: ssid,
          bssid: bssid,
          timestamp: DateTime.now(),
          evidence: denied.message,
        ),
      );
    }

    if (!Platform.isLinux) {
      return _unsupportedEvent(
        ssid,
        bssid,
        'Active defense check is Linux-only for now',
      );
    }

    final isRoot = await _privilegeService.isRoot();
    if (!isRoot) {
      return _unsupportedEvent(
        ssid,
        bssid,
        'Root privileges required for active defense',
      );
    }

    final result = await _processRunner.run('which', ['aireplay-ng']);
    if (result.exitCode != 0) {
      return _unsupportedEvent(
        ssid,
        bssid,
        'aireplay-ng not found. Install `aircrack-ng`.',
      );
    }

    return _emit(
      SecurityEvent(
        type: SecurityEventType.deauthBurstDetected,
        severity: SecurityEventSeverity.info,
        ssid: ssid,
        bssid: bssid,
        timestamp: DateTime.now(),
        evidence:
            'Active defense toolchain verified for $interfaceName. '
            'No live packet injection executed automatically.',
      ),
    );
  }

  SecurityEvent _unsupportedEvent(String ssid, String bssid, String message) {
    return _emit(
      SecurityEvent(
        type: SecurityEventType.unsupportedOperation,
        severity: SecurityEventSeverity.warning,
        ssid: ssid,
        bssid: bssid,
        timestamp: DateTime.now(),
        evidence: message,
      ),
    );
  }

  SecurityEvent _emit(SecurityEvent event) {
    _eventStore.add(event);
    return event;
  }
}
