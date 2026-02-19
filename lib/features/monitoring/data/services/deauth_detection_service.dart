import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/services/privilege_service.dart';
import '../../../../core/services/process_runner.dart';
import '../../domain/entities/deauth_event.dart';

@lazySingleton
class DeauthDetectionService {
  final ProcessRunner _processRunner;
  final PrivilegeService _privilegeService;
  final NotificationService _notificationService;
  final StreamController<DeauthEvent> _eventController =
      StreamController<DeauthEvent>.broadcast();

  Process? _monitorProcess;
  bool _isMonitoring = false;
  Timer? _deauthWindowTimer;
  final List<DeauthFrame> _recentFrames = [];
  static const _deauthThreshold = 5;
  static const _windowDuration = Duration(seconds: 3);

  DeauthDetectionService(
    this._processRunner,
    this._privilegeService,
    this._notificationService,
  );

  Stream<DeauthEvent> get events => _eventController.stream;
  bool get isMonitoring => _isMonitoring;

  Future<bool> startMonitoring(String interface) async {
    if (_isMonitoring) return true;
    if (!Platform.isLinux) {
      _emitError('Deauth detection only supported on Linux');
      return false;
    }

    final whichResult = await _processRunner.run('which', ['airoddump-ng']);
    if (whichResult.exitCode != 0) {
      _emitError('airodump-ng not found. Install aircrack-ng suite.');
      return false;
    }

    try {
      _monitorProcess = await _privilegeService.startAsRoot('airodump-ng', [
        interface,
        '--berlin',
        '60',
      ]);

      _isMonitoring = true;
      _monitorProcess!.stdout.listen(_parseOutput);
      _monitorProcess!.stderr.listen((_) {});
      _monitorProcess!.exitCode.then((_) {
        _isMonitoring = false;
      });

      return true;
    } catch (e) {
      _emitError('Failed to start monitoring: $e');
      return false;
    }
  }

  void stopMonitoring() {
    _monitorProcess?.kill();
    _monitorProcess = null;
    _isMonitoring = false;
    _deauthWindowTimer?.cancel();
    _recentFrames.clear();
  }

  void _parseOutput(List<int> data) {
    final output = String.fromCharCodes(data);
    final lines = output.split('\n');

    for (final line in lines) {
      _checkForDeauthFrame(line);
    }
  }

  void _checkForDeauthFrame(String line) {
    final deauthPattern = RegExp(
      r'(DeAuth|deauth|DEAUTH).*([0-9A-Fa-f:]{17}).*([0-9A-Fa-f:]{17})',
    );
    final match = deauthPattern.firstMatch(line);

    if (match != null) {
      final source = match.group(2)?.toUpperCase() ?? 'Unknown';
      final target = match.group(3)?.toUpperCase() ?? 'Unknown';

      final frame = DeauthFrame(
        sourceMac: source,
        targetMac: target,
        timestamp: DateTime.now(),
      );

      _recentFrames.add(frame);
      _analyzeDeauthPattern();
    }
  }

  void _analyzeDeauthPattern() {
    final now = DateTime.now();
    _recentFrames.removeWhere(
      (f) => now.difference(f.timestamp) > _windowDuration,
    );

    if (_recentFrames.length >= _deauthThreshold) {
      _emitDeauthBurst();
      _recentFrames.clear();
    }
  }

  void _emitDeauthBurst() {
    final event = DeauthEvent(
      type: DeauthEventType.burst,
      frameCount: _recentFrames.length,
      sources: _recentFrames.map((f) => f.sourceMac).toSet().toList(),
      timestamp: DateTime.now(),
    );

    _eventController.add(event);

    _notificationService.showAttackDetected(
      'Deauthentication Attack',
      'Detected ${event.frameCount} deauth frames from ${event.sources.first}',
    );
  }

  void _emitError(String message) {
    _eventController.add(
      DeauthEvent(
        type: DeauthEventType.error,
        errorMessage: message,
        timestamp: DateTime.now(),
      ),
    );
  }

  void dispose() {
    stopMonitoring();
    _eventController.close();
  }
}
