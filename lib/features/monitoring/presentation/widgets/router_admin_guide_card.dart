import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/oui_lookup.dart';

/// Auto-detected, vendor-aware "How do I change my Wi-Fi channel?" guide.
///
/// Reads the connected SSID/BSSID/gateway IP, identifies the router vendor
/// via OUI lookup, and shows the matching admin URL + menu path along with
/// a 20/40/80/160 MHz explanation and a safety note.
class RouterAdminGuideCard extends StatefulWidget {
  const RouterAdminGuideCard({super.key});

  @override
  State<RouterAdminGuideCard> createState() => _RouterAdminGuideCardState();
}

class _RouterAdminGuideCardState extends State<RouterAdminGuideCard> {
  String? _ssid;
  String? _gatewayIp;
  String? _vendorRaw;
  _VendorGuide? _guide;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _detect();
  }

  Future<void> _detect() async {
    try {
      final info = NetworkInfo();
      final results = await Future.wait([
        info.getWifiName(),
        info.getWifiBSSID(),
        info.getWifiGatewayIP(),
      ]);
      final ssid = (results[0] ?? '').replaceAll('"', '');
      final bssid = results[1];
      final gw = results[2];

      String? vendor;
      if (bssid != null && bssid.isNotEmpty) {
        vendor = await GetIt.I<OuiLookup>().lookup(bssid);
      }

      if (!mounted) return;
      setState(() {
        _ssid = ssid.isEmpty ? null : ssid;
        _gatewayIp = (gw != null && gw.isNotEmpty) ? gw : null;
        _vendorRaw = vendor;
        _guide = _matchGuide(vendor);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  /// Matches the OUI-resolved vendor string against known router brand
  /// keywords. The lookup database returns names like "TP-LINK TECHNOLOGIES
  /// CO., LTD." — we only need to find a brand keyword inside it.
  _VendorGuide? _matchGuide(String? vendor) {
    if (vendor == null || vendor.isEmpty) return null;
    final v = vendor.toUpperCase();
    for (final g in _knownGuides) {
      for (final kw in g.matchKeywords) {
        if (v.contains(kw)) return g;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();

    final l10n = context.l10n;
    final color = AppColors.neonCyan;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final hasConnection = _ssid != null;
    final adminAddress =
        _guide?.adminUrl ??
        (_gatewayIp != null ? 'http://$_gatewayIp' : null);
    final menuPath =
        _guide?.menuPath.join(' → ') ?? l10n.guideGenericMenuPath;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: color,
          collapsedIconColor: color.withValues(alpha: 0.7),
          leading: Icon(Icons.router_rounded, color: color, size: 22),
          title: Text(
            l10n.howToChangeChannelTitle,
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              l10n.howToChangeChannelSubtitle,
              style: GoogleFonts.rajdhani(
                fontSize: 11,
                color: onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
          children: [
            if (!hasConnection)
              _NoConnectionHint(text: l10n.guideNoConnection, color: color)
            else ...[
              _DetectedHeader(
                ssid: _ssid!,
                vendorRaw: _vendorRaw,
                vendorMatched: _guide?.brand,
                color: color,
                onSurface: onSurface,
              ),
              const SizedBox(height: 16),
              _StepBlock(
                stepLabel: l10n.guideStep1,
                body: l10n.guideStep1Body,
                color: color,
                onSurface: onSurface,
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (adminAddress != null)
                      _AdminAddressRow(address: adminAddress, color: color),
                    const SizedBox(height: 10),
                    _CredentialsSubSection(
                      title: l10n.guideCredentialsHeader,
                      body: l10n.guideCredentialsBody,
                      color: color,
                      onSurface: onSurface,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _StepBlock(
                stepLabel: l10n.guideStep2,
                body: l10n.guideStep2Body,
                color: color,
                onSurface: onSurface,
                trailing: _MenuPathRow(
                  pathLabel: l10n.guideMenuPathLabel,
                  path: menuPath,
                  color: color,
                  onSurface: onSurface,
                ),
              ),
              const SizedBox(height: 14),
              _StepBlock(
                stepLabel: l10n.guideStep3,
                body: l10n.guideStep3Body,
                color: color,
                onSurface: onSurface,
              ),
            ],
            const SizedBox(height: 18),
            _CollapsibleNote(
              icon: Icons.alt_route_rounded,
              title: l10n.channelWidthHeader,
              body: l10n.channelWidthBody,
              color: AppColors.neonGreen,
              onSurface: onSurface,
            ),
            const SizedBox(height: 10),
            _CollapsibleNote(
              icon: Icons.shield_outlined,
              title: l10n.guideRisksHeader,
              body: l10n.guideRisksBody,
              color: AppColors.neonPurple,
              onSurface: onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────

class _NoConnectionHint extends StatelessWidget {
  final String text;
  final Color color;
  const _NoConnectionHint({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.08),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.rajdhani(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetectedHeader extends StatelessWidget {
  final String ssid;
  final String? vendorRaw;
  final String? vendorMatched;
  final Color color;
  final Color onSurface;
  const _DetectedHeader({
    required this.ssid,
    required this.vendorRaw,
    required this.vendorMatched,
    required this.color,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vendorDisplay =
        vendorMatched ??
        (vendorRaw == null ||
                vendorRaw!.isEmpty ||
                vendorRaw!.toLowerCase() == 'unknown'
            ? l10n.guideRouterUnknown
            : vendorRaw!);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.07),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv(context, Icons.wifi_rounded, l10n.guideConnectedTo, ssid),
          const SizedBox(height: 6),
          _kv(context, Icons.memory_rounded, l10n.guideRouterVendor, vendorDisplay),
        ],
      ),
    );
  }

  Widget _kv(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.8)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: onSurface.withValues(alpha: 0.55),
          ),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.orbitron(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: onSurface.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepBlock extends StatelessWidget {
  final String stepLabel;
  final String body;
  final Color color;
  final Color onSurface;
  final Widget? trailing;
  const _StepBlock({
    required this.stepLabel,
    required this.body,
    required this.color,
    required this.onSurface,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stepLabel,
          style: GoogleFonts.orbitron(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: GoogleFonts.rajdhani(
            fontSize: 13,
            height: 1.45,
            color: onSurface.withValues(alpha: 0.82),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(height: 8),
          trailing!,
        ],
      ],
    );
  }
}

class _AdminAddressRow extends StatelessWidget {
  final String address;
  final Color color;
  const _AdminAddressRow({required this.address, required this.color});

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final uri = Uri.parse(
      address.startsWith(RegExp(r'https?://')) ? address : 'http://$address',
    );
    bool launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }
    if (!launched) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.guideOpenFailedMessage),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    await Clipboard.setData(ClipboardData(text: address));
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.guideAddressCopied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.public_rounded, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              address,
              style: GoogleFonts.firaCode(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _copy(context),
            icon: Icon(Icons.copy_rounded, size: 16, color: color),
            tooltip: l10n.guideCopyAddress,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          ElevatedButton.icon(
            onPressed: () => _open(context),
            icon: const Icon(Icons.open_in_new_rounded, size: 14),
            label: Text(
              l10n.guideOpenInBrowser.toUpperCase(),
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.black,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Detailed credentials sub-section under Step 1 — covers default factory
/// passwords, ISP-provided unique passwords, factory reset and router apps.
class _CredentialsSubSection extends StatefulWidget {
  final String title;
  final String body;
  final Color color;
  final Color onSurface;
  const _CredentialsSubSection({
    required this.title,
    required this.body,
    required this.color,
    required this.onSurface,
  });

  @override
  State<_CredentialsSubSection> createState() => _CredentialsSubSectionState();
}

class _CredentialsSubSectionState extends State<_CredentialsSubSection> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: widget.color.withValues(alpha: 0.04),
        border: Border.all(color: widget.color.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.vpn_key_rounded,
                    size: 14,
                    color: widget.color.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.orbitron(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: widget.color.withValues(alpha: 0.9),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Icon(
                    _open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: widget.color.withValues(alpha: 0.65),
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                widget.body,
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  height: 1.55,
                  color: widget.onSurface.withValues(alpha: 0.85),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuPathRow extends StatelessWidget {
  final String pathLabel;
  final String path;
  final Color color;
  final Color onSurface;
  const _MenuPathRow({
    required this.pathLabel,
    required this.path,
    required this.color,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pathLabel.toUpperCase(),
            style: GoogleFonts.orbitron(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: color.withValues(alpha: 0.7),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            path,
            style: GoogleFonts.firaCode(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: onSurface.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollapsibleNote extends StatefulWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  final Color onSurface;
  const _CollapsibleNote({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    required this.onSurface,
  });

  @override
  State<_CollapsibleNote> createState() => _CollapsibleNoteState();
}

class _CollapsibleNoteState extends State<_CollapsibleNote> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: widget.color.withValues(alpha: 0.05),
        border: Border.all(color: widget.color.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(widget.icon, size: 16, color: widget.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Icon(
                    _open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: widget.color.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                widget.body,
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  height: 1.5,
                  color: widget.onSurface.withValues(alpha: 0.85),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Vendor guides ──────────────────────────────────────────────────────

class _VendorGuide {
  final String brand;
  final List<String> matchKeywords; // upper-case substrings of OUI vendor name
  final String adminUrl;
  final List<String> menuPath;

  const _VendorGuide({
    required this.brand,
    required this.matchKeywords,
    required this.adminUrl,
    required this.menuPath,
  });
}

const _knownGuides = <_VendorGuide>[
  _VendorGuide(
    brand: 'TP-Link',
    matchKeywords: ['TP-LINK', 'TPLINK'],
    adminUrl: 'http://tplinkwifi.net',
    menuPath: ['Wireless', 'Wireless Settings', 'Channel'],
  ),
  _VendorGuide(
    brand: 'Mercusys',
    matchKeywords: ['MERCUSYS'],
    adminUrl: 'http://mwlogin.net',
    menuPath: ['Wireless', 'Wireless Settings', 'Channel'],
  ),
  _VendorGuide(
    brand: 'Asus',
    matchKeywords: ['ASUSTEK', 'ASUS'],
    adminUrl: 'http://router.asus.com',
    menuPath: ['Wireless', 'General', 'Control Channel'],
  ),
  _VendorGuide(
    brand: 'Huawei',
    matchKeywords: ['HUAWEI'],
    adminUrl: 'http://192.168.1.1',
    menuPath: ['Settings', 'Wi-Fi', 'Wi-Fi Advanced', 'Channel'],
  ),
  _VendorGuide(
    brand: 'ZTE',
    matchKeywords: ['ZTE'],
    adminUrl: 'http://192.168.1.1',
    menuPath: ['Network', 'WLAN', 'WLAN Basic', 'Channel'],
  ),
  _VendorGuide(
    brand: 'AirTies',
    matchKeywords: ['AIRTIES'],
    adminUrl: 'http://192.168.2.1',
    menuPath: ['Kablosuz', 'Kablosuz Ayarlar', 'Kanal'],
  ),
  _VendorGuide(
    brand: 'D-Link',
    matchKeywords: ['D-LINK', 'DLINK'],
    adminUrl: 'http://192.168.0.1',
    menuPath: ['Setup', 'Wireless Settings', 'Manual Wireless Setup', 'Channel'],
  ),
  _VendorGuide(
    brand: 'Tenda',
    matchKeywords: ['TENDA'],
    adminUrl: 'http://tendawifi.com',
    menuPath: ['WiFi Settings', 'WiFi Channel & Bandwidth'],
  ),
  _VendorGuide(
    brand: 'Xiaomi',
    matchKeywords: ['XIAOMI', 'MI '],
    adminUrl: 'http://miwifi.com',
    menuPath: ['Settings', 'Wi-Fi', 'Channel'],
  ),
  _VendorGuide(
    brand: 'Netgear',
    matchKeywords: ['NETGEAR'],
    adminUrl: 'http://routerlogin.net',
    menuPath: ['Wireless', 'Channel'],
  ),
  _VendorGuide(
    brand: 'Linksys',
    matchKeywords: ['LINKSYS', 'BELKIN'],
    adminUrl: 'http://linksyssmartwifi.com',
    menuPath: ['Wi-Fi Settings', 'Advanced', 'Channel'],
  ),
  _VendorGuide(
    brand: 'MikroTik',
    matchKeywords: ['MIKROTIK', 'ROUTERBOARD'],
    adminUrl: 'http://192.168.88.1',
    menuPath: ['Wireless', 'Interfaces', 'Frequency'],
  ),
  _VendorGuide(
    brand: 'Ubiquiti',
    matchKeywords: ['UBIQUITI', 'UBNT'],
    adminUrl: 'http://unifi',
    menuPath: ['Settings', 'Wi-Fi', 'Edit network', 'Wi-Fi Advanced', 'Channel'],
  ),
  _VendorGuide(
    brand: 'Zyxel',
    matchKeywords: ['ZYXEL'],
    adminUrl: 'http://192.168.1.1',
    menuPath: ['Network Setting', 'Wireless', 'General', 'Channel'],
  ),
  _VendorGuide(
    brand: 'Sagemcom',
    matchKeywords: ['SAGEMCOM', 'SAGEM'],
    adminUrl: 'http://192.168.1.1',
    menuPath: ['Wireless', 'Configuration', 'Channel'],
  ),
  _VendorGuide(
    brand: 'Technicolor',
    matchKeywords: ['TECHNICOLOR', 'THOMSON'],
    adminUrl: 'http://192.168.1.1',
    menuPath: ['Home Network', 'Wireless', 'Channel'],
  ),
];
