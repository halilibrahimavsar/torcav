import 'dart:convert';

import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/process_runner.dart';
import '../../domain/entities/wifi_network.dart';
import 'wifi_data_source.dart';

@LazySingleton(as: WifiDataSource)
class LinuxWifiDataSource implements WifiDataSource {
  final ProcessRunner processRunner;

  LinuxWifiDataSource(this.processRunner);

  @override
  Future<List<WifiNetwork>> scanNetworks() async {
    try {
      // Using nmcli with terse output (-t) and specific fields
      // nmcli -t -f BSSID,SSID,SIGNAL,SECURITY,CHAN,FREQ,BARS devise wifi
      final result = await processRunner.run('nmcli', [
        '-t',
        '-f',
        'BSSID,SSID,SIGNAL,SECURITY,CHAN,FREQ',
        'device',
        'wifi',
        'list',
      ]);

      if (result.exitCode != 0) {
        throw const ScanFailure('Failed to execute nmcli');
      }

      final output = result.stdout.toString();
      final lines = const LineSplitter().convert(output);
      final networks = <WifiNetwork>[];

      for (final line in lines) {
        // nmcli escapes colons in values with backslash, but the separator is also colon.
        // -t format separates fields with :. BSSID also has :.
        // nmcli -t escapes the field separators (Wait, nmcli -t output is tricky with BSSID)
        // Actually, nmcli -t escapes field delimiters using backslash.
        // Let's parse carefully. Or maybe use CSV output? nmcli doesn't output CSV directly easily.
        // Let's assume standard behavior: BSSID:SSID:SIGNAL...
        // But BSSID itself contains colons! "AA:BB:CC..."
        //
        // A better approach might be to use fixed width or just handle the split carefully.
        // Or use `iw` which is more raw but robust.
        //
        // Let's try parsing manually. BSSID is always the first field and contains 5 colons? No, BSSID has 5 colons.
        //
        // Alternative: Use `nmcli -f BSSID,SSID...` without `-t` and parse column based? No, strict is better.
        //
        // nmcli documentation says: "In terse mode, the columns are separated by colons (:). Colons inside the values are escaped with a backslash (\)."
        // So we can split by `(?<!\\):`.

        final parts = _splitTerse(line);
        if (parts.length < 6) continue;

        final bssid = _unescape(parts[0]);
        final ssid = _unescape(parts[1]);
        final quality = int.tryParse(parts[2]) ?? 0;
        final signalDbm =
            (quality / 2).round() - 100; // Approximate dBm from quality
        final securityStr = _unescape(parts[3]);
        final channel = int.tryParse(parts[4]) ?? 0;
        final freqStr = _unescape(parts[5].replaceAll(' MHz', ''));
        final frequency = int.tryParse(freqStr) ?? 0;

        networks.add(
          WifiNetwork(
            ssid: ssid,
            bssid: bssid,
            signalStrength:
                signalDbm, // nmcli 'SIGNAL' is usually quality 0-100. 'SSID-HEX' might be needed.
            // Wait, SIGNAL in nmcli is usually bars/quality.
            // dbm is in 'SIGNAL-DBM' field? Let's check.
            // Command: nmcli -f BSSID,SSID,SIGNAL,SECURITY,CHAN,FREQ device wifi
            // Yes. SIGNAL is usually 0-100.
            // We want dBm. nmcli usually doesn't explicitly expose dBm easily in all versions.
            // `iw dev wlan0 scan` gives dBm.
            // But parsing `iw` is harder.
            // Let's try to map quality to dBm roughly if needed, or check if we can get dBm.
            //
            // Actually, let's use `nmcli -f BSSID,SSID,SIGNAL,SECURITY,CHAN,FREQ,Rate,BARS device wifi`
            // If we can't get dBm, we might approximate: dBm ~= (quality / 2) - 100.
            //
            // Let's stick with this for now and improve later if we switch to `iw`.
            frequency: frequency,
            channel: channel,
            security: _parseSecurity(securityStr),
            isHidden: ssid.isEmpty,
          ),
        );
      }
      return networks;
    } catch (e) {
      throw ScanFailure(e.toString());
    }
  }

  List<String> _splitTerse(String line) {
    // Split by colon not preceded by backslash
    final regex = RegExp(r'(?<!\\):');
    return line.split(regex);
  }

  String _unescape(String start) {
    return start.replaceAll(r'\:', ':').replaceAll(r'\\', r'\');
  }

  SecurityType _parseSecurity(String sec) {
    final s = sec.toUpperCase();
    if (s.contains('WPA3')) return SecurityType.wpa3;
    if (s.contains('WPA2')) return SecurityType.wpa2;
    if (s.contains('WPA')) return SecurityType.wpa;
    if (s.contains('WEP')) return SecurityType.wep;
    if (s == '--' || s.isEmpty) return SecurityType.open;
    return SecurityType.unknown;
  }
}
