import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

import '../../../../core/error/failures.dart';
import '../../domain/backends/wifi_backend.dart';
import '../../domain/entities/scan_request.dart';
import '../../domain/entities/wifi_network.dart';

class AndroidWifiBackend implements WifiBackend {
  const AndroidWifiBackend();

  @override
  Future<BackendScanResult> scan({
    required String interfaceName,
    required ScanRequest request,
  }) async {
    final hasPermission = await Permission.location.request().isGranted;
    if (!hasPermission) {
      throw const PermissionFailure('Location permission denied');
    }

    // Try to trigger a fresh scan. Android 9+ throttles foreground apps
    // to ~4 scans per 2 minutes, so this may fail. In that case we
    // fall back to cached results, which are usually still recent.
    var triggeredNewScan = false;
    try {
      final canStart = await WiFiScan.instance.canStartScan();
      if (canStart == CanStartScan.yes) {
        triggeredNewScan = await WiFiScan.instance.startScan();
      }
    } catch (_) {
      // Fall through — use cached results.
    }

    if (triggeredNewScan) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    final results = await WiFiScan.instance.getScannedResults();
    final networks =
        results
            .map(
              (result) => WifiNetwork(
                ssid: result.ssid,
                bssid: result.bssid.toUpperCase(),
                signalStrength: result.level,
                channel: _frequencyToChannel(result.frequency),
                frequency: result.frequency,
                security: _mapCapabilitiesToSecurity(result.capabilities),
                isHidden: result.ssid.isEmpty,
              ),
            )
            .where((entry) => request.includeHidden || entry.ssid.isNotEmpty)
            .toList();

    return BackendScanResult(
      backendName: 'android_wifi_scan',
      networks: networks,
    );
  }

  @override
  Future<BackendCapabilities> capabilities() async {
    return const BackendCapabilities(
      backendName: 'android_wifi_scan',
      supportsHiddenScan: true,
      requiresPrivileges: false,
      supportsRealtimeDbm: true,
    );
  }

  int _frequencyToChannel(int frequency) {
    if (frequency == 2484) return 14;
    if (frequency < 2484) return (frequency - 2407) ~/ 5;
    if (frequency >= 4910 && frequency <= 4980) {
      return (frequency - 4000) ~/ 5;
    }
    if (frequency < 5925) return (frequency - 5000) ~/ 5;
    if (frequency >= 5955) return (frequency - 5950) ~/ 5;
    return 0;
  }

  SecurityType _mapCapabilitiesToSecurity(String capabilities) {
    final caps = capabilities.toUpperCase();
    if (caps.contains('WPA3') || caps.contains('SAE')) {
      return SecurityType.wpa3;
    }
    if (caps.contains('WPA2') || caps.contains('RSN')) {
      return SecurityType.wpa2;
    }
    if (caps.contains('WPA')) {
      return SecurityType.wpa;
    }
    if (caps.contains('WEP')) {
      return SecurityType.wep;
    }
    return SecurityType.open;
  }
}
