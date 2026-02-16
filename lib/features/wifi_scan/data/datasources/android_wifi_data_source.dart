import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wifi_network.dart';
import 'wifi_data_source.dart';

@LazySingleton(as: WifiDataSource)
@Named('android')
class AndroidWifiDataSource implements WifiDataSource {
  @override
  Future<List<WifiNetwork>> scanNetworks() async {
    // Check permissions
    if (await Permission.location.request().isGranted) {
      final canScan = await WiFiScan.instance.canStartScan();
      if (canScan != CanStartScan.yes) {
        throw const ScanFailure(
          'Cannot start scan: Location disabled or throttle limit reached',
        );
      }

      final started = await WiFiScan.instance.startScan();
      if (!started) {
        throw const ScanFailure('Failed to start Wi-Fi scan');
      }

      // Get results
      final results = await WiFiScan.instance.getScannedResults();
      return results.map((result) {
        return WifiNetwork(
          ssid: result.ssid,
          bssid: result.bssid,
          signalStrength: result.level,
          channel: _frequencyToChannel(result.frequency),
          frequency: result.frequency,
          security: _mapCapabilitiesToSecurity(result.capabilities),
          vendor: '', // Android doesn't give vendor directly
        );
      }).toList();
    } else {
      throw const PermissionFailure('Location permission denied');
    }
  }

  int _frequencyToChannel(int freq) {
    if (freq == 2484) return 14;
    if (freq < 2484) return (freq - 2407) ~/ 5;
    if (freq >= 4910 && freq <= 4980) return (freq - 4000) ~/ 5;
    if (freq < 5935) return (freq - 5000) ~/ 5;
    if (freq >= 5935) return (freq - 5950) ~/ 5;
    return 0;
  }

  SecurityType _mapCapabilitiesToSecurity(String capabilities) {
    final caps = capabilities.toUpperCase();
    if (caps.contains('WPA3')) return SecurityType.wpa3;
    if (caps.contains('WPA2')) return SecurityType.wpa2;
    if (caps.contains('WPA')) return SecurityType.wpa;
    if (caps.contains('WEP')) return SecurityType.wep;
    if (caps.contains('ESS')) return SecurityType.open; // Basic check
    return SecurityType.open;
  }
}
