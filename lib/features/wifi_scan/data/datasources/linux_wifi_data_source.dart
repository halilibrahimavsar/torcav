import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/process_runner.dart';
import '../../domain/entities/scan_request.dart';
import '../../domain/entities/scan_snapshot.dart';
import '../../domain/entities/wifi_network.dart';
import 'scan_snapshot_builder.dart';
import 'wifi_data_source.dart';

@LazySingleton(as: WifiDataSource)
@Named('linux')
class LinuxWifiDataSource implements WifiDataSource {
  final ProcessRunner _processRunner;
  final ScanSnapshotBuilder _snapshotBuilder;

  LinuxWifiDataSource(this._processRunner)
    : _snapshotBuilder = const ScanSnapshotBuilder();

  @override
  Future<List<WifiNetwork>> scanNetworks({ScanRequest? request}) async {
    final snapshot = await scanSnapshot(request ?? const ScanRequest());
    return snapshot.toLegacyNetworks();
  }

  @override
  Future<ScanSnapshot> scanSnapshot(ScanRequest request) async {
    if (!Platform.isLinux) {
      throw const ScanFailure('Linux scanner is only supported on Linux');
    }

    final interfaceName =
        request.interfaceName ?? await _detectActiveInterfaceName() ?? 'wlan0';

    final passCount = max(1, request.passes);
    final passResults = <List<WifiNetwork>>[];
    String backendUsed = 'unknown';

    for (var pass = 0; pass < passCount; pass++) {
      final result = await _scanSinglePass(interfaceName, request);
      backendUsed = backendUsed == 'unknown' ? result.backend : backendUsed;
      passResults.add(result.networks);

      if (pass < passCount - 1 && request.passIntervalMs > 0) {
        await Future<void>.delayed(
          Duration(milliseconds: request.passIntervalMs),
        );
      }
    }

    if (passResults.every((entry) => entry.isEmpty)) {
      throw const ScanFailure('No networks found in scan passes');
    }

    return _snapshotBuilder.build(
      timestamp: DateTime.now(),
      backendUsed: backendUsed,
      interfaceName: interfaceName,
      passes: passResults,
    );
  }

  Future<_PassResult> _scanSinglePass(
    String interfaceName,
    ScanRequest request,
  ) async {
    switch (request.backendPreference) {
      case WifiBackendPreference.nmcli:
        return _PassResult(
          backend: 'nmcli',
          networks: await _scanWithNmcli(interfaceName),
        );
      case WifiBackendPreference.iw:
        return _PassResult(
          backend: 'iw',
          networks: await _scanWithIw(interfaceName),
        );
      case WifiBackendPreference.android:
        throw const ScanFailure('Android backend is not available on Linux');
      case WifiBackendPreference.auto:
        try {
          final networks = await _scanWithNmcli(interfaceName);
          return _PassResult(backend: 'nmcli', networks: networks);
        } on Failure {
          final networks = await _scanWithIw(interfaceName);
          return _PassResult(backend: 'iw', networks: networks);
        }
    }
  }

  Future<List<WifiNetwork>> _scanWithNmcli(String interfaceName) async {
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

    final output = result.stdout.toString();
    final lines = const LineSplitter().convert(output);
    final networks = <WifiNetwork>[];

    for (final line in lines) {
      final parts = _splitTerse(line);
      if (parts.length < 6) {
        continue;
      }

      final bssid = _unescape(parts[0]);
      if (bssid.isEmpty) {
        continue;
      }

      final ssid = _unescape(parts[1]);
      final quality = int.tryParse(parts[2]) ?? 0;
      final signalDbm = (quality / 2).round() - 100;
      final security = _parseSecurity(_unescape(parts[3]));
      final channel = int.tryParse(parts[4]) ?? 0;
      final freqRaw = _unescape(parts[5]).replaceAll(' MHz', '');
      final frequency = int.tryParse(freqRaw) ?? 0;

      networks.add(
        WifiNetwork(
          ssid: ssid,
          bssid: bssid,
          signalStrength: signalDbm,
          channel: channel == 0 ? _frequencyToChannel(frequency) : channel,
          frequency: frequency,
          security: security,
          isHidden: ssid.isEmpty,
        ),
      );
    }

    return networks;
  }

