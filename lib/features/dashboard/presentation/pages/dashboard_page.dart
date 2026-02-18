import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../wifi_scan/domain/services/scan_session_store.dart';

/// Dashboard — a quick status overview that shows current network state
/// and provides shortcuts to the main workflows.
class DashboardPage extends StatefulWidget {
  final void Function(String destination) onNavigate;

  const DashboardPage({super.key, required this.onNavigate});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _ssid = '—';
  String _ip = '—';
  String _gateway = '—';
  int _networkCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNetworkInfo();
  }

  Future<void> _loadNetworkInfo() async {
    try {
      final info = NetworkInfo();
      final results = await Future.wait([
        info.getWifiName(),
        info.getWifiIP(),
        info.getWifiGatewayIP(),
      ]);

      final store = getIt<ScanSessionStore>();
      final latestSnapshot = store.latest;

      if (!mounted) return;
      setState(() {
        _ssid = _cleanSsid(results[0]) ?? '—';
        _ip = results[1] ?? '—';
        _gateway = results[2] ?? '—';
        _networkCount = latestSnapshot?.networks.length ?? 0;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String? _cleanSsid(String? raw) {
    if (raw == null) return null;
    // Android may wrap the SSID in quotes.
    return raw.replaceAll('"', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TORCAV',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 3,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadNetworkInfo,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // ── Connection Card ──────────────────────────────
            _ConnectionCard(
              ssid: _ssid,
              ip: _ip,
              gateway: _gateway,
              loading: _loading,
            ),
            const SizedBox(height: 20),

            // ── Quick-Action Row ─────────────────────────────
            Text(
              'QUICK ACTIONS',
              style: GoogleFonts.rajdhani(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.wifi_find_rounded,
                    label: 'Wi-Fi Scan',
                    color: AppTheme.primaryColor,
                    onTap: () => widget.onNavigate('wifi'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.device_hub_rounded,
                    label: 'LAN Recon',
                    color: AppTheme.secondaryColor,
                    onTap: () => widget.onNavigate('lan'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.speed_rounded,
                    label: 'Speed Test',
                    color: const Color(0xFFFFAB40),
                    onTap: () => widget.onNavigate('monitoring'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Last Scan Summary ────────────────────────────
            Text(
              'LAST SCAN',
              style: GoogleFonts.rajdhani(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            _LastScanStrip(
              networkCount: _networkCount,
              onViewDetails: () => widget.onNavigate('wifi'),
            ),
            const SizedBox(height: 24),

            // ── Safety Badge ────────────────────────────────
            _SafetyBadge(onTap: () => widget.onNavigate('security')),
          ],
        ),
      ),
    );
  }
}

// ── Connection Card ─────────────────────────────────────────────────

class _ConnectionCard extends StatelessWidget {
  final String ssid;
  final String ip;
  final String gateway;
  final bool loading;

  const _ConnectionCard({
    required this.ssid,
    required this.ip,
    required this.gateway,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = ssid != '—' && ssid.isNotEmpty;
    final accentColor =
        isConnected ? AppTheme.primaryColor : const Color(0xFFFF6B6B);
    final statusLabel = isConnected ? 'CONNECTED' : 'NOT CONNECTED';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.10),
            accentColor.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.30)),
      ),
      child:
          loading
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        statusLabel,
                        style: GoogleFonts.rajdhani(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ssid,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InfoChip(label: 'IP', value: ip),
                      const SizedBox(width: 12),
                      _InfoChip(label: 'Gateway', value: gateway),
                    ],
                  ),
                ],
              ),
    );
  }
}

/// Small read-only chip — clearly non-interactive (no elevation,
/// no ripple, muted colors).
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: GoogleFonts.rajdhani(color: Colors.white30, fontSize: 13),
        ),
        Text(
          value,
          style: GoogleFonts.sourceCodePro(color: Colors.white60, fontSize: 13),
        ),
      ],
    );
  }
}

// ── Quick Action Button ─────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: color.withValues(alpha: 0.08),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Last Scan Strip ─────────────────────────────────────────────────

class _LastScanStrip extends StatelessWidget {
  final int networkCount;
  final VoidCallback onViewDetails;

  const _LastScanStrip({
    required this.networkCount,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (networkCount == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white24, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No scan data yet — run a Wi-Fi scan to see results.',
                style: GoogleFonts.rajdhani(
                  color: Colors.white38,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.primaryColor.withValues(alpha: 0.06),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.20),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.wifi_tethering_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$networkCount networks detected',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'VIEW',
                style: GoogleFonts.rajdhani(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.primaryColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Safety Badge ────────────────────────────────────────────────────

class _SafetyBadge extends StatelessWidget {
  final VoidCallback onTap;

  const _SafetyBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Strict safety mode enabled',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white24,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
