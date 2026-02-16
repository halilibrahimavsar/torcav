import 'dart:io';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/process_runner.dart';
import '../../domain/entities/network_device.dart';

abstract class NmapDataSource {
  Future<List<NetworkDevice>> scanSubnet(String subnet);
}

@LazySingleton(as: NmapDataSource)
class LinuxNmapDataSource implements NmapDataSource {
  final ProcessRunner _processRunner;

  LinuxNmapDataSource(this._processRunner);

  @override
  Future<List<NetworkDevice>> scanSubnet(String subnet) async {
    if (!Platform.isLinux) {
      // Return empty or throw error? For now, empty list as fallback.
      return [];
    }

    try {
      // -sn: Ping Scan - disable port scan due to speed and privilege
      // -oG -: Output grepable format to stdout
      final result = await _processRunner.run('nmap', [
        '-sn',
        '-oG',
        '-',
        subnet,
      ]);

      if (result.exitCode != 0) {
        throw ScanFailure('Nmap failed: ${result.stderr}');
      }

      return _parseNmapOutput(result.stdout.toString());
    } catch (e) {
      throw ScanFailure(e.toString());
    }
  }

  List<NetworkDevice> _parseNmapOutput(String output) {
    final devices = <NetworkDevice>[];
    final lines = output.split('\n');

    for (var line in lines) {
      if (line.trim().isEmpty || line.startsWith('#')) continue;

      // specific parsing for grepable output
      // Host: 192.168.1.1 (Gateway)	Status: Up	Host: 192.168.1.10 ()	Status: Up
      // Wait, -oG output format:
      // Host: 192.168.1.1 (Execute)	Status: Up
      // It can contain MAC Address depending on privileges. Non-root might not show MAC.
      // Let's try parsing fields.

      final hostMatch = RegExp(
        r'Host: ([0-9\.]+)\s*\((.*?)\)',
      ).firstMatch(line);
      if (hostMatch != null) {
        final ip = hostMatch.group(1) ?? '';
        final hostname = hostMatch.group(2) ?? '';

        // Try to find MAC if available (requires root usually)
        // Nmap 7.9x might require different parsing or privileges for MAC
        // If not root, we might not get MAC.

        devices.add(
          NetworkDevice(
            ip: ip,
            mac:
                '', // Placeholder, might need parsing improvement for MAC or ARP table lookup fallback
            vendor: '',
            hostName: hostname,
          ),
        );
      }
    }
    return devices;
  }
}
