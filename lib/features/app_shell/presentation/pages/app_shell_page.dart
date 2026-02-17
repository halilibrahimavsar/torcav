import 'package:flutter/material.dart';

import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../monitoring/presentation/pages/monitoring_hub_page.dart';
import '../../../network_scan/presentation/pages/network_scan_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../security/presentation/pages/security_center_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../wifi_scan/presentation/pages/wifi_scan_page.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key});

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs();
    final isWide = MediaQuery.sizeOf(context).width >= 980;

    return Scaffold(
      appBar: AppBar(title: Text(tabs[_index].title)),
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              labelType: NavigationRailLabelType.all,
              destinations:
                  tabs
                      .map(
                        (tab) => NavigationRailDestination(
                          icon: Icon(tab.icon),
                          label: Text(tab.title),
                        ),
                      )
                      .toList(),
            ),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: tabs.map((tab) => tab.page).toList(growable: false),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          isWide
              ? null
              : NavigationBar(
                selectedIndex: _index,
                onDestinationSelected:
                    (value) => setState(() => _index = value),
                destinations:
                    tabs
                        .map(
                          (tab) => NavigationDestination(
                            icon: Icon(tab.icon),
                            label: tab.title,
                          ),
                        )
                        .toList(),
              ),
    );
  }

  List<_ShellTab> _tabs() {
    return [
      _ShellTab(
        title: 'Dashboard',
        icon: Icons.dashboard_outlined,
        page: DashboardPage(onSelectTab: (tab) => setState(() => _index = tab)),
      ),
      const _ShellTab(title: 'Wi-Fi', icon: Icons.wifi, page: WifiScanPage()),
      const _ShellTab(
        title: 'Security',
        icon: Icons.security,
        page: SecurityCenterPage(),
      ),
      const _ShellTab(title: 'LAN', icon: Icons.radar, page: NetworkScanPage()),
      const _ShellTab(
        title: 'Monitoring',
        icon: Icons.show_chart,
        page: MonitoringHubPage(),
      ),
      const _ShellTab(
        title: 'Reports',
        icon: Icons.description_outlined,
        page: ReportsPage(),
      ),
      const _ShellTab(
        title: 'Settings',
        icon: Icons.tune,
        page: SettingsPage(),
      ),
    ];
  }
}

class _ShellTab {
  final String title;
  final IconData icon;
  final Widget page;

  const _ShellTab({
    required this.title,
    required this.icon,
    required this.page,
  });
}
