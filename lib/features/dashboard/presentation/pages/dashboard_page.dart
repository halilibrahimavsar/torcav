import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../wifi_scan/domain/services/scan_session_store.dart';
import '../widgets/security_core.dart';

/// Dashboard — neon-styled status overview with animated bento-grid layout.
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
      final info = getIt<NetworkInfo>();
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
    return raw.replaceAll('"', '');
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.menu_rounded, size: 18),
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: NeonText(
          'TORCAV',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 4,
            color: AppColors.neonCyan,
          ),
          glowRadius: 15,
        ),
        actions: [
          NeonIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.neonCyan,
        backgroundColor: AppColors.darkSurface,
        onRefresh: _loadNetworkInfo,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            // ── Dynamic Bento Header: Security Core & Primary Stats ──
            StaggeredEntry(
              delay: const Duration(milliseconds: 100),
              child: _SecurityBentoHeader(
                ssid: _ssid,
                ip: _ip,
                gateway: _gateway,
                loading: _loading,
              ),
            ),
            
            const SizedBox(height: 32),

            // ── System Metrics Strip ──
            StaggeredEntry(
              delay: const Duration(milliseconds: 300),
              child: const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: NeonSectionHeader(
                  label: 'LIVE PULSE',
                  color: AppColors.neonCyan,
                  icon: Icons.monitor_heart_rounded,
                ),
              ),
            ),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _QuickAction(
                  index: 0,
                  icon: Icons.hub_rounded,
                  label: 'OPERATIONS',
                  color: AppColors.neonPurple,
                  onTap: () => widget.onNavigate('operations'),
                ),
                _QuickAction(
                  index: 1,
                  icon: Icons.device_hub_rounded,
                  label: 'TOPOLOGY',
                  color: AppColors.neonGreen,
                  onTap: () => widget.onNavigate('monitor/topology'),
                ),
              ],
            ),
            
            const SizedBox(height: 32),

            // ── Recent Activity Section ──
            StaggeredEntry(
              delay: const Duration(milliseconds: 700),
              child: const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: NeonSectionHeader(
                  label: 'NETWORK LOGS',
                  color: AppColors.neonGreen,
                ),
              ),
            ),
            
            StaggeredEntry(
              delay: const Duration(milliseconds: 800),
              child: _LastScanStrip(
                networkCount: _networkCount,
                onViewDetails: () => widget.onNavigate('wifi'),
              ),
            ),

            const SizedBox(height: 20),
            
            StaggeredEntry(
              delay: const Duration(milliseconds: 900),
              child: _SafetyBadge(onTap: () => widget.onNavigate('security')),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bento Header Component ──────────────────────────────────────────

class _SecurityBentoHeader extends StatelessWidget {
  final String ssid;
  final String ip;
  final String gateway;
  final bool loading;

  const _SecurityBentoHeader({
    required this.ssid,
    required this.ip,
    required this.gateway,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isConnected = ssid != '—' && ssid.isNotEmpty;
    final accentColor = isConnected ? AppColors.neonCyan : AppColors.neonRed;
    final statusLabel = isConnected
        ? l10n.connectedStatusCaps
        : l10n.disconnectedStatusCaps;

    return Column(
      children: [
        SecurityCore(
          statusColor: accentColor,
          label: statusLabel,
          subLabel: ssid,
          isLoading: loading,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _BentoStatTile(
                label: l10n.ipLabel,
                value: ip,
                icon: Icons.lan_outlined,
                color: AppColors.neonCyan,
                delay: const Duration(milliseconds: 400),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _BentoStatTile(
                label: l10n.gatewayLabel,
                value: gateway,
                icon: Icons.router_outlined,
                color: AppColors.neonPurple,
                delay: const Duration(milliseconds: 500),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BentoStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Duration delay;

  const _BentoStatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredEntry(
      delay: delay,
      slideOffset: 20,
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(16),
        borderColor: color.withValues(alpha: 0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 14),
                const SizedBox(width: 6),
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.rajdhani(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Action Component ──────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int index;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredEntry(
      delay: Duration(milliseconds: 400 + (index * 100)),
      slideOffset: 20,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: color.withValues(alpha: 0.15),
          highlightColor: color.withValues(alpha: 0.05),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.darkSurfaceLight,
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.05),
                  blurRadius: 15,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Icon(
                      icon,
                      size: 80,
                      color: color.withValues(alpha: 0.03),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withValues(alpha: 0.1),
                            border: Border.all(color: color.withValues(alpha: 0.2)),
                          ),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        const Spacer(),
                        Text(
                          label,
                          style: GoogleFonts.rajdhani(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ACCESS ENGINE', // Thematic flavor text
                          style: GoogleFonts.orbitron(
                            color: color.withValues(alpha: 0.5),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Activity Strip Component ───────────────────────────────────────

class _LastScanStrip extends StatelessWidget {
  final int networkCount;
  final VoidCallback onViewDetails;

  const _LastScanStrip({
    required this.networkCount,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NeonCard(
      glowColor: AppColors.neonGreen,
      glowIntensity: 0.08,
      onTap: onViewDetails,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonGreen.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.radar_rounded, color: AppColors.neonGreen, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LATEST SNAPSHOT',
                  style: GoogleFonts.orbitron(
                    color: AppColors.neonGreen.withValues(alpha: 0.7),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  networkCount == 0 ? l10n.noSnapshotAvailable : l10n.networksCount(networkCount),
                  style: GoogleFonts.rajdhani(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: AppColors.neonGreen.withValues(alpha: 0.5), size: 14),
        ],
      ),
    );
  }
}

// ── Safety Badge Component ──────────────────────────────────────────

class _SafetyBadge extends StatelessWidget {
  final VoidCallback onTap;

  const _SafetyBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      borderColor: AppColors.neonGreen.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonGreen.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.verified_user_rounded, color: AppColors.neonGreen, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STRICT SAFETY ENABLED',
                    style: GoogleFonts.orbitron(
                      color: AppColors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Active monitoring in progress',
                    style: GoogleFonts.rajdhani(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
