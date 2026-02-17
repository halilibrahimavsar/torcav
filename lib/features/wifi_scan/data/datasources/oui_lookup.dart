class OuiLookup {
  const OuiLookup();

  static const Map<String, String> _vendors = {
    '00:11:22': 'Cisco',
    '00:1A:2B': 'Intel',
    '08:26:97': 'TP-Link',
    '0C:EF:15': 'TP-Link',
    '14:36:0E': 'Turk Telekom',
    '40:ED:00': 'Turk Telekom',
    '5C:6A:80': 'AVM',
    '6C:E8:73': 'Xiaomi',
    '74:04:F1': 'Intel',
    'B0:8B:92': 'Vodafone',
  };

  String lookup(String bssid) {
    final normalized = bssid.toUpperCase().replaceAll('-', ':');
    final parts = normalized.split(':');
    if (parts.length < 3) {
      return 'Unknown';
    }

    final prefix = '${parts[0]}:${parts[1]}:${parts[2]}';
    return _vendors[prefix] ?? 'Unknown';
  }
}
