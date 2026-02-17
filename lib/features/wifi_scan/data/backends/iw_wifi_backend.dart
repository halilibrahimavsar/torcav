import 'dart:convert';

import '../../../../core/error/failures.dart';
import '../../../../core/services/process_runner.dart';
import '../../domain/backends/wifi_backend.dart';
import '../../domain/entities/scan_request.dart';
import '../../domain/entities/wifi_network.dart';

class IwWifiBackend implements WifiBackend {
  final ProcessRunner _processRunner;

  const IwWifiBackend(this._processRunner);

  @override
  Future<BackendScanResult> scan({
    required String interfaceName,
    required ScanRequest request,
  }) async {
    final result = await _processRunner.run('iw', [
      'dev',
      interfaceName,
      'scan',
    ]);
    if (result.exitCode != 0) {
      throw ScanFailure('iw failed: ${result.stderr}');
    }

    final lines = const LineSplitter().convert(result.stdout.toString());
    final networks = <WifiNetwork>[];
    _IwRow? current;

    void flush() {
      final entry = current;
      if (entry == null || entry.bssid.isEmpty) {
        return;
      }
      if (!request.includeHidden && entry.ssid.isEmpty) {
        return;
      }
      final frequency = entry.frequency;
      networks.add(
        WifiNetwork(
          ssid: entry.ssid,
          bssid: entry.bssid,
          signalStrength: entry.signalDbm.round(),
          channel:
              entry.channel == 0
                  ? _frequencyToChannel(frequency)
                  : entry.channel,
          frequency: frequency,
          security: entry.security,
          isHidden: entry.ssid.isEmpty,
        ),
      );
    }

    for (final raw in lines) {
      final line = raw.trimLeft();
      if (line.startsWith('BSS ')) {
        flush();
        final bssid =
            RegExp(
              r'^BSS\s+([0-9A-Fa-f:]{17})',
            ).firstMatch(line)?.group(1)?.toUpperCase();
        current = _IwRow(bssid: bssid ?? '');
        continue;
      }
      if (current == null) {
        continue;
      }
      if (line.startsWith('SSID:')) {
        current = current.copyWith(ssid: line.substring(5).trim());
      } else if (line.startsWith('freq:')) {
        current = current.copyWith(
          frequency: int.tryParse(line.substring(5).trim()) ?? 0,
        );
      } else if (line.startsWith('signal:')) {
        final val = RegExp(
          r'signal:\s*(-?[0-9]+(\.[0-9]+)?)',
        ).firstMatch(line)?.group(1);
        current = current.copyWith(
          signalDbm: double.tryParse(val ?? '') ?? -100,
        );
      } else if (line.contains('DS Parameter set: channel')) {
        final channel = RegExp(
          r'channel\s+([0-9]+)',
        ).firstMatch(line)?.group(1);
        current = current.copyWith(channel: int.tryParse(channel ?? '') ?? 0);
      } else if (line.contains('SAE') || line.contains('WPA3')) {
        current = current.copyWith(security: SecurityType.wpa3);
      } else if (line.contains('RSN:')) {
        if (current.security != SecurityType.wpa3) {
          current = current.copyWith(security: SecurityType.wpa2);
        }
      } else if (line.contains('WPA:') &&
          current.security == SecurityType.open) {
        current = current.copyWith(security: SecurityType.wpa);
      } else if (line.contains('WEP')) {
        current = current.copyWith(security: SecurityType.wep);
      }
    }
    flush();

    return BackendScanResult(backendName: 'iw', networks: networks);
  }

  @override
  Future<BackendCapabilities> capabilities() async {
    return const BackendCapabilities(
      backendName: 'iw',
      supportsHiddenScan: true,
      requiresPrivileges: true,
      supportsRealtimeDbm: true,
    );
  }

  int _frequencyToChannel(int frequency) {
    if (frequency == 2484) return 14;
    if (frequency < 2484 && frequency >= 2412) return (frequency - 2407) ~/ 5;
    if (frequency >= 4910 && frequency <= 4980) return (frequency - 4000) ~/ 5;
    if (frequency >= 5000 && frequency < 5925) return (frequency - 5000) ~/ 5;
    if (frequency >= 5955) return (frequency - 5950) ~/ 5;
    return 0;
  }
}

class _IwRow {
  final String bssid;
  final String ssid;
  final int frequency;
  final double signalDbm;
  final int channel;
  final SecurityType security;

  const _IwRow({
    required this.bssid,
    this.ssid = '',
    this.frequency = 0,
    this.signalDbm = -100,
    this.channel = 0,
    this.security = SecurityType.open,
  });

  _IwRow copyWith({
    String? ssid,
    int? frequency,
    double? signalDbm,
    int? channel,
    SecurityType? security,
  }) {
    return _IwRow(
      bssid: bssid,
      ssid: ssid ?? this.ssid,
      frequency: frequency ?? this.frequency,
      signalDbm: signalDbm ?? this.signalDbm,
      channel: channel ?? this.channel,
      security: security ?? this.security,
    );
  }
}
