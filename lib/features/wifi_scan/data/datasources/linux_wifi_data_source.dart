import 'dart:io';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/scan_request.dart';
import '../../domain/entities/scan_snapshot.dart';
import '../../domain/entities/wifi_network.dart';
import 'scan_snapshot_builder.dart';
import 'wifi_data_source.dart';

/// Wi-Fi data source for Linux desktop using `nmcli`.
///
/// Falls back to `iwlist` if NetworkManager is not available.
/// Extended fields (channel width, Wi-Fi standard) are not available
/// without root — they are left null.
class LinuxWifiDataSource implements WifiDataSource {
  final ScanSnapshotBuilder _snapshotBuilder;

  LinuxWifiDataSource() : _snapshotBuilder = const ScanSnapshotBuilder();

  @override
  Future<List<WifiNetwork>> scanNetworks({ScanRequest? request}) async {
    final snapshot = await scanSnapshot(request ?? const ScanRequest());
    return snapshot.toLegacyNetworks();
  }

  @override
  Future<ScanSnapshot> scanSnapshot(ScanRequest request) async {
    final passes = <List<WifiNetwork>>[];
    final passCount = request.passes.clamp(1, 3);

    for (var i = 0; i < passCount; i++) {
      final networks = await _scan(request);
      passes.add(networks);
      if (i < passCount - 1) {
        await Future<void>.delayed(
          Duration(milliseconds: request.passIntervalMs.clamp(200, 1500)),
        );
      }
    }

    return _snapshotBuilder.build(
      timestamp: DateTime.now(),
      backendUsed: 'linux_nmcli',
      interfaceName: request.interfaceName ?? await _detectInterface(),
      passes: passes,
    );
  }

  Future<List<WifiNetwork>> _scan(ScanRequest request) async {
    // Try nmcli first (most reliable, no root required)
    try {
      return await _scanWithNmcli(request);
    } catch (_) {
      // Fallback: iwlist (older systems)
      try {
        return await _scanWithIwlist(request);
      } catch (e) {
        throw ScanFailure(
          'Wi-Fi scan failed. Ensure NetworkManager or wireless-tools is '
          'installed and Wi-Fi is enabled. Error: $e',
        );
      }
    }
  }

  Future<List<WifiNetwork>> _scanWithNmcli(ScanRequest request) async {
    // Request a rescan first (may be ignored if too frequent)
    await Process.run('nmcli', ['device', 'wifi', 'rescan']).catchError((_) => ProcessResult(0, 0, '', ''));

    final result = await Process.run('nmcli', [
      '-t',
      '-f',
      'SSID,BSSID,SIGNAL,CHAN,FREQ,SECURITY,BARS',
      'device',
      'wifi',
      'list',
    ]);

    if (result.exitCode != 0) {
      throw ScanFailure('nmcli exited with code ${result.exitCode}: ${result.stderr}');
    }

    final lines = (result.stdout as String)
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    final networks = <WifiNetwork>[];
    for (final line in lines) {
      final n = _parseNmcliLine(line);
      if (n != null) {
        if (!request.includeHidden && n.ssid.isEmpty) continue;
        networks.add(n);
      }
    }

    if (networks.isEmpty) {
      throw const ScanFailure(
        'No Wi-Fi networks found. Ensure Wi-Fi is enabled.',
      );
    }

    return networks;
  }

  /// Parse a single nmcli -t output line.
  /// Format: SSID:BSSID:SIGNAL:CHAN:FREQ:SECURITY
  /// Note: SSID may contain colons — nmcli escapes them as \:
  WifiNetwork? _parseNmcliLine(String line) {
    try {
      // nmcli -t escapes colons within field values as `\:`
      // We split on unescaped `:` only
      final fields = _splitNmcli(line);
      if (fields.length < 6) return null;

      final ssid = fields[0].replaceAll(r'\:', ':');
      final bssid = fields[1].replaceAll(r'\:', ':').toUpperCase();
      final signal = int.tryParse(fields[2]) ?? 0;
      final channel = int.tryParse(fields[3]) ?? 0;
      final freqStr = fields[4].replaceAll(RegExp(r'[^\d]'), '');
      final freq = int.tryParse(freqStr) ?? _channelToFrequency(channel);
      final security = _mapNmcliSecurity(fields[5]);

      // nmcli signal is 0–100; convert to approximate dBm (-100 to -30)
      final dbm = _signalPercentToDbm(signal);

      return WifiNetwork(
        ssid: ssid,
        bssid: bssid,
        signalStrength: dbm,
        channel: channel,
        frequency: freq,
        security: security,
        isHidden: ssid.isEmpty,
      );
    } catch (_) {
      return null;
    }
  }

