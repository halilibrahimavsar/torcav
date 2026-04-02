import 'package:flutter/services.dart';

/// Dart-side bridge to the `torcav/wifi_extended` method channel.
///
/// The Android side (MainActivity.kt) provides additional ScanResult fields
/// not exposed by the `wifi_scan` package: channelWidth, wifiStandard,
/// raw capabilities string, timestamp, and (API 33+) the AP MLD MAC.
class WifiExtendedChannel {
  static const _channel = MethodChannel('torcav/wifi_extended');

  /// Fetches extended ScanResult data from Android.
  ///
  /// Returns a map keyed by normalised BSSID (uppercase, colon-separated).
  /// Each value is a map with the following keys:
  ///   - `channelWidth` (int?): 0=20 MHz, 1=40, 2=80, 3=160, 4=320
  ///   - `wifiStandard`  (int?): Android constant (4=n, 5=ac, 6=ax, 7=be)
  ///   - `capabilities`  (String?): raw capabilities string
  ///   - `apMldMac`      (String?): AP MLD MAC address (Wi-Fi 7, API 33+)
  ///   - `timestampUs`   (int?): microseconds since boot
  static Future<Map<String, Map<String, dynamic>>> getExtendedResults() async {
    try {
      final raw = await _channel.invokeMethod<List<dynamic>>('getExtendedResults');
      if (raw == null) return {};

      final result = <String, Map<String, dynamic>>{};
      for (final item in raw) {
        if (item is Map) {
          final bssid = (item['bssid'] as String?)?.toUpperCase();
          if (bssid == null) continue;
          result[bssid] = {
            'channelWidth': item['channelWidth'],
            'wifiStandard': item['wifiStandard'],
            'capabilities': item['capabilities'],
            'apMldMac': item['apMldMac'],
            'timestampUs': item['timestampUs'],
          };
        }
      }
      return result;
    } on PlatformException {
      // If the method channel is not available (e.g. running on non-Android
      // in tests), return empty map gracefully.
      return {};
    } catch (_) {
      return {};
    }
  }

  /// Parses the raw channelWidth int into MHz bandwidth.
  static int? channelWidthToMhz(int? raw) {
    switch (raw) {
      case 0:
        return 20;
      case 1:
        return 40;
      case 2:
        return 80;
      case 3:
        return 160;
      case 4:
        return 320;
      default:
        return null;
    }
  }

  /// Returns true if the capabilities string contains [WPS].
  static bool hasWps(String? capabilities) {
    if (capabilities == null) return false;
    return capabilities.toUpperCase().contains('[WPS]');
  }

  /// Returns true if the capabilities string indicates PMF support.
  /// PMF is advertised via [PMF], [MFPR] (PMF required), or [MFPC] (capable).
  static bool hasPmf(String? capabilities) {
    if (capabilities == null) return false;
    final caps = capabilities.toUpperCase();
    return caps.contains('[PMF]') ||
        caps.contains('[MFPR]') ||
        caps.contains('[MFPC]');
  }
}
