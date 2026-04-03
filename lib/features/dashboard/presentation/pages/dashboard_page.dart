import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../security/presentation/bloc/notification/notification_bloc.dart';
import '../../../wifi_scan/domain/services/scan_session_store.dart';
import '../widgets/security_core.dart';
import 'notification_sheet.dart';

/// Dashboard — neon-styled status overview with animated bento-grid layout.
class DashboardPage extends StatefulWidget {
  final void Function(String destination) onNavigate;
  final VoidCallback? onOpenDrawer;

  const DashboardPage({super.key, required this.onNavigate, this.onOpenDrawer});

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
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => getIt<NotificationBloc>()..add(LoadNotifications()),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: Builder(
            builder:
                (context) => IconButton(
                  icon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(Icons.menu_rounded, size: 18),
                  ),
                  onPressed: widget.onOpenDrawer ?? () => Scaffold.of(context).openDrawer(),
                ),
          ),
          title: NeonText(
            'TORCAV',
            style: GoogleFonts.orbitron(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 4,
              color: Theme.of(context).colorScheme.primary,
            ),
            glowRadius: 15,
          ),
          actions: [
            BlocConsumer<NotificationBloc, NotificationState>(
              listener: (context, state) {
                if (state is NotificationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                int unreadCount = 0;
                if (state is NotificationLoaded) {
                  unreadCount = state.unreadCount;
                }

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    NeonIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: () => _showNotificationSheet(context),
                      tooltip: l10n.securityAlertsTooltip,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: GoogleFonts.rajdhani(
                              color: Theme.of(context).colorScheme.onError,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
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
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: NeonSectionHeader(
                    label: l10n.livePulse,
                    color: Theme.of(context).colorScheme.primary,
                    icon: Icons.monitor_heart_rounded,
                  ),
                ),
              ),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _QuickAction(
                    index: 0,
                    icon: Icons.hub_rounded,
                    label: l10n.operationsLabel,
                    color: Theme.of(context).colorScheme.secondary,
                    onTap: () => widget.onNavigate('operations'),
                  ),
                  _QuickAction(
                    index: 1,
                    icon: Icons.device_hub_rounded,
                    label: l10n.topologyLabel,
                    color: Theme.of(context).colorScheme.tertiary,
                    onTap: () => widget.onNavigate('monitor/topology'),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Recent Activity Section ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 700),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: NeonSectionHeader(
                    label: l10n.networkLogs,
                    color: Theme.of(context).colorScheme.tertiary,
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
      ),
    );
  }

  void _showNotificationSheet(BuildContext context) {
    final notificationBloc = context.read<NotificationBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (sheetContext) => BlocProvider.value(
            value: notificationBloc,
            child: const NotificationSheet(),
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
    final scheme = Theme.of(context).colorScheme;
    final accentColor = isConnected ? scheme.primary : scheme.error;
    final statusLabel =
        isConnected ? l10n.connectedStatusCaps : l10n.disconnectedStatusCaps;

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
                color: Theme.of(context).colorScheme.primary,
                delay: const Duration(milliseconds: 400),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _BentoStatTile(
                label: l10n.gatewayLabel,
                value: gateway,
                icon: Icons.router_outlined,
                color: Theme.of(context).colorScheme.secondary,
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                color: Theme.of(context).colorScheme.onSurface,
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
              color: Theme.of(context).colorScheme.surfaceContainerLow,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withValues(alpha: 0.1),
                            border: Border.all(
                              color: color.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        const Spacer(),
                        Text(
                          label,
                          style: GoogleFonts.rajdhani(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.accessEngine,
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

    final tertiary = Theme.of(context).colorScheme.tertiary;

    return NeonCard(
      glowColor: tertiary,
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
              color: tertiary.withValues(alpha: 0.1),
              border: Border.all(
                color: tertiary.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              Icons.radar_rounded,
              color: tertiary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.latestSnapshotTitle,
                  style: GoogleFonts.orbitron(
                    color: tertiary.withValues(alpha: 0.7),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  networkCount == 0
                      ? l10n.noSnapshotAvailable
                      : l10n.networksCount(networkCount),
                  style: GoogleFonts.rajdhani(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: tertiary.withValues(alpha: 0.5),
            size: 14,
          ),
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
    final tertiary = Theme.of(context).colorScheme.tertiary;

    return GlassmorphicContainer(
      borderColor: tertiary.withValues(alpha: 0.3),
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
                color: tertiary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.verified_user_rounded,
                color: tertiary,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.strictSafetyEnabled,
                    style: GoogleFonts.orbitron(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.activeMonitoringProgress,
                    style: GoogleFonts.rajdhani(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
