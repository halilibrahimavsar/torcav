import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/l10n/app_localizations.dart';

import '../../../../core/presentation/widgets/cyber_neomorphic_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../heatmap/presentation/pages/heatmap_page.dart';
import '../../../monitoring/presentation/pages/spectrum_optimization_page.dart';
import '../../../performance/presentation/pages/speed_hub_page.dart';
import '../../../ping_stabilizer/presentation/pages/ping_stabilizer_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../security/presentation/pages/security_center_page.dart';

/// Operations hub — every command center grouped by the question it answers,
/// so the user can find a feature by its purpose rather than scan a flat grid.
class OperationsHubPage extends StatelessWidget {
  const OperationsHubPage({
    super.key,
    required this.onNavigate,
  });

  final Function(String route) onNavigate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          // ── SECURITY ──
          _GroupHeader(label: l10n.opsGroupSecurity, color: scheme.secondary),
          _CardGrid(
            cards: [
              _OperationCard(
                title: l10n.securityLabel,
                subtitle: l10n.opsSecuritySubtitle,
                icon: Icons.security_rounded,
                color: Colors.indigoAccent,
                onTap: () => _push(context, const SecurityCenterPage()),
                delay: 100,
              ),
            ],
          ),

          // ── SPEED & CONNECTION ──
          _GroupHeader(label: l10n.opsGroupSpeed, color: scheme.primary),
          _CardGrid(
            cards: [
              _OperationCard(
                title: l10n.speedHubTitle,
                subtitle: l10n.opsSpeedSubtitle,
                icon: Icons.speed_rounded,
                color: scheme.primary,
                onTap: () => _push(context, const SpeedHubPage()),
                delay: 150,
              ),
              _OperationCard(
                title: l10n.pingStabilizerTitle,
                subtitle: l10n.pingStabilizerSubtitle,
                icon: Icons.shield_rounded,
                color: AppColors.neonPurple,
                onTap: () => _push(context, const PingStabilizerPage()),
                delay: 200,
              ),
            ],
          ),

          // ── COVERAGE ──
          _GroupHeader(label: l10n.opsGroupCoverage, color: scheme.tertiary),
          _CardGrid(
            cards: [
              _OperationCard(
                title: l10n.spectrumOptimizationCaps,
                subtitle: l10n.spectrumOptimizationOpsSubtitle,
                icon: Icons.auto_graph_rounded,
                color: AppColors.neonPurple,
                onTap:
                    () => _push(context, const SpectrumOptimizationPage()),
                delay: 250,
              ),
              _OperationCard(
                title: l10n.heatmapTooltip,
                subtitle: l10n.opsHeatmapSubtitle,
                icon: Icons.map_rounded,
                color: Colors.cyanAccent,
                onTap: () => _push(context, const HeatmapPage()),
                delay: 300,
              ),
            ],
          ),

          // ── REPORTS ──
          _GroupHeader(label: l10n.opsGroupReports, color: scheme.outline),
          _CardGrid(
            cards: [
              _OperationCard(
                title: l10n.reportsTitle,
                subtitle: l10n.opsReportsSubtitle,
                icon: Icons.analytics_outlined,
                color: scheme.outline,
                onTap: () => _push(context, const ReportsPage()),
                delay: 350,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: StaggeredEntry(
        delay: const Duration(milliseconds: 50),
        child: NeonSectionHeader(
          label: label,
          icon: Icons.hub_rounded,
          color: color,
        ),
      ),
    );
  }
}

class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: cards,
    );
  }
}

// ── Operation card ──────────────────────────────────────────────────────────

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
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? color.withValues(alpha: 0.9)
                        : AppColors.textPrimaryLight,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
