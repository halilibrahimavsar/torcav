import 'package:injectable/injectable.dart';
import '../storage/oui_database_service.dart';

/// OUI (Organizationally Unique Identifier) lookup utility.
///
/// Maps the first 3 octets of a MAC address to the registered hardware vendor
/// using a high-performance, disk-backed SQLite database.
@lazySingleton
class OuiLookup {
  final OuiDatabaseService _dbService;

  const OuiLookup(this._dbService);

  /// Returns the vendor name for the given MAC address, or 'Unknown' if not found.
  Future<String> lookup(String mac) => _dbService.getVendor(mac);

  /// Returns `true` when the MAC address has a Locally Administered Address
  /// (LAA) bit set — a strong indicator of MAC randomization or spoofing.
  ///
  /// LAA is identified by the second hex character of the first octet being
  /// 2, 6, A, or E (i.e. bit 1 of the first byte is set).
  static bool isSuspicious(String mac) {
    if (mac.length < 2) return false;
    final secondChar = mac[1].toUpperCase();
    return ['2', '6', 'A', 'E'].contains(secondChar);
  }
}
