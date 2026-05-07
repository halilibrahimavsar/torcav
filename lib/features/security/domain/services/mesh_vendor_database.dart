/// Static OUI prefix database for popular consumer mesh-router vendors.
///
/// Used by [EvilTwinClassifier] to recognise mesh siblings whose BSSIDs
/// might not be sequential (some mesh systems randomise per-radio MACs)
/// but still come from the same vendor and ship the same SSID by design.
///
/// Sources: IEEE OUI registry + vendor documentation as of late 2025.
/// This list is intentionally short — false-classifying a generic Asus
/// router as "AiMesh" only matters when that router is paired with a
/// suspicious peer, and even then only adds a small mitigation weight.
class MeshVendorDatabase {
  const MeshVendorDatabase();

  /// Lower-case `aa:bb:cc` OUI prefixes mapped to a human label.
  static const Map<String, String> _ouiToVendor = {
    // ── Amazon Eero ─────────────────────────────────────────────────
    '40:b4:cd': 'Eero',
    '4c:cc:34': 'Eero',
    '74:80:ec': 'Eero',
    'ac:7e:8a': 'Eero',
    'd4:90:9c': 'Eero',
    'f0:9f:c2': 'Eero',

    // ── Google Nest Wifi / Google Wifi ──────────────────────────────
    '70:3a:cb': 'Google Nest Wifi',
    'b4:f1:da': 'Google Nest Wifi',
    'f4:f5:e8': 'Google Nest Wifi',
    '40:4e:36': 'Google Nest Wifi',

    // ── Netgear Orbi ────────────────────────────────────────────────
    'a0:40:a0': 'Netgear Orbi',
    '9c:3d:cf': 'Netgear Orbi',
    'e0:46:9a': 'Netgear Orbi',
    'b0:39:56': 'Netgear Orbi',

    // ── TP-Link Deco ────────────────────────────────────────────────
    'a4:2b:b0': 'TP-Link Deco',
    'b0:4e:26': 'TP-Link Deco',
    'c4:e9:84': 'TP-Link Deco',
    '50:c7:bf': 'TP-Link Deco',

    // ── Asus AiMesh (ZenWiFi / RT-series) ───────────────────────────
    '04:d4:c4': 'Asus AiMesh',
    '04:d9:f5': 'Asus AiMesh',
    '50:46:5d': 'Asus AiMesh',
    'ac:9e:17': 'Asus AiMesh',

    // ── Linksys Velop ───────────────────────────────────────────────
    '14:91:82': 'Linksys Velop',
    '24:f5:a2': 'Linksys Velop',
    'c0:56:27': 'Linksys Velop',
  };

  /// Returns the vendor label for [bssid] when its OUI prefix matches a
  /// known mesh family, otherwise null.
  String? lookup(String bssid) {
    final prefix = _prefix(bssid);
    if (prefix.isEmpty) return null;
    return _ouiToVendor[prefix];
  }

  /// True when both BSSIDs map to the same mesh vendor family. A pair from
  /// the same mesh family is *very* likely to be sibling nodes even when
  /// their MACs are not sequential.
  bool sameMeshFamily(String bssidA, String bssidB) {
    final a = lookup(bssidA);
    final b = lookup(bssidB);
    if (a == null || b == null) return false;
    return a == b;
  }

  String _prefix(String bssid) {
    final parts = bssid.split(':');
    if (parts.length < 3) return '';
    return parts.take(3).join(':').toLowerCase();
  }
}
