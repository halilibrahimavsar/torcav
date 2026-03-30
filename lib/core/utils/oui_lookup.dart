class OuiLookup {
  static const Map<String, String> _vendors = {
    '00:03:93': 'Apple',
    '00:05:02': 'Apple',
    '00:0A:27': 'Apple',
    '00:0D:93': 'Apple',
    '00:10:FA': 'Apple',
    '00:14:51': 'Apple',
    '00:16:CB': 'Apple',
    '00:17:F2': 'Apple',
    '00:19:E3': 'Apple',
    '00:1B:63': 'Apple',
    '00:1C:B3': 'Apple',
    '00:1D:4F': 'Apple',
    '00:1E:52': 'Apple',
    '00:1E:C2': 'Apple',
    '00:1F:5B': 'Apple',
    '00:21:E9': 'Apple',
    '00:22:41': 'Apple',
    '00:23:12': 'Apple',
    '00:23:32': 'Apple',
    '00:23:6C': 'Apple',
    '00:24:36': 'Apple',
    '00:25:00': 'Apple',
    '00:25:4B': 'Apple',
    '00:26:08': 'Apple',
    '00:26:4A': 'Apple',
    '00:26:B0': 'Apple',
    '00:26:BB': 'Apple',
    '28:CF:E9': 'Apple',
    'D8:30:62': 'Apple',
    'F0:D1:A9': 'Apple',
    
    '00:24:D7': 'Samsung',
    '00:26:37': 'Samsung',
    '04:18:0F': 'Samsung',
    '1C:62:B8': 'Samsung',
    '38:AA:3C': 'Samsung',
    '44:F4:59': 'Samsung',
    '50:85:69': 'Samsung',
    '5C:A3:9D': 'Samsung',
    '90:18:7C': 'Samsung',
    'A8:06:00': 'Samsung',
    
    '00:0C:29': 'VMware',
    '00:50:56': 'VMware',
    '00:05:69': 'VMware',
    '08:00:27': 'VirtualBox',
    
    '00:13:10': 'Cisco',
    '00:14:1B': 'Cisco',
    '00:15:2B': 'Cisco',
    '00:16:47': 'Cisco',
    '00:17:0F': 'Cisco',
    '00:17:DF': 'Cisco',
    '00:18:74': 'Cisco',
    '00:18:B9': 'Cisco',
    '00:19:07': 'Cisco',
    
    '00:0C:43': 'Ralink',
    '00:0E:8E': 'Ralink',
    
    '00:1E:10': 'Shenzhen TP-LINK',
    '00:21:27': 'Shenzhen TP-LINK',
    '00:23:CD': 'Shenzhen TP-LINK',
    '00:27:19': 'Shenzhen TP-LINK',
    'B0:48:7A': 'TP-LINK',
    'C0:4A:00': 'TP-LINK',
    
    '00:16:01': 'Xiaomi',
    '00:9E:C1': 'Xiaomi',
    '14:F6:5A': 'Xiaomi',
    '18:59:36': 'Xiaomi',
    '28:6C:07': 'Xiaomi',
    '64:09:80': 'Xiaomi',
  };

  static String getVendor(String mac) {
    if (mac.length < 8) return 'Unknown';
    final prefix = mac.substring(0, 8).toUpperCase().replaceAll('-', ':');
    return _vendors[prefix] ?? 'Unknown Vendor';
  }

  static bool isSuspicious(String mac) {
    // Locally administered addresses (LAA) often used for MAC randomization/spoofing
    // The second character of the first byte is 2, 6, A, or E.
    // x2:xx:xx:xx:xx:xx, x6:xx:xx:xx:xx:xx, xA:xx:xx:xx:xx:xx, xE:xx:xx:xx:xx:xx
    if (mac.length < 2) return false;
    final secondChar = mac[1].toUpperCase();
    return ['2', '6', 'A', 'E'].contains(secondChar);
  }
}
