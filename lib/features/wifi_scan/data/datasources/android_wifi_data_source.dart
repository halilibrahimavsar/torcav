import 'dart:io';
import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/platform/wifi_extended_channel.dart';
import '../../domain/entities/scan_request.dart';
import '../../domain/entities/scan_snapshot.dart';
import '../../domain/entities/wifi_network.dart';
import 'scan_snapshot_builder.dart';
import 'wifi_data_source.dart';
import '../../../settings/domain/services/app_settings_store.dart';

@lazySingleton
class AndroidWifiDataSource implements WifiDataSource {
  final ScanSnapshotBuilder _snapshotBuilder;
  final AppSettingsStore _settingsStore;
  final WiFiScan _wifiScan;

  AndroidWifiDataSource(
    this._snapshotBuilder,
    this._settingsStore,
    this._wifiScan,
  );


  @override
  Future<List<WifiNetwork>> scanNetworks({ScanRequest? request}) async {
    final snapshot = await scanSnapshot(request ?? const ScanRequest());
    return snapshot.toLegacyNetworks();
  }

  @override
  Future<ScanSnapshot> scanSnapshot(ScanRequest request) async {
    if (!Platform.isAndroid) {
      throw const ScanFailure('Android scanner is only supported on Android');
    }

    final hasPermission = await Permission.location.request().isGranted;
    if (!hasPermission) {
      throw const PermissionFailure('Location permission denied');
    }

    // ENFORCEMENT: If strictSafetyMode is ON, we disable hidden SSID scanning
    // regardless of the request parameter to prevent active probing.
    final effectiveIncludeHidden = _settingsStore.value.strictSafetyMode
        ? false
        : request.includeHidden;

    final passCount = max(1, request.passes);
    final passResults = <List<WifiNetwork>>[];
    var anyPassTriggeredFreshScan = false;

    for (var pass = 0; pass < passCount; pass++) {
      // Try to trigger a fresh scan, but if throttled, fall back to
      // cached results. Android 9+ limits foreground scans to ~4 per
      // 2 minutes, so this is expected behaviour.
      var triggeredFreshScan = false;
      try {
        final canStartScan = await _wifiScan.canStartScan();
        if (canStartScan == CanStartScan.yes) {
          triggeredFreshScan = await _wifiScan.startScan();
        }
      } catch (_) {
        // Swallow — we'll use cached results.
      }

      if (triggeredFreshScan) anyPassTriggeredFreshScan = true;

      if (triggeredFreshScan) {
        // Give the radio time to gather results.
        await Future<void>.delayed(
          Duration(milliseconds: request.passIntervalMs.clamp(150, 1500)),
        );
      } else if (pass > 0) {
        // No point in more passes if we can't trigger new scans.
        break;
      }

      // Read whatever results the OS has (fresh or cached).
      final canGetResults = await _wifiScan.canGetScannedResults();
      if (canGetResults != CanGetScannedResults.yes) {
        throw const ScanFailure(
          'Cannot retrieve Wi-Fi scan results. '
          'Please ensure Location is enabled in system settings.',
        );
      }

      final results = await _wifiScan.getScannedResults();

      if (results.isEmpty && pass == 0) {
        throw const ScanFailure(
          'No Wi-Fi networks found. '
          'Ensure Wi-Fi and Location services are enabled.',
        );
      }

      // Fetch extended fields (channel width, WiFi standard, WPS, PMF)
      // from the native method channel. Failures here are non-fatal.
      final extended = await WifiExtendedChannel.getExtendedResults();

      final networks =
          results
              .map((result) {
                final bssid = result.bssid.toUpperCase();
                final ext = extended[bssid];
                final capabilities = ext?['capabilities'] as String?;

                return WifiNetwork(
                  ssid: result.ssid,
                  bssid: bssid,
                  signalStrength: result.level,
                  channel: _frequencyToChannel(result.frequency),
                  frequency: result.frequency,
                  security: _mapCapabilitiesToSecurity(
                    capabilities ?? result.capabilities,
                  ),
                  isHidden: result.ssid.isEmpty,
                  channelWidthMhz: WifiExtendedChannel.channelWidthToMhz(
                    ext?['channelWidth'] as int?,
                  ),
                  wifiStandard: wifiStandardFromInt(
                    ext?['wifiStandard'] as int?,
                  ),
                  hasWps:
                      ext != null
                          ? WifiExtendedChannel.hasWps(capabilities)
                          : null,
                  hasPmf:
                      ext != null
                          ? WifiExtendedChannel.hasPmf(capabilities)
                          : null,
                  rawCapabilities: capabilities,
                  apMldMac: ext?['apMldMac'] as String?,
                );
              })
              .where(
                (network) =>
                    effectiveIncludeHidden || network.ssid.isNotEmpty,
              )
              .toList();

      passResults.add(networks);
    }

    return await _snapshotBuilder.build(
      timestamp: DateTime.now(),
      backendUsed: 'android_wifi_scan',
      interfaceName: request.interfaceName ?? 'wlan0',
      passes: passResults,
      isFromCache: !anyPassTriggeredFreshScan,
    );
  }

  int _frequencyToChannel(int frequency) {
    if (frequency == 2484) {
      return 14;
    }
    if (frequency < 2484) {
      return (frequency - 2407) ~/ 5;
    }
    if (frequency >= 4910 && frequency <= 4980) {
      return (frequency - 4000) ~/ 5;
    }
    if (frequency < 5925) {
      return (frequency - 5000) ~/ 5;
    }
    if (frequency >= 5955) {
      return (frequency - 5950) ~/ 5;
    }
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
