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

/// Static metadata for each [HardeningCheck]. User-facing copy (title, body,
/// step-by-step instructions) is sourced from the localization layer via
/// [HardeningCheckX] in `presentation/extensions/hardening_extension.dart`.
class HardeningCheckMeta {
  final HardeningCheck id;

  /// Common menu labels across vendors (TP-Link, Asus, Netgear, Huawei,
  /// Mercusys, Tenda, Mi). Helps the user recognise the right page when
  /// vendors use different wording. Brand/menu names are intentionally
  /// untranslated.
  final List<String> menuHints;

  /// Critical = security cannot be considered hardened without this. Used to
  /// boost prominence in the UI.
  final bool critical;

  const HardeningCheckMeta({
    required this.id,
    this.menuHints = const [],
    this.critical = false,
  });
}

const hardeningCatalog = <HardeningCheckMeta>[
  HardeningCheckMeta(
    id: HardeningCheck.changeAdminPassword,
    critical: true,
    menuHints: [
      'Administration',
      'System',
      'Maintenance',
      'System Tools',
      'Account',
    ],
  ),
  HardeningCheckMeta(
    id: HardeningCheck.useWpa3OrWpa2Aes,
    critical: true,
    menuHints: [
      'Wireless',
      'Wi-Fi',
      'Wi-Fi Settings',
      'Wireless Security',
      'WLAN',
    ],
  ),
  HardeningCheckMeta(
    id: HardeningCheck.disableWps,
    critical: true,
    menuHints: ['WPS', 'Wireless > WPS', 'Easy Setup', 'Quick Connect'],
  ),
  HardeningCheckMeta(
    id: HardeningCheck.enablePmf,
    menuHints: [
      'PMF',
      '802.11w',
      'Management Frame Protection',
      'Wireless > Advanced',
    ],
  ),
  HardeningCheckMeta(
    id: HardeningCheck.enableGuestNetwork,
    menuHints: ['Guest Network', 'Guest Wi-Fi', 'Guest Access', 'Multi-SSID'],
  ),
  HardeningCheckMeta(
    id: HardeningCheck.disableRemoteAdmin,
    critical: true,
    menuHints: [
      'Remote Management',
      'WAN Access',
      'Administration > Remote',
      'Web Access from WAN',
    ],
  ),
  HardeningCheckMeta(
    id: HardeningCheck.updateFirmware,
    menuHints: [
      'Firmware Update',
      'System Update',
      'Online Upgrade',
      'Maintenance',
    ],
  ),
  HardeningCheckMeta(
    id: HardeningCheck.strongPassphrase,
    menuHints: [
      'Wireless',
      'Wireless Security',
      'Wi-Fi Password',
      'Wireless Key',
    ],
  ),
];