  Future<List<WifiNetwork>> _scanWithIw(String interfaceName) async {
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
    _IwNetworkAccumulator? current;

    void flushCurrent() {
      final entry = current;
      if (entry == null || entry.bssid.isEmpty) {
        return;
      }

      final frequency = entry.frequency;
      final derivedChannel =
          entry.channel == 0 ? _frequencyToChannel(frequency) : entry.channel;

      networks.add(
        WifiNetwork(
          ssid: entry.ssid,
          bssid: entry.bssid,
          signalStrength: entry.signalDbm.round(),
          channel: derivedChannel,
          frequency: frequency,
          security: entry.security,
          isHidden: entry.ssid.isEmpty,
        ),
      );
    }

    for (final rawLine in lines) {
      final line = rawLine.trimLeft();

      if (line.startsWith('BSS ')) {
        flushCurrent();
        final match = RegExp(r'^BSS\s+([0-9A-Fa-f:]{17})').firstMatch(line);
        current = _IwNetworkAccumulator(
          bssid: match?.group(1)?.toUpperCase() ?? '',
        );
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
        final match = RegExp(
          r'signal:\s*(-?[0-9]+(\.[0-9]+)?)',
        ).firstMatch(line);
        current = current.copyWith(
          signalDbm: double.tryParse(match?.group(1) ?? '') ?? -100,
        );
      } else if (line.contains('DS Parameter set: channel')) {
        final match = RegExp(r'channel\s+([0-9]+)').firstMatch(line)?.group(1);
        current = current.copyWith(channel: int.tryParse(match ?? '') ?? 0);
      } else if (line.contains('SAE') || line.contains('WPA3')) {
        current = current.copyWith(security: SecurityType.wpa3);
      } else if (line.contains('RSN:')) {
        if (current.security != SecurityType.wpa3) {
          current = current.copyWith(security: SecurityType.wpa2);
        }
      } else if (line.contains('WPA:')) {
        if (current.security == SecurityType.open) {
          current = current.copyWith(security: SecurityType.wpa);
        }
      } else if (line.contains('WEP')) {
        current = current.copyWith(security: SecurityType.wep);
      }
    }

    flushCurrent();
    return networks;
  }

  Future<String?> _detectActiveInterfaceName() async {
    try {
      final nmcliResult = await _processRunner.run('nmcli', [
        '-t',
        '-f',
        'DEVICE,TYPE,STATE',
        'device',
        'status',
      ]);

      if (nmcliResult.exitCode == 0) {
        final lines = const LineSplitter().convert(
          nmcliResult.stdout.toString(),
        );
        String? fallbackWifi;

        for (final line in lines) {
          final parts = _splitTerse(line);
          if (parts.length < 3) {
            continue;
          }
          final device = _unescape(parts[0]);
          final type = _unescape(parts[1]).toLowerCase();
          final state = _unescape(parts[2]).toLowerCase();

          if (type != 'wifi') {
            continue;
          }
          fallbackWifi ??= device;
          if (state.contains('connected')) {
            return device;
          }
        }

        if (fallbackWifi != null && fallbackWifi.isNotEmpty) {
          return fallbackWifi;
        }
      }
    } catch (_) {
      // fallback to iw parser below
    }

    try {
      final iwResult = await _processRunner.run('iw', ['dev']);
      if (iwResult.exitCode != 0) {
        return null;
      }

      final lines = const LineSplitter().convert(iwResult.stdout.toString());
      for (final line in lines) {
        final match = RegExp(r'^\s*Interface\s+(\S+)\s*$').firstMatch(line);
        if (match != null) {
          return match.group(1);
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  List<String> _splitTerse(String line) {
    return line.split(RegExp(r'(?<!\\):'));
  }

  String _unescape(String value) {
    return value.replaceAll(r'\:', ':').replaceAll(r'\\', r'\').trim();
  }

  SecurityType _parseSecurity(String securityRaw) {
    final security = securityRaw.toUpperCase();
    if (security.contains('WPA3') || security.contains('SAE')) {
      return SecurityType.wpa3;
    }
    if (security.contains('WPA2') || security.contains('RSN')) {
      return SecurityType.wpa2;
    }
    if (security.contains('WPA')) {
      return SecurityType.wpa;
    }
    if (security.contains('WEP')) {
      return SecurityType.wep;
    }
    if (security == '--' || security.isEmpty) {
      return SecurityType.open;
    }
    return SecurityType.unknown;
  }

  int _frequencyToChannel(int frequency) {
    if (frequency == 2484) {
      return 14;
    }
    if (frequency < 2484 && frequency >= 2412) {
      return (frequency - 2407) ~/ 5;
    }
    if (frequency >= 4910 && frequency <= 4980) {
      return (frequency - 4000) ~/ 5;
    }
    if (frequency >= 5000 && frequency < 5925) {
      return (frequency - 5000) ~/ 5;
    }
    if (frequency >= 5955) {
      return (frequency - 5950) ~/ 5;
    }
    return 0;
  }
}

class _PassResult {
  final String backend;
  final List<WifiNetwork> networks;

  const _PassResult({required this.backend, required this.networks});
}

class _IwNetworkAccumulator {
  final String bssid;
  final String ssid;
  final int frequency;
  final double signalDbm;
  final int channel;
  final SecurityType security;

  const _IwNetworkAccumulator({
    required this.bssid,
    this.ssid = '',
    this.frequency = 0,
    this.signalDbm = -100,
    this.channel = 0,
    this.security = SecurityType.open,
  });

  _IwNetworkAccumulator copyWith({
    String? ssid,
    int? frequency,
    double? signalDbm,
    int? channel,
    SecurityType? security,
  }) {
    return _IwNetworkAccumulator(
      bssid: bssid,
      ssid: ssid ?? this.ssid,
      frequency: frequency ?? this.frequency,
      signalDbm: signalDbm ?? this.signalDbm,
      channel: channel ?? this.channel,
      security: security ?? this.security,
    );
  }
}