  /// Split on unescaped colons (nmcli -t separator).
  List<String> _splitNmcli(String line) {
    final parts = <String>[];
    final buf = StringBuffer();
    for (var i = 0; i < line.length; i++) {
      if (line[i] == '\\' && i + 1 < line.length && line[i + 1] == ':') {
        buf.write('\\:');
        i++;
      } else if (line[i] == ':') {
        parts.add(buf.toString());
        buf.clear();
      } else {
        buf.write(line[i]);
      }
    }
    parts.add(buf.toString());
    return parts;
  }

  Future<List<WifiNetwork>> _scanWithIwlist(ScanRequest request) async {
    final iface = await _detectInterface();
    final result = await Process.run('iwlist', [iface, 'scan']);
    if (result.exitCode != 0) {
      throw ScanFailure('iwlist exited with ${result.exitCode}');
    }
    return _parseIwlist(result.stdout as String, request);
  }

  List<WifiNetwork> _parseIwlist(String output, ScanRequest request) {
    final networks = <WifiNetwork>[];
    final cells = output.split(RegExp(r'Cell \d+ - '));
    for (final cell in cells.skip(1)) {
      final n = _parseIwlistCell(cell);
      if (n != null) {
        if (!request.includeHidden && n.ssid.isEmpty) continue;
        networks.add(n);
      }
    }
    return networks;
  }

  WifiNetwork? _parseIwlistCell(String cell) {
    try {
      String? ssid, bssid;
      int signal = -80, channel = 0, frequency = 0;
      SecurityType security = SecurityType.open;

      for (final line in cell.split('\n')) {
        final t = line.trim();
        if (t.startsWith('Address:')) {
          bssid = t.substring(8).trim().toUpperCase();
        } else if (t.startsWith('ESSID:')) {
          ssid = t.substring(6).trim().replaceAll('"', '');
        } else if (t.startsWith('Channel:')) {
          channel = int.tryParse(t.substring(8).trim()) ?? 0;
        } else if (t.startsWith('Frequency:')) {
          final m = RegExp(r'([\d.]+)\s*GHz').firstMatch(t);
          if (m != null) {
            final ghz = double.tryParse(m.group(1)!) ?? 0.0;
            frequency = (ghz * 1000).round();
          }
        } else if (t.startsWith('Signal level=')) {
          final m = RegExp(r'Signal level=(-?\d+)').firstMatch(t);
          if (m != null) signal = int.tryParse(m.group(1)!) ?? -80;
        } else if (t.contains('WPA2') || t.contains('RSN')) {
          security = SecurityType.wpa2;
        } else if (t.contains('WPA')) {
          if (security != SecurityType.wpa2) security = SecurityType.wpa;
        } else if (t.contains('WEP')) {
          if (security == SecurityType.open) security = SecurityType.wep;
        }
      }

      if (bssid == null) return null;
      if (frequency == 0) frequency = _channelToFrequency(channel);

      return WifiNetwork(
        ssid: ssid ?? '',
        bssid: bssid,
        signalStrength: signal,
        channel: channel,
        frequency: frequency,
        security: security,
        isHidden: ssid == null || ssid.isEmpty,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String> _detectInterface() async {
    // Try to get the first active wireless interface via iw/ip
    try {
      final result = await Process.run('iw', ['dev']);
      final m = RegExp(r'Interface\s+(\w+)').firstMatch(result.stdout as String);
      if (m != null) return m.group(1)!;
    } catch (_) {}
    return 'wlan0';
  }

  SecurityType _mapNmcliSecurity(String sec) {
    final s = sec.toUpperCase();
    if (s.contains('WPA3') || s.contains('SAE')) return SecurityType.wpa3;
    if (s.contains('WPA2')) return SecurityType.wpa2;
    if (s.contains('WPA')) return SecurityType.wpa;
    if (s.contains('WEP')) return SecurityType.wep;
    if (s == '--' || s.isEmpty) return SecurityType.open;
    return SecurityType.open;
  }

  /// Convert nmcli's 0–100 signal percentage to approximate dBm.
  int _signalPercentToDbm(int percent) {
    if (percent >= 100) return -30;
    if (percent <= 0) return -100;
    return (percent / 2 - 100).round();
  }

  int _channelToFrequency(int channel) {
    if (channel >= 1 && channel <= 13) return 2407 + channel * 5;
    if (channel == 14) return 2484;
    if (channel >= 36 && channel <= 177) return 5000 + channel * 5;
    return 0;
  }
}
