/// Vendor-agnostic router hardening checklist.
///
/// Order matters: items appear in the wizard in declaration order, so the
/// list flows from highest-impact (admin password) to nice-to-have. Each
/// item is independent — users can tackle them in any order.
enum HardeningCheck {
  changeAdminPassword,
  useWpa3OrWpa2Aes,
  disableWps,
  enablePmf,
  enableGuestNetwork,
  disableRemoteAdmin,
  updateFirmware,
  strongPassphrase,
}

class HardeningCheckMeta {
  final HardeningCheck id;

  /// One-line headline.
  final String title;

  /// 1-2 sentence WHY this matters. Written for non-technical readers.
  final String body;

  /// Step-by-step walkthrough. Each entry is one numbered step. Written
  /// for someone who has never logged into a router admin panel before —
  /// be explicit about menu names, common variations, and where things go.
  final List<String> steps;

  /// Common menu labels across vendors (TP-Link, Asus, Netgear, Huawei,
  /// Mercusys, Tenda, Mi). Helps the user recognise the right page when
  /// vendors use different wording.
  final List<String> menuHints;

  /// Critical = security cannot be considered hardened without this. Used to
  /// boost prominence in the UI.
  final bool critical;

  const HardeningCheckMeta({
    required this.id,
    required this.title,
    required this.body,
    required this.steps,
    this.menuHints = const [],
    this.critical = false,
  });
}

