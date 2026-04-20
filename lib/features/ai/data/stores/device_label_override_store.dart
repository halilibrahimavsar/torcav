import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists user-supplied device-type corrections keyed by MAC address.
/// Overrides are stored in SharedPreferences under the prefix `ai_label_`.
@lazySingleton
class DeviceLabelOverrideStore {
  static const _prefix = 'ai_label_';

  Future<void> set(String mac, String deviceType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix${mac.toUpperCase()}', deviceType);
  }

  Future<void> remove(String mac) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix${mac.toUpperCase()}');
  }

  Future<String?> get(String mac) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix${mac.toUpperCase()}');
  }

  Future<Map<String, String>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, String>{};
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_prefix)) {
        final mac = key.substring(_prefix.length);
        result[mac] = prefs.getString(key)!;
      }
    }
    return result;
  }
}
