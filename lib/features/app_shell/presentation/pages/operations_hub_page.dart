import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../performance/presentation/pages/performance_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../security/presentation/pages/security_center_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../monitoring/presentation/pages/topology_page.dart';
import '../../../security/presentation/pages/vulnerability_lab_page.dart';
import '../../../heatmap/presentation/pages/heatmap_page.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/cyber_neomorphic_button.dart';
import '../../../../core/theme/app_theme.dart';

class OperationsHubPage extends StatelessWidget {
  const OperationsHubPage({super.key, required this.onNavigate});

  final Function(String route) onNavigate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          // ── COMMAND CENTERS ──
          StaggeredEntry(
            delay: const Duration(milliseconds: 50),
            child: NeonSectionHeader(
              label: l10n.commandCenters,
              icon: Icons.hub_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.15,
            children: [
              _OperationCard(
                title: l10n.performanceTitle,
                subtitle: l10n.speedTestHeader,
                icon: Icons.speed_rounded,
                color: Theme.of(context).colorScheme.primary,
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PerformancePage(),
                      ),
                    ),
                delay: 100,
              ),
              _OperationCard(
                title: l10n.defenseTitle,
                subtitle: l10n.activeShielding,
                icon: Icons.security_rounded,
                color: Colors.indigoAccent,
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SecurityCenterPage(),
                      ),
                    ),
                delay: 200,
              ),
              _OperationCard(
                title: l10n.topologyLabel,
                subtitle: l10n.networkMesh,
                icon: Icons.device_hub_rounded,
                color: Theme.of(context).colorScheme.tertiary,
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TopologyRoute(),
                      ),
                    ),
                delay: 300,
              ),
              _OperationCard(
                title: l10n.logisticsTitle,
                subtitle: l10n.intelMetrics,
                icon: Icons.analytics_outlined,
                color: Theme.of(context).colorScheme.outline,
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ReportsPage(),
                      ),
                    ),
                delay: 400,
              ),
              _OperationCard(
                title: l10n.heatmapTooltip,
                subtitle: l10n.temporalHeatmap,
                icon: Icons.map_rounded,
                color: Colors.cyanAccent,
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HeatmapPage(),
                      ),
                    ),
                delay: 450,
              ),
              _OperationCard(
                title: l10n.vulnLabTitle,
                subtitle: l10n.vulnLabSubtitle,
                icon: Icons.biotech_rounded,
                color: const Color(0xFFFF6B35),
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const VulnerabilityLabPage(),
                      ),
                    ),
                delay: 500,
              ),
              _OperationCard(
                title: l10n.tuningTitle,
                subtitle: l10n.systemConfig,
                icon: Icons.settings_suggest_rounded,
                color: Theme.of(context).colorScheme.secondary,
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    ),
                delay: 600,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Existing widgets ────────────────────────────────────────────────────────

class _OperationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int delay;

  const _OperationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredEntry(
      delay: Duration(milliseconds: delay),
      child: CyberNeomorphicButton(
        onPressed: onTap,
        borderRadius: 24,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? color.withValues(alpha: 0.9)
                    : AppColors.textPrimaryLight,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
