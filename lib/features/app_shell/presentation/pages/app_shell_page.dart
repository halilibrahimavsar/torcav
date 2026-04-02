import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../network_scan/presentation/pages/network_scan_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../security/presentation/pages/security_center_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../monitoring/presentation/pages/topology_page.dart';
import '../../../wifi_scan/presentation/pages/wifi_scan_page.dart';
import '../widgets/cyber_drawer.dart';
import 'operations_hub_page.dart';
import 'profile_hub_page.dart';

/// Root shell: simplified 3-tab navigation with neon bottom bar.
///
/// Tabs:  Dashboard │ Discovery │ Operations
/// Secondary features (Security, Reports, Settings) are consolidated
/// into the Operations hub.
class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key});

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  int _index = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() => _index = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: CyberDrawer(onNavigate: _navigateTo),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          DashboardPage(onNavigate: _navigateTo),
          const _DiscoveryTabPage(),
          OperationsHubPage(onNavigate: _navigateTo),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: _NeonBottomBar(
        currentIndex: _index,
        onTap: _onTabSelected,
        items: [
          _NeonBarItem(
            icon: Icons.grid_view_outlined,
            selectedIcon: Icons.grid_view_rounded,
            label: l10n.navDashboard.toUpperCase(),
          ),
          _NeonBarItem(
            icon: Icons.radar_outlined,
            selectedIcon: Icons.radar_rounded,
            label: l10n.navDiscovery.toUpperCase(),
          ),
          _NeonBarItem(
            icon: Icons.hub_outlined,
            selectedIcon: Icons.hub_rounded,
            label: l10n.navOperations.toUpperCase(),
          ),
        ],
      ),
    );
  }

  void _navigateTo(String destination) {
    switch (destination) {
      case 'dashboard':
        _onTabSelected(0);
      case 'wifi':
      case 'lan':
        _onTabSelected(1);
      case 'operations':
        _onTabSelected(2);
      case 'monitor/topology':
        _onTabSelected(2);
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const TopologyPage()));
      case 'security':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SecurityCenterPage()),
        );
      case 'reports':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const ReportsPage()));
      case 'settings':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const SettingsPage()));
      case 'profile':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const ProfileHubPage()));
    }
  }
}

// ── Discovery Tab (Wi-Fi + LAN combined) ──────────────────────────────

class _DiscoveryTabPage extends StatefulWidget {
  const _DiscoveryTabPage();

  @override
  State<_DiscoveryTabPage> createState() => _DiscoveryTabPageState();
}

class _DiscoveryTabPageState extends State<_DiscoveryTabPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: NeonText(
          'DISCOVERY',
          style: GoogleFonts.orbitron(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          glowRadius: 8,
        ),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: getIt<ThemeCubit>(),
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark;
              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: isDark ? 'Light mode' : 'Dark mode',
                onPressed: () => getIt<ThemeCubit>().toggle(),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              dividerColor: Colors.transparent,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              labelStyle: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
              unselectedLabelStyle: GoogleFonts.orbitron(
                fontSize: 11,
                letterSpacing: 1,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(l10n.navWifi),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.device_hub_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(l10n.navLan),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [WifiScanPage(), NetworkScanPage()],
      ),
    );
  }
}

// ── Neon Bottom Bar ──────────────────────────────────────────────────

class _NeonBarItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NeonBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _NeonBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NeonBarItem> items;

  const _NeonBottomBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / items.length;
                return Stack(
                  children: [
                    // Moving Shuttle
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      left: (currentIndex * itemWidth) + (itemWidth * 0.1),
                      top: 10,
                      child: Container(
                        width: itemWidth * 0.8,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Items
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        final isSelected = currentIndex == index;
                        return _NeonBarButton(
                          icon: isSelected ? item.selectedIcon : item.icon,
                          label: item.label,
                          isSelected: isSelected,
                          onTap: () => onTap(index),
                          width: itemWidth,
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NeonBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;

  const _NeonBarButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isSelected ? scheme.primary : scheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: isSelected ? 24 : 22),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.outfit(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.5,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
