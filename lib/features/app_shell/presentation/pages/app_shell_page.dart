import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../monitoring/presentation/pages/monitoring_hub_page.dart';
import '../../../network_scan/presentation/pages/network_scan_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../security/presentation/pages/security_center_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../wifi_scan/presentation/pages/wifi_scan_page.dart';

/// Root shell that manages the bottom navigation and page switching.
///
/// Tabs are reduced to 4 to avoid clutter on smaller screens.
/// The "More" tab opens a hub with less-frequently-used features.
class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key});

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  int _index = 0;

  static const _primaryTabs = [
    _ShellTab(
      title: 'Dashboard',
      icon: Icons.space_dashboard_outlined,
      selectedIcon: Icons.space_dashboard_rounded,
    ),
    _ShellTab(
      title: 'Wi-Fi',
      icon: Icons.wifi_outlined,
      selectedIcon: Icons.wifi_rounded,
    ),
    _ShellTab(
      title: 'LAN',
      icon: Icons.device_hub_outlined,
      selectedIcon: Icons.device_hub_rounded,
    ),
    _ShellTab(
      title: 'More',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DashboardPage(onNavigate: (destination) => _navigateTo(destination)),
          const WifiScanPage(),
          const NetworkScanPage(),
          _MoreHub(onNavigate: _pushPage),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 70,
        destinations:
            _primaryTabs
                .map(
                  (tab) => NavigationDestination(
                    icon: Icon(tab.icon),
                    selectedIcon: Icon(tab.selectedIcon),
                    label: tab.title,
                  ),
                )
                .toList(),
      ),
    );
  }

  void _navigateTo(String destination) {
    switch (destination) {
      case 'wifi':
        setState(() => _index = 1);
      case 'lan':
        setState(() => _index = 2);
      case 'security':
        _pushPage(const SecurityCenterPage(), 'Security Center');
      case 'monitoring':
        _pushPage(const MonitoringHubPage(), 'Monitoring');
      case 'reports':
        _pushPage(const ReportsPage(), 'Reports');
      case 'settings':
        _pushPage(const SettingsPage(), 'Settings');
      case 'more':
        setState(() => _index = 3);
    }
  }

  void _pushPage(Widget page, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => Scaffold(appBar: AppBar(title: Text(title)), body: page),
      ),
    );
  }
}

class _ShellTab {
  final String title;
  final IconData icon;
  final IconData selectedIcon;

  const _ShellTab({
    required this.title,
    required this.icon,
    required this.selectedIcon,
  });
}

// ── More Hub ──────────────────────────────────────────────────────────

class _MoreHub extends StatelessWidget {
  final void Function(Widget page, String title) onNavigate;

  const _MoreHub({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MORE')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(label: 'TOOLS'),
          const SizedBox(height: 8),
          _MenuTile(
            icon: Icons.speed_rounded,
            iconColor: AppTheme.secondaryColor,
            title: 'Speed Test & Monitoring',
            subtitle: 'Bandwidth, latency, and anomaly tracking',
            onTap: () => onNavigate(const MonitoringHubPage(), 'Monitoring'),
          ),
          _MenuTile(
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFFFF6B6B),
            title: 'Security Center',
            subtitle: 'Risk scoring, allowlists, and policy controls',
            onTap:
                () => onNavigate(const SecurityCenterPage(), 'Security Center'),
          ),
          _MenuTile(
            icon: Icons.description_outlined,
            iconColor: const Color(0xFFFFAB40),
            title: 'Reports',
            subtitle: 'Export scans as PDF, HTML, or JSON',
            onTap: () => onNavigate(const ReportsPage(), 'Reports'),
          ),
          const SizedBox(height: 20),
          _SectionHeader(label: 'PREFERENCES'),
          const SizedBox(height: 8),
          _MenuTile(
            icon: Icons.tune_rounded,
            iconColor: Colors.white54,
            title: 'Settings',
            subtitle: 'Scan behavior, backends, and safety mode',
            onTap: () => onNavigate(const SettingsPage(), 'Settings'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.rajdhani(
            color: Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: Colors.white12, thickness: 1)),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white24,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
