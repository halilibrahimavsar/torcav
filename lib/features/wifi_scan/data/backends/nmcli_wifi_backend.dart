import 'dart:convert';

import '../../../../core/error/failures.dart';
import '../../../../core/services/process_runner.dart';
import '../../domain/backends/wifi_backend.dart';
import '../../domain/entities/scan_request.dart';
import '../../domain/entities/wifi_network.dart';

class NmcliWifiBackend implements WifiBackend {
  final ProcessRunner _processRunner;

  const NmcliWifiBackend(this._processRunner);

  @override
  Future<BackendScanResult> scan({
    required String interfaceName,
    required ScanRequest request,
  }) async {
    final result = await _processRunner.run('nmcli', [
      '-t',
      '-f',
      'BSSID,SSID,SIGNAL,SECURITY,CHAN,FREQ',
      'device',
      'wifi',
      'list',
      'ifname',
      interfaceName,
    ]);

    if (result.exitCode != 0) {
      throw ScanFailure('nmcli failed: ${result.stderr}');
    }

    final lines = const LineSplitter().convert(result.stdout.toString());
    final networks = <WifiNetwork>[];

    for (final line in lines) {
      final parts = line.split(RegExp(r'(?<!\\):'));
      if (parts.length < 6) {
        continue;
      }
      final bssid = _unescape(parts[0]);
      final ssid = _unescape(parts[1]);
      if (bssid.isEmpty || (!request.includeHidden && ssid.isEmpty)) {
        continue;
      }

      final quality = int.tryParse(parts[2]) ?? 0;
      final signalDbm = (quality / 2).round() - 100;
      final channel = int.tryParse(parts[4]) ?? 0;
      final frequency =
          int.tryParse(_unescape(parts[5]).replaceAll(' MHz', '')) ?? 0;

      networks.add(
        WifiNetwork(
          ssid: ssid,
          bssid: bssid,
          signalStrength: signalDbm,
          channel: channel == 0 ? _frequencyToChannel(frequency) : channel,
          frequency: frequency,
          security: _parseSecurity(_unescape(parts[3])),
          isHidden: ssid.isEmpty,
        ),
      );
    }

    return BackendScanResult(backendName: 'nmcli', networks: networks);
  }

  @override
  Future<BackendCapabilities> capabilities() async {
    return const BackendCapabilities(
      backendName: 'nmcli',
      supportsHiddenScan: true,
      requiresPrivileges: false,
      supportsRealtimeDbm: false,
    );
  }

  String _unescape(String value) {
    return value.replaceAll(r'\:', ':').replaceAll(r'\\', r'\').trim();
  }

  SecurityType _parseSecurity(String sec) {
    final s = sec.toUpperCase();
    if (s.contains('WPA3') || s.contains('SAE')) return SecurityType.wpa3;
    if (s.contains('WPA2') || s.contains('RSN')) return SecurityType.wpa2;
    if (s.contains('WPA')) return SecurityType.wpa;
    if (s.contains('WEP')) return SecurityType.wep;
    if (s == '--' || s.isEmpty) return SecurityType.open;
    return SecurityType.unknown;
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
