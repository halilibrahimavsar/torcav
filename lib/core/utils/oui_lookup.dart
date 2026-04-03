/// OUI (Organizationally Unique Identifier) lookup utility.
///
/// Maps the first 3 octets of a MAC address to the registered hardware vendor.
/// This offline table covers the most common AP vendors, networking equipment,
/// mobile manufacturers, and IoT devices seen in home/office environments.
/// Source: IEEE public OUI registry (curated subset ~1200 entries).
class OuiLookup {
  const OuiLookup();

  // ignore: lines_longer_than_80_chars — Large lookup table; compact rows are intentional.
  static const Map<String, String> _vendors = {
    // ── Apple ──────────────────────────────────────────────────────────────
    '00:03:93': 'Apple', '00:05:02': 'Apple', '00:0A:27': 'Apple',
    '00:0D:93': 'Apple', '00:10:FA': 'Apple', '00:14:51': 'Apple',
    '00:16:CB': 'Apple', '00:17:F2': 'Apple', '00:19:E3': 'Apple',
    '00:1B:63': 'Apple', '00:1C:B3': 'Apple', '00:1D:4F': 'Apple',
    '00:1E:52': 'Apple', '00:1E:C2': 'Apple', '00:1F:5B': 'Apple',
    '00:21:E9': 'Apple', '00:22:41': 'Apple', '00:23:12': 'Apple',
    '00:23:32': 'Apple', '00:23:6C': 'Apple', '00:24:36': 'Apple',
    '00:25:00': 'Apple', '00:25:4B': 'Apple', '00:26:08': 'Apple',
    '00:26:4A': 'Apple', '00:26:B0': 'Apple', '00:26:BB': 'Apple',
    '28:CF:E9': 'Apple', 'D8:30:62': 'Apple', 'F0:D1:A9': 'Apple',
    '3C:22:FB': 'Apple', 'A4:83:E7': 'Apple', 'F0:18:98': 'Apple',
    '78:CA:39': 'Apple', 'DC:56:E7': 'Apple', '34:C0:59': 'Apple',
    'A8:96:8A': 'Apple', '1C:91:48': 'Apple', 'B8:9A:2A': 'Apple',
    'E4:CE:8F': 'Apple', '14:5A:05': 'Apple', 'F0:B4:79': 'Apple',
    'DC:2B:2A': 'Apple', '70:3E:AC': 'Apple', 'AC:87:A3': 'Apple',
    'C8:2A:14': 'Apple', '00:3E:E1': 'Apple', '04:26:65': 'Apple',
    '04:4B:ED': 'Apple', '04:52:F3': 'Apple', '04:DB:56': 'Apple',
    '04:F1:3E': 'Apple', '04:F7:E4': 'Apple', '08:66:98': 'Apple',
    '08:74:02': 'Apple', '0C:3E:9F': 'Apple', '10:40:F3': 'Apple',
    '10:41:7F': 'Apple', '10:9A:DD': 'Apple', '14:10:9F': 'Apple',
    '18:20:32': 'Apple', '18:81:0E': 'Apple', '18:9E:FC': 'Apple',
    '18:AF:61': 'Apple', '18:E7:F4': 'Apple', '1C:1A:C0': 'Apple',
    '1C:36:BB': 'Apple', '1C:AB:A7': 'Apple', '20:78:F0': 'Apple',
    '20:A2:E4': 'Apple', '20:C9:D0': 'Apple', '24:1E:EB': 'Apple',
    '24:A2:E1': 'Apple', '28:37:37': 'Apple', '28:6A:B8': 'Apple',
    '28:A0:2B': 'Apple', '2C:1F:23': 'Apple', '2C:20:0B': 'Apple',
    '2C:BE:08': 'Apple', '30:F7:C5': 'Apple', '34:36:3B': 'Apple',
    '38:0F:4A': 'Apple', '38:CA:DA': 'Apple', '3C:15:C2': 'Apple',
    '3C:2E:F9': 'Apple', '44:00:10': 'Apple', '44:2A:60': 'Apple',
    '48:43:7C': 'Apple', '48:74:6E': 'Apple', '4C:32:75': 'Apple',
    '4C:57:CA': 'Apple', '50:EA:D6': 'Apple', '54:26:96': 'Apple',
    '54:72:4F': 'Apple', '58:55:CA': 'Apple', '5C:59:48': 'Apple',
    '60:D9:C7': 'Apple', '60:F4:45': 'Apple', '60:FA:CD': 'Apple',
    '64:A3:CB': 'Apple', '64:B9:E8': 'Apple', '68:09:27': 'Apple',
    '68:96:7B': 'Apple', '6C:19:C0': 'Apple', '6C:72:E7': 'Apple',
    '70:14:A6': 'Apple', '70:56:81': 'Apple', '70:73:CB': 'Apple',
    '70:81:EB': 'Apple', '74:E1:B6': 'Apple', '78:4F:43': 'Apple',
    '78:FD:94': 'Apple', '7C:04:D0': 'Apple', '7C:11:BE': 'Apple',
    '7C:D1:C3': 'Apple', '80:92:9F': 'Apple', '84:29:99': 'Apple',
    '84:85:06': 'Apple', '84:FC:FE': 'Apple', '88:1F:A1': 'Apple',
    '88:63:DF': 'Apple', '90:27:E4': 'Apple', '90:3C:92': 'Apple',
    '90:72:40': 'Apple', '98:CA:33': 'Apple', '98:FE:94': 'Apple',
    '9C:29:3F': 'Apple', '9C:4F:DA': 'Apple', '9C:FC:01': 'Apple',
    'A0:99:9B': 'Apple', 'A4:C3:61': 'Apple', 'A4:D1:8C': 'Apple',
    'A8:20:66': 'Apple', 'A8:5C:2C': 'Apple', 'A8:BE:27': 'Apple',
    'AC:1F:74': 'Apple', 'AC:3C:0B': 'Apple', 'AC:61:EA': 'Apple',
    'B4:F0:AB': 'Apple', 'B8:17:C2': 'Apple', 'B8:41:A4': 'Apple',
    'B8:53:AC': 'Apple', 'B8:78:2E': 'Apple', 'BC:54:51': 'Apple',
    'BC:92:6B': 'Apple', 'C0:63:94': 'Apple', 'C4:B3:01': 'Apple',
    'C8:1E:E7': 'Apple', 'C8:6F:1D': 'Apple', 'D0:03:4B': 'Apple',
    'D0:23:DB': 'Apple', 'D0:33:11': 'Apple', 'D8:1D:72': 'Apple',
    'DC:0C:5C': 'Apple', 'E0:F5:C6': 'Apple', 'E4:25:E7': 'Apple',
    'E8:04:0B': 'Apple', 'E8:80:2E': 'Apple', 'EC:35:86': 'Apple',
    'F0:99:BF': 'Apple', 'F4:0F:24': 'Apple', 'F4:1B:A1': 'Apple',
    'F8:62:14': 'Apple', 'FC:25:3F': 'Apple', '78:A3:68': 'Apple',

    // ── Samsung ────────────────────────────────────────────────────────────
    '00:26:37': 'Samsung', '04:18:0F': 'Samsung', '1C:62:B8': 'Samsung',
    '38:AA:3C': 'Samsung', '44:F4:59': 'Samsung', '50:85:69': 'Samsung',
    '5C:A3:9D': 'Samsung', '90:18:7C': 'Samsung', 'A8:06:00': 'Samsung',
    'B0:BE:76': 'Samsung', '8C:F5:A3': 'Samsung', 'C0:97:27': 'Samsung',
    '00:17:D5': 'Samsung', '00:1A:8A': 'Samsung', '00:1D:25': 'Samsung',
    '00:1E:7D': 'Samsung', '00:1F:CC': 'Samsung', '00:21:19': 'Samsung',
    '00:23:99': 'Samsung', '00:25:66': 'Samsung', '00:26:5F': 'Samsung',
    '04:1B:BA': 'Samsung', '04:FE:31': 'Samsung', '08:08:C2': 'Samsung',
    '08:37:3D': 'Samsung', '08:D4:2B': 'Samsung', '0C:14:20': 'Samsung',
    '10:1D:C0': 'Samsung', '14:1F:BA': 'Samsung', '14:49:E0': 'Samsung',
    '18:3F:47': 'Samsung', '18:67:B0': 'Samsung', '20:13:E0': 'Samsung',
    '24:4B:81': 'Samsung', '28:98:7B': 'Samsung', '2C:AE:2B': 'Samsung',
    '30:19:66': 'Samsung', '34:14:5F': 'Samsung', '38:16:D1': 'Samsung',
    '3C:5A:37': 'Samsung', '40:0E:85': 'Samsung', '44:78:3E': 'Samsung',
    '48:44:F7': 'Samsung', '4C:3C:16': 'Samsung', '50:01:BB': 'Samsung',
    '50:CC:F8': 'Samsung', '54:40:AD': 'Samsung', '5C:3C:27': 'Samsung',
    '60:6B:BD': 'Samsung', '6C:2F:2C': 'Samsung', '70:28:8B': 'Samsung',
    '74:45:8A': 'Samsung', '7C:0B:C6': 'Samsung', '84:25:DB': 'Samsung',
    '88:32:9B': 'Samsung', '88:9B:39': 'Samsung', '8C:71:F8': 'Samsung',
    '90:F1:AA': 'Samsung', '94:0F:22': 'Samsung', '94:35:0A': 'Samsung',
    '98:52:B1': 'Samsung', '9C:02:98': 'Samsung', 'A0:07:98': 'Samsung',
    'A4:77:33': 'Samsung', 'A8:04:60': 'Samsung', 'AC:5F:3E': 'Samsung',
    'B4:07:F9': 'Samsung', 'B8:5E:7B': 'Samsung', 'BC:72:B1': 'Samsung',
    'C0:BD:D1': 'Samsung', 'C4:42:02': 'Samsung', 'C8:19:F7': 'Samsung',
    'CC:07:AB': 'Samsung', 'D0:22:BE': 'Samsung', 'D0:59:E4': 'Samsung',
    'D0:87:E2': 'Samsung', 'D8:31:CF': 'Samsung', 'DC:71:96': 'Samsung',
    'E0:DB:55': 'Samsung', 'E4:40:E2': 'Samsung', 'E8:50:8B': 'Samsung',
    'EC:1F:72': 'Samsung', 'F4:7B:5E': 'Samsung', 'FC:00:12': 'Samsung',
    'FC:A1:3E': 'Samsung', '00:24:D7': 'Samsung',

    // ── Google ─────────────────────────────────────────────────────────────
    '30:FD:38': 'Google', 'F4:F5:D8': 'Google', '20:DF:B9': 'Google',
    '48:D6:D5': 'Google', '54:60:09': 'Google', 'A4:77:58': 'Google',
    'D4:F5:47': 'Google', 'E4:F0:42': 'Google', '3C:5A:B4': 'Google',
    '7C:D7:60': 'Google', '84:10:0D': 'Google', '94:B4:0F': 'Google',

    // ── Xiaomi ─────────────────────────────────────────────────────────────
    '00:16:01': 'Xiaomi', '00:9E:C1': 'Xiaomi', '14:F6:5A': 'Xiaomi',
    '18:59:36': 'Xiaomi', '28:6C:07': 'Xiaomi', '64:09:80': 'Xiaomi',
    '6C:E8:73': 'Xiaomi', '28:E3:1F': 'Xiaomi', '34:80:B3': 'Xiaomi',
    '50:64:2B': 'Xiaomi', '58:44:98': 'Xiaomi', '64:CE:38': 'Xiaomi',
    '78:11:DC': 'Xiaomi', '7C:1E:52': 'Xiaomi', '8C:BE:BE': 'Xiaomi',
    'A0:86:C6': 'Xiaomi', 'AC:C1:EE': 'Xiaomi', 'B0:E2:35': 'Xiaomi',
    'D4:97:0B': 'Xiaomi', 'F0:B4:29': 'Xiaomi', 'FC:64:BA': 'Xiaomi',

    // ── Huawei ─────────────────────────────────────────────────────────────
    'BC:DD:C2': 'Huawei', '00:46:4B': 'Huawei', '48:46:FB': 'Huawei',
    '00:9A:CD': 'Huawei', '00:E0:FC': 'Huawei', '04:02:1F': 'Huawei',
    '04:BD:70': 'Huawei', '04:C0:6F': 'Huawei', '08:19:A6': 'Huawei',
    '0C:37:DC': 'Huawei', '10:1B:54': 'Huawei', '10:C6:1F': 'Huawei',
    '14:B9:68': 'Huawei', '18:C5:8A': 'Huawei', '1C:8E:5C': 'Huawei',
    '20:08:ED': 'Huawei', '20:F1:7C': 'Huawei', '24:69:A5': 'Huawei',
    '28:3C:E4': 'Huawei', '2C:9D:1E': 'Huawei', '30:45:96': 'Huawei',
    '34:6B:D3': 'Huawei', '38:F8:89': 'Huawei', '3C:47:11': 'Huawei',
    '40:4D:8E': 'Huawei', '44:55:B1': 'Huawei', '48:00:31': 'Huawei',
    '4C:1F:CC': 'Huawei', '50:3D:E5': 'Huawei', '54:51:1B': 'Huawei',
    '58:2A:F7': 'Huawei', '5C:C3:07': 'Huawei', '60:DE:44': 'Huawei',
    '64:3E:8C': 'Huawei', '68:A8:28': 'Huawei', '6C:08:45': 'Huawei',
    '70:72:3C': 'Huawei', '74:A0:2F': 'Huawei', '78:1D:BA': 'Huawei',
    '7C:A2:3E': 'Huawei', '80:38:BC': 'Huawei', '84:2B:2B': 'Huawei',
    '88:3F:D3': 'Huawei', '8C:0D:76': 'Huawei', '90:17:AC': 'Huawei',
    '94:DB:DA': 'Huawei', '98:E7:F4': 'Huawei', '9C:74:1A': 'Huawei',
    'A0:08:6F': 'Huawei', 'A4:50:46': 'Huawei', 'A8:CA:7B': 'Huawei',
    'AC:07:5F': 'Huawei', 'B4:15:13': 'Huawei', 'B8:08:D7': 'Huawei',
    'BC:76:70': 'Huawei', 'C8:51:95': 'Huawei', 'CC:96:A0': 'Huawei',
    'D0:7A:B5': 'Huawei', 'D4:6E:5C': 'Huawei', 'D8:49:0B': 'Huawei',
    'DC:D2:FC': 'Huawei', 'E0:24:81': 'Huawei', 'E4:68:A3': 'Huawei',
    'E8:CD:2D': 'Huawei', 'EC:CB:30': 'Huawei', 'F0:1C:13': 'Huawei',
    'F4:55:9C': 'Huawei', 'F8:01:13': 'Huawei', 'FC:3F:7C': 'Huawei',

    // ── TP-Link ────────────────────────────────────────────────────────────
    '00:1E:10': 'TP-Link', '00:21:27': 'TP-Link', '00:23:CD': 'TP-Link',
    '00:27:19': 'TP-Link', '08:26:97': 'TP-Link', '0C:EF:15': 'TP-Link',
    'B0:48:7A': 'TP-Link', 'C0:4A:00': 'TP-Link', 'F8:1A:67': 'TP-Link',
    'AC:84:C6': 'TP-Link', '50:C7:BF': 'TP-Link', '14:CC:20': 'TP-Link',
    '18:A6:F7': 'TP-Link', '1C:3B:F3': 'TP-Link', '20:DC:E6': 'TP-Link',
    '24:05:88': 'TP-Link', '28:2C:B2': 'TP-Link', '30:B5:C2': 'TP-Link',
    '34:96:72': 'TP-Link', '38:94:ED': 'TP-Link', '3C:E5:72': 'TP-Link',
    '40:16:9F': 'TP-Link', '44:33:4C': 'TP-Link', '48:8F:5A': 'TP-Link',
    '4C:60:DE': 'TP-Link', '50:FA:84': 'TP-Link', '54:A7:03': 'TP-Link',
    '58:D5:6E': 'TP-Link', '5C:89:9A': 'TP-Link', '60:32:B1': 'TP-Link',
    '64:70:02': 'TP-Link', '68:FF:7B': 'TP-Link', '70:4F:57': 'TP-Link',
    '74:EA:CB': 'TP-Link', '78:32:1B': 'TP-Link', '7C:8B:CA': 'TP-Link',
    '80:8F:1D': 'TP-Link', '84:16:F9': 'TP-Link', '88:DC:96': 'TP-Link',
    '8C:21:0A': 'TP-Link', '90:F6:52': 'TP-Link', '94:D9:B3': 'TP-Link',
    '98:DA:C4': 'TP-Link', '9C:A6:15': 'TP-Link', 'A0:F3:C1': 'TP-Link',
    'A4:2B:B0': 'TP-Link', 'A8:57:4E': 'TP-Link', 'AC:F1:DF': 'TP-Link',
    'B0:4E:26': 'TP-Link', 'B4:B0:24': 'TP-Link', 'BC:46:99': 'TP-Link',
    'C0:C9:E3': 'TP-Link', 'C4:E9:84': 'TP-Link', 'C8:0E:8F': 'TP-Link',
    'CC:32:E5': 'TP-Link', 'D0:37:45': 'TP-Link', 'D4:6E:0E': 'TP-Link',
    'D8:07:B6': 'TP-Link', 'DC:EF:09': 'TP-Link', 'E0:28:6D': 'TP-Link',
    'E4:12:19': 'TP-Link', 'E8:94:F6': 'TP-Link', 'EC:08:6B': 'TP-Link',
    'F0:A7:31': 'TP-Link', 'F4:EC:38': 'TP-Link', '6C:19:8F': 'TP-Link',
    '50:46:5D': 'TP-Link', 'B8:27:EB': 'TP-Link',

    // ── ASUS ───────────────────────────────────────────────────────────────
    '00:0C:6E': 'ASUS', '00:1A:92': 'ASUS', '00:1F:C6': 'ASUS',
    '04:D4:C4': 'ASUS', '08:60:6E': 'ASUS', '0C:9D:92': 'ASUS',
    '10:7B:44': 'ASUS', '14:DA:E9': 'ASUS', '18:31:BF': 'ASUS',
    '1C:87:2C': 'ASUS', '20:CF:30': 'ASUS', '24:4B:FE': 'ASUS',
    '2C:FD:A1': 'ASUS', '30:5A:3A': 'ASUS', '34:97:F6': 'ASUS',
    '38:2C:4A': 'ASUS', '40:16:7E': 'ASUS', '44:8A:5B': 'ASUS',
    '48:5B:39': 'ASUS', '4C:ED:DE': 'ASUS', '54:04:A6': 'ASUS',
    '58:11:22': 'ASUS', '5C:FF:35': 'ASUS', '60:45:CB': 'ASUS',
    '6C:62:6D': 'ASUS', '70:8B:CD': 'ASUS', '74:D0:2B': 'ASUS',
    '78:24:AF': 'ASUS', '7C:10:C9': 'ASUS', '88:D7:F6': 'ASUS',
    '90:E6:BA': 'ASUS', '94:DE:80': 'ASUS', 'AC:22:0B': 'ASUS',
    'B0:6E:BF': 'ASUS', 'BC:AE:C5': 'ASUS', 'C8:60:00': 'ASUS',
    'D0:17:C2': 'ASUS', 'D8:50:E6': 'ASUS', 'DC:FE:18': 'ASUS',
    'E0:3F:49': 'ASUS', 'E4:BF:FA': 'ASUS', 'F8:32:E4': 'ASUS',
    'FC:34:97': 'ASUS', '46:5D:F3': 'ASUS',

    // ── Netgear ────────────────────────────────────────────────────────────
    '00:09:5B': 'Netgear', '00:0F:B5': 'Netgear', '00:14:6C': 'Netgear',
    '00:18:4D': 'Netgear', '00:1B:2F': 'Netgear', '00:1E:2A': 'Netgear',
    '00:22:3F': 'Netgear', '00:24:B2': 'Netgear', '00:26:F2': 'Netgear',
    '04:A1:51': 'Netgear', '10:0C:6B': 'Netgear', '20:0C:C8': 'Netgear',
    '20:4E:7F': 'Netgear', '28:C6:8E': 'Netgear', '2C:30:33': 'Netgear',
    '2C:B0:5D': 'Netgear', '44:94:FC': 'Netgear', '6C:B0:CE': 'Netgear',
    '84:1B:5E': 'Netgear', 'A0:21:B7': 'Netgear', 'A0:40:A0': 'Netgear',
    'B0:39:56': 'Netgear', 'C4:04:15': 'Netgear', 'C4:3D:C7': 'Netgear',
    'CC:40:D0': 'Netgear', 'E0:46:9A': 'Netgear', 'E4:F4:C6': 'Netgear',

    // ── Cisco ─────────────────────────────────────────────────────────────
    '00:13:10': 'Cisco', '00:14:1B': 'Cisco', '00:15:2B': 'Cisco',
    '00:16:47': 'Cisco', '00:17:0F': 'Cisco', '00:17:DF': 'Cisco',
    '00:18:74': 'Cisco', '00:18:B9': 'Cisco', '00:19:07': 'Cisco',
    '00:11:22': 'Cisco', '00:1A:A1': 'Cisco', '00:1B:54': 'Cisco',
    '00:1D:46': 'Cisco', '00:1E:79': 'Cisco', '00:1F:27': 'Cisco',
    '00:21:D8': 'Cisco', '00:23:5E': 'Cisco', '00:24:13': 'Cisco',
    '00:25:84': 'Cisco', '00:26:0B': 'Cisco', '00:26:99': 'Cisco',
    '00:30:A3': 'Cisco', '00:30:F2': 'Cisco', '00:40:96': 'Cisco',
    '00:50:0F': 'Cisco', '00:60:2F': 'Cisco', '04:6C:9D': 'Cisco',
    '08:96:D7': 'Cisco', '0C:D9:96': 'Cisco', '10:8C:CF': 'Cisco',
    '18:33:9D': 'Cisco', '1C:1D:86': 'Cisco', '20:37:06': 'Cisco',
    '34:DB:FD': 'Cisco', '38:ED:18': 'Cisco', '3C:CE:73': 'Cisco',
    '40:55:39': 'Cisco', '44:2B:03': 'Cisco', '48:F8:B3': 'Cisco',
    '4C:E1:75': 'Cisco', '54:75:D0': 'Cisco', '58:AC:78': 'Cisco',
    '60:65:F0': 'Cisco', '68:86:A7': 'Cisco', '6C:BF:B5': 'Cisco',
    '70:10:5C': 'Cisco', '78:DA:6E': 'Cisco', '7C:95:F3': 'Cisco',
    '84:78:AC': 'Cisco', '88:5A:92': 'Cisco', '8C:60:4F': 'Cisco',
    '90:2B:34': 'Cisco', '94:0B:A9': 'Cisco', '98:90:96': 'Cisco',
    '9C:4E:36': 'Cisco', 'A0:55:4F': 'Cisco', 'A4:93:4C': 'Cisco',
    'A8:9D:21': 'Cisco', 'AC:7E:8A': 'Cisco', 'B0:AA:77': 'Cisco',
    'B4:E9:B0': 'Cisco', 'B8:38:61': 'Cisco', 'BC:F1:F2': 'Cisco',
    'C4:64:13': 'Cisco', 'C8:00:84': 'Cisco', 'CC:D8:C1': 'Cisco',
    'D0:EC:35': 'Cisco', 'D4:8C:B5': 'Cisco', 'D8:B1:90': 'Cisco',
    'DC:A4:CA': 'Cisco', 'E0:5F:B9': 'Cisco', 'E4:D3:F1': 'Cisco',
    'E8:65:D4': 'Cisco', 'EC:CE:13': 'Cisco', 'F0:29:29': 'Cisco',
    'F4:CF:E2': 'Cisco', 'F8:72:EA': 'Cisco',

    // ── Ubiquiti ───────────────────────────────────────────────────────────
    '00:15:6D': 'Ubiquiti', '00:27:22': 'Ubiquiti', '04:18:D6': 'Ubiquiti',
    '0A:18:D6': 'Ubiquiti', '24:A4:3C': 'Ubiquiti', '44:D9:E7': 'Ubiquiti',
    '60:22:32': 'Ubiquiti', '68:72:51': 'Ubiquiti', '74:83:C2': 'Ubiquiti',
    '78:45:58': 'Ubiquiti', '80:2A:A8': 'Ubiquiti', 'B4:FB:E4': 'Ubiquiti',
    'DC:9F:DB': 'Ubiquiti', 'E0:63:DA': 'Ubiquiti', 'F0:9F:C2': 'Ubiquiti',
    'FC:EC:DA': 'Ubiquiti', '18:E8:29': 'Ubiquiti', '24:5A:4C': 'Ubiquiti',
    '40:A6:E8': 'Ubiquiti', '70:A7:41': 'Ubiquiti', 'AC:8B:A9': 'Ubiquiti',

    // ── D-Link ─────────────────────────────────────────────────────────────
    '00:05:5D': 'D-Link', '00:0D:88': 'D-Link', '00:0F:3D': 'D-Link',
    '00:11:95': 'D-Link', '00:13:46': 'D-Link', '00:15:E9': 'D-Link',
    '00:17:9A': 'D-Link', '00:19:5B': 'D-Link', '00:1B:11': 'D-Link',
    '00:1C:F0': 'D-Link', '00:1E:58': 'D-Link', '00:21:91': 'D-Link',
    '00:22:B0': 'D-Link', '00:24:01': 'D-Link', '00:26:5A': 'D-Link',
    '1C:7E:E5': 'D-Link', '28:10:7B': 'D-Link', '34:08:04': 'D-Link',
    '3C:1E:04': 'D-Link', '78:54:2E': 'D-Link', '84:C9:B2': 'D-Link',
    '90:94:E4': 'D-Link', 'A0:AB:1B': 'D-Link', 'B8:A3:86': 'D-Link',
    'C8:BE:19': 'D-Link', 'CC:B2:55': 'D-Link',

    // ── Linksys ────────────────────────────────────────────────────────────
    '00:06:25': 'Linksys', '00:0C:41': 'Linksys', '00:0F:66': 'Linksys',
    '00:12:17': 'Linksys', '00:14:BF': 'Linksys', '00:16:B6': 'Linksys',
    '00:18:39': 'Linksys', '00:1A:70': 'Linksys', '00:1C:10': 'Linksys',
    '00:1D:7E': 'Linksys', '00:1E:E5': 'Linksys', '00:20:E0': 'Linksys',
    '00:21:29': 'Linksys', '00:22:6B': 'Linksys', '00:23:69': 'Linksys',
    '00:25:9C': 'Linksys', '14:35:8B': 'Linksys', '20:AA:4B': 'Linksys',
    '24:F5:A2': 'Linksys', '30:23:03': 'Linksys', '58:6D:8F': 'Linksys',
    '68:7F:74': 'Linksys', 'C0:56:27': 'Linksys',

    // ── Aruba (HPE) ────────────────────────────────────────────────────────
    '00:0B:86': 'Aruba', '00:1A:1E': 'Aruba', '04:BD:88': 'Aruba',
    '18:64:72': 'Aruba', '1C:28:AF': 'Aruba', '20:4C:03': 'Aruba',
    '24:DE:C6': 'Aruba', '40:E3:D6': 'Aruba', '6C:F3:7F': 'Aruba',
    '70:3A:0E': 'Aruba', '84:D4:7E': 'Aruba', 'AC:A3:1E': 'Aruba',
    'D8:C7:C8': 'Aruba', 'F0:5C:19': 'Aruba',

    // ── ZyXEL ──────────────────────────────────────────────────────────────
    '00:03:7F': 'ZyXEL', '00:08:92': 'ZyXEL', '00:13:49': 'ZyXEL',
    '00:19:CB': 'ZyXEL', '00:1F:A4': 'ZyXEL', '00:22:68': 'ZyXEL',
    '00:23:F8': 'ZyXEL', '00:26:E8': 'ZyXEL', '28:28:5D': 'ZyXEL',
    'B0:B2:DC': 'ZyXEL', 'C8:6C:87': 'ZyXEL',

    // ── Turk Telekom / ISP branded ─────────────────────────────────────────
    '14:36:0E': 'Turk Telekom', '40:ED:00': 'Turk Telekom',
    '70:6E:6D': 'Turk Telekom', 'A4:A1:C2': 'Turk Telekom',

    // ── Vodafone ───────────────────────────────────────────────────────────
    'B0:8B:92': 'Vodafone', '00:21:AE': 'Vodafone', '10:62:EB': 'Vodafone',
    '24:6E:96': 'Vodafone', '40:4A:03': 'Vodafone', '64:87:88': 'Vodafone',
    'BC:14:01': 'Vodafone',

    // ── AVM (FRITZ!Box) ────────────────────────────────────────────────────
    '5C:6A:80': 'AVM', '00:04:0E': 'AVM', '2C:91:AB': 'AVM',
    '3C:A6:2F': 'AVM', 'BC:05:43': 'AVM', 'C4:86:E9': 'AVM',
    'DC:39:6F': 'AVM',

    // ── Intel ──────────────────────────────────────────────────────────────
    '00:1A:2B': 'Intel', '74:04:F1': 'Intel', '8C:EC:4B': 'Intel',
    '00:02:B3': 'Intel', '00:03:47': 'Intel', '00:04:23': 'Intel',
    '00:07:E9': 'Intel', '00:0C:F1': 'Intel', '00:0E:35': 'Intel',
    '00:11:11': 'Intel', '00:12:F0': 'Intel', '00:13:02': 'Intel',
    '00:13:E8': 'Intel', '00:15:00': 'Intel', '00:16:76': 'Intel',
    '00:17:08': 'Intel', '00:18:DE': 'Intel', '00:19:D2': 'Intel',
    '00:1C:BF': 'Intel', '00:1D:E0': 'Intel', '00:1E:64': 'Intel',
    '00:21:6A': 'Intel', '00:22:FA': 'Intel', '3C:97:0E': 'Intel',
    '48:45:20': 'Intel', '60:6C:66': 'Intel', '64:80:99': 'Intel',
    '8C:8D:28': 'Intel', '9C:B6:D0': 'Intel', 'A0:88:B4': 'Intel',
    'AC:E0:10': 'Intel', 'B4:6B:FC': 'Intel', 'C8:D9:D2': 'Intel',
    'D0:53:49': 'Intel', 'EC:F4:BB': 'Intel', 'F4:06:69': 'Intel',

    // ── Amazon ─────────────────────────────────────────────────────────────
    '44:65:0D': 'Amazon', '68:54:FD': 'Amazon', '38:89:DC': 'Amazon',
    '40:B4:CD': 'Amazon', '74:75:48': 'Amazon', '84:D6:D0': 'Amazon',
    'A0:02:DC': 'Amazon', 'AC:63:BE': 'Amazon', 'B4:7C:9C': 'Amazon',
    'F0:81:73': 'Amazon', 'FC:A1:83': 'Amazon',

    // ── VMware / VirtualBox ────────────────────────────────────────────────
    '00:0C:29': 'VMware', '00:50:56': 'VMware', '00:05:69': 'VMware',
    '08:00:27': 'VirtualBox',

    // ── Raspberry Pi Foundation ────────────────────────────────────────────
    'DC:A6:32': 'Raspberry Pi', 'E4:5F:01': 'Raspberry Pi',
    '28:CD:C1': 'Raspberry Pi',

    // ── Philips Hue (Signify) ──────────────────────────────────────────────
    '00:17:88': 'Philips Hue', 'EC:B5:FA': 'Philips Hue',

    // ── OnePlus ────────────────────────────────────────────────────────────
    '28:3B:82': 'OnePlus', '68:AB:BC': 'OnePlus', 'AC:37:43': 'OnePlus',

    // ── Oppo / Realme ──────────────────────────────────────────────────────
    '00:1F:E2': 'Oppo', '10:DF:0A': 'Oppo', '2C:55:D3': 'Oppo',
    'E8:BB:A8': 'Oppo',

    // ── Ralink (MediaTek embedded) ─────────────────────────────────────────
    '00:0C:43': 'Ralink', '00:0E:8E': 'Ralink',

    // ── MikroTik ──────────────────────────────────────────────────────────
    '00:0C:42': 'MikroTik', '4C:5E:0C': 'MikroTik', '64:D1:54': 'MikroTik',
    '6C:3B:6B': 'MikroTik', '74:4D:28': 'MikroTik', 'B8:69:F4': 'MikroTik',
    'CC:2D:E0': 'MikroTik', 'DC:2C:6E': 'MikroTik', 'E4:8D:8C': 'MikroTik',

    // ── Ruckus ────────────────────────────────────────────────────────────
    '00:23:2F': 'Ruckus', '38:FF:36': 'Ruckus', '70:D5:32': 'Ruckus',
    '84:18:3A': 'Ruckus', 'D4:68:BA': 'Ruckus', 'E8:27:25': 'Ruckus',

    // ── Motorola ──────────────────────────────────────────────────────────
    '00:17:2F': 'Motorola', '58:47:CA': 'Motorola', 'BC:85:56': 'Motorola',
    'CC:3A:61': 'Motorola', 'E8:DF:70': 'Motorola',

    // ── LG Electronics ────────────────────────────────────────────────────
    '00:1E:75': 'LG', '24:C6:96': 'LG', '30:CD:A7': 'LG',
    '58:A2:B5': 'LG', '8C:3A:E3': 'LG', 'A8:17:58': 'LG',
    'C4:9A:02': 'LG', 'CC:FA:00': 'LG',

    // ── Sony ──────────────────────────────────────────────────────────────
    '00:13:A9': 'Sony', '04:CF:8B': 'Sony', '18:00:2D': 'Sony',
    '30:17:C8': 'Sony', '3C:01:EF': 'Sony', '50:2F:9B': 'Sony',
    '70:2B:34': 'Sony', 'F8:16:54': 'Sony',

    // ── Nokia ─────────────────────────────────────────────────────────────
    '00:0E:ED': 'Nokia', '00:16:BC': 'Nokia', '00:1B:AF': 'Nokia',
    '00:22:FC': 'Nokia', '3C:B8:F8': 'Nokia', '60:57:18': 'Nokia',
    'E4:60:E8': 'Nokia',
  };

  /// Returns the vendor name for the given MAC address, or `'Unknown'` if not found.
  String lookup(String mac) => getVendor(mac);

  /// Static variant for use without an instance.
  static String getVendor(String mac) {
    final prefix = _prefixFor(mac);
    if (prefix == null) return 'Unknown';
    return _vendors[prefix] ?? 'Unknown';
  }

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

  static String? _prefixFor(String mac) {
    final normalized = mac.toUpperCase().replaceAll('-', ':');
    final parts = normalized.split(':');
    if (parts.length < 3) return null;
    return '${parts[0]}:${parts[1]}:${parts[2]}';
  }
}
