import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  final void Function(int tabIndex) onSelectTab;

  const DashboardPage({super.key, required this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A111A), Color(0xFF121F32), Color(0xFF09111D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Torcav Command Center',
            style: GoogleFonts.orbitron(
              fontSize: 28,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Wi-Fi intelligence, network mapping, and security analytics in one workflow.',
            style: GoogleFonts.rajdhani(
              color: Colors.white70,
              fontSize: 18,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _actionCard(
                context,
                icon: Icons.wifi_tethering,
                title: 'Run Wi-Fi Scan',
                subtitle: 'Multi-pass scan with channel analytics',
                onTap: () => onSelectTab(1),
              ),
              _actionCard(
                context,
                icon: Icons.security,
                title: 'Security Center',
                subtitle: 'Risk scoring and allowlist policy',
                onTap: () => onSelectTab(2),
              ),
              _actionCard(
                context,
                icon: Icons.radar,
                title: 'LAN Recon',
                subtitle: 'Nmap profiles and exposure scoring',
                onTap: () => onSelectTab(3),
              ),
              _actionCard(
                context,
                icon: Icons.show_chart,
                title: 'Monitoring',
                subtitle: 'Live dBm and trend visualization',
                onTap: () => onSelectTab(4),
              ),
              _actionCard(
                context,
                icon: Icons.description,
                title: 'Reports',
                subtitle: 'PDF / JSON / HTML export',
                onTap: () => onSelectTab(5),
              ),
              _actionCard(
                context,
                icon: Icons.tune,
                title: 'Settings',
                subtitle: 'Intervals, profiles, safety controls',
                onTap: () => onSelectTab(6),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _statusStrip(),
        ],
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isWide = MediaQuery.sizeOf(context).width > 700;
    final width = isWide ? (MediaQuery.sizeOf(context).width - 56) / 2 : 1e9;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.4),
          ),
          color: const Color(0xFF101A2A),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.14),
              child: Icon(icon, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.rajdhani(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _statusStrip() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1622),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.secondaryColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user, color: AppTheme.secondaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Safety mode: strict consent + allowlist enabled for active operations.',
              style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