const hardeningCatalog = <HardeningCheckMeta>[
  HardeningCheckMeta(
    id: HardeningCheck.changeAdminPassword,
    title: 'Change router admin password',
    critical: true,
    body:
        'Default admin credentials (admin/admin, admin/password) are publicly '
        'documented. Anyone on your Wi-Fi can open the admin panel and '
        'rewrite settings — DNS hijack, redirect traffic, lock you out.',
    menuHints: [
      'Administration',
      'System',
      'Maintenance',
      'System Tools',
      'Account',
    ],
    steps: [
      'Tap the big OPEN ADMIN PANEL button at the top of this page. Your '
          'browser will open the router login page. (If it asks "open with", '
          'pick your usual browser like Chrome or Firefox.)',
      'Log in. If you have never logged in: try "admin" as username and '
          '"admin" or "password" as password. Some routers print the default '
          'on a sticker on the back of the device.',
      'Find a menu named "Administration", "System", "Maintenance" or '
          '"Account" (names vary by brand — see the hints below).',
      'Inside that menu look for "Login password", "Admin password" or '
          '"Change password".',
      'Pick a NEW password — at least 12 characters, mix uppercase, '
          'lowercase, numbers and a symbol. Do NOT reuse a password from '
          'email, banking or social media.',
      'Save / Apply. The router may reboot for ~30 seconds — that is normal.',
      'Write the new password down somewhere safe (password manager, locked '
          'drawer). If you forget it, the only fix is a factory reset, which '
          'wipes every other setting.',
      'Once saved, come back here and tap MARK DONE.',
    ],
  ),
  HardeningCheckMeta(
    id: HardeningCheck.useWpa3OrWpa2Aes,
    title: 'Use WPA3, fall back to WPA2-AES',
    critical: true,
    body:
        'WPA3 is the modern Wi-Fi encryption standard. If your router is too '
        'old for WPA3, WPA2-AES is acceptable. WPA/TKIP and WEP can be '
        'cracked in minutes by anyone nearby.',
    menuHints: [
      'Wireless',
      'Wi-Fi',
      'Wi-Fi Settings',
      'Wireless Security',
      'WLAN',
    ],
    steps: [
      'Open the admin panel using the button at the top.',
      'Find the wireless section: "Wireless", "Wi-Fi" or "WLAN".',
      'Look for a security or encryption setting — usually called '
          '"Security mode", "Authentication" or "Encryption".',
      'Choose the strongest option in this order: WPA3-Personal > '
          'WPA2/WPA3 mixed > WPA2-Personal (AES). Avoid anything labelled '
          '"WPA-PSK", "TKIP", "WEP" or "Open" — these are insecure.',
      'If you set WPA3-Personal and an old device (smart bulb, printer, '
          'older phone) stops working, switch to "WPA2/WPA3 mixed" — that '
          'lets old gear connect while new devices still use WPA3.',
      'If you have separate 2.4 GHz and 5 GHz settings, change BOTH bands.',
      'Save / Apply. Your devices may briefly disconnect — they will '
          'rejoin in a few seconds.',
      'Come back here and tap MARK DONE.',
    ],
  ),
  HardeningCheckMeta(
    id: HardeningCheck.disableWps,
    title: 'Disable WPS',
    critical: true,
    body:
        'WPS is the "easy connect" PIN feature. Even with a strong WPA2/WPA3 '
        'passphrase, WPS lets attackers bypass it in hours using public '
        'tools (Pixie Dust attack). Turn it off — typing the password once '
        'is not a hardship.',
    menuHints: ['WPS', 'Wireless > WPS', 'Easy Setup', 'Quick Connect'],
    steps: [
      'Open the admin panel.',
      'Find the Wireless or Wi-Fi section.',
      'Look for a sub-menu called "WPS", "Easy Setup", "Quick Connect" or '
          'a tab inside Wireless Settings labelled WPS.',
      'Switch the WPS toggle to OFF / Disabled.',
      'Some routers also have a physical WPS button on the device — that '
          'will stop working too, which is the goal.',
      'Save / Apply.',
      'From now on, when you connect a new device just type the Wi-Fi '
          'password normally. Takes 10 extra seconds, removes a serious '
          'attack path.',
      'Come back here and tap MARK DONE.',
    ],
  ),
  HardeningCheckMeta(
    id: HardeningCheck.enablePmf,
    title: 'Enable PMF / 802.11w',
    body:
        'Protected Management Frames stop attackers from forging '
        'disconnect packets that knock your devices offline (used in evil '
        'twin and deauth attacks). WPA3 requires it; on WPA2 it is usually '
        'a separate toggle.',
    menuHints: [
      'PMF',
      '802.11w',
      'Management Frame Protection',
      'Wireless > Advanced',
    ],
    steps: [
      'Open the admin panel.',
      'Go to the Wireless / Wi-Fi section.',
      'Look in "Advanced" or "Wireless Security" for a setting called '
          '"PMF", "802.11w" or "Management Frame Protection".',
      'Set it to "Required" if all your devices are recent (last ~5 years). '
          'If older devices stop seeing the network, change it to '
          '"Optional / Capable" — that still helps, just less strictly.',
      'If you cannot find this setting at all, your router may have it '
          'baked into WPA3 mode (so completing item 2 above already covers '
          'it). In that case, tap MARK DONE here too.',
      'Save / Apply.',
      'Come back here and tap MARK DONE.',
    ],
  ),
  HardeningCheckMeta(
    id: HardeningCheck.enableGuestNetwork,
    title: 'Enable a guest network',
    body:
        'A second SSID for visitors and IoT devices (cameras, smart bulbs, '
        'smart TVs). If a cheap IoT device is hacked, it stays trapped on '
        'the guest network and cannot reach your laptop, phone or NAS.',
    menuHints: ['Guest Network', 'Guest Wi-Fi', 'Guest Access', 'Multi-SSID'],
    steps: [
      'Open the admin panel.',
      'Find a menu called "Guest Network", "Guest Wi-Fi" or "Multi-SSID".',
      'Enable it. Give it a different name from your main Wi-Fi — for '
          'example, if your main is "Home", call the guest one "Home-Guest".',
      'Set a password. It can be simpler than your main one (guests will '
          'type it), but still 10+ characters.',
      'Look for a setting called "Client Isolation", "AP Isolation" or '
          '"Guest network isolation". Turn it ON. This stops guest devices '
          'from talking to each other or to your private network.',
      'Move your IoT devices (smart plugs, cameras, robot vacuum, smart TV) '
          'over to the guest network — connect them with the new password.',
      'Save / Apply.',
      'Come back here and tap MARK DONE.',
    ],
  ),
  HardeningCheckMeta(
    id: HardeningCheck.disableRemoteAdmin,
    title: 'Disable remote / WAN-side admin',
    critical: true,
    body:
        'If the admin panel is reachable from the internet, anyone in the '
        'world can try default passwords. Most home users never need this — '
        'turn it off.',
    menuHints: [
      'Remote Management',
      'WAN Access',
      'Administration > Remote',
      'Web Access from WAN',
    ],
    steps: [
      'Open the admin panel.',
      'Go to "Administration", "System Tools" or "Security".',
      'Find a setting called "Remote Management", "Web Access from WAN" or '
          '"Remote admin".',
      'Switch it OFF / Disabled.',
      'While here, also check for "Cloud / Remote App access" (some brands '
          'have this — TP-Link Tether, Asus Router app, Mi Wi-Fi). If you '
          'do not actively use that app, turn it off too.',
      'Save / Apply.',
      'You can still manage your router from inside your home — only the '
          'remote / public-internet path is closed.',
      'Come back here and tap MARK DONE.',
    ],
  ),
  HardeningCheckMeta(
    id: HardeningCheck.updateFirmware,
    title: 'Update firmware (and enable auto-update)',
    body:
        'Most home routers ship with known security holes that vendors patch '
        'quietly. If you have not updated in a year, you almost certainly '
        'have outdated firmware.',
    menuHints: [
      'Firmware Update',
      'System Update',
      'Online Upgrade',
      'Maintenance',
    ],
    steps: [
      'Open the admin panel.',
      'Find a menu called "Firmware Update", "System Update", "Online '
          'Upgrade" or "Maintenance".',
      'Tap "Check for update" or "Online check". The router will look for '
          'a newer version on the vendor server.',
      'If an update is offered, install it. The router will reboot for '
          '2-5 minutes — do NOT unplug it during the update or it can '
          'become a paperweight.',
      'After it comes back, go to the same menu and look for "Auto update" '
          'or "Automatic upgrade". Turn it ON if available.',
      'Some older routers do not have online updates. In that case, note '
          'the router model from the device sticker, search the vendor '
          'website, download the latest firmware file, and use the '
          '"Manual upload" option in the same menu.',
      'Come back here and tap MARK DONE.',
    ],
  ),
  HardeningCheckMeta(
    id: HardeningCheck.strongPassphrase,
    title: 'Use a strong, unique Wi-Fi passphrase',
    body:
        'The Wi-Fi password is the last line of defence if WPS or PMF fail. '
        '12+ characters, mixed case with numbers or symbols, never reused '
        'from another service.',
    menuHints: [
      'Wireless',
      'Wireless Security',
      'Wi-Fi Password',
      'Wireless Key',
    ],
    steps: [
      'Open the admin panel.',
      'Go to "Wireless", "Wi-Fi" or "WLAN".',
      'Find the password field — labelled "Wireless password", "Pre-Shared '
          'Key (PSK)", "Wireless Key" or simply "Password".',
      'Replace it with a NEW passphrase: at least 12 characters, with a '
          'mix of uppercase, lowercase, numbers and a symbol. Avoid '
          'dictionary words and personal info (birthdays, pet names).',
      'A good trick: pick three unrelated words plus a number, e.g. '
          '"correct-horse-battery-9". Long passphrases are harder to crack '
          'than short complex ones.',
      'If you have separate 2.4 GHz and 5 GHz networks, change BOTH.',
      'Save / Apply. Every device will disconnect — re-enter the new '
          'password on each one.',
      'Write the password down (password manager, fridge note for '
          'visitors, whatever works for you).',
      'Come back here and tap MARK DONE.',
    ],
  ),
];
