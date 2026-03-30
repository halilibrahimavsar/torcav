import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../monitoring/presentation/bloc/monitoring_bloc.dart';
import '../../../monitoring/presentation/widgets/speed_command_gauge.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../security/presentation/pages/security_center_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../monitoring/presentation/pages/topology_page.dart';
import '../../../monitoring/presentation/pages/packet_logs_page.dart';
import '../../../monitoring/presentation/pages/ai_insights_page.dart';
import '../../../../l10n/generated/app_localizations.dart';

class OperationsHubPage extends StatefulWidget {
  const OperationsHubPage({
    super.key,
    required this.onNavigate,
  });

  final Function(String route) onNavigate;

  @override
  State<OperationsHubPage> createState() => _OperationsHubPageState();
}

class _OperationsHubPageState extends State<OperationsHubPage> {
  final MonitoringBloc _bloc = getIt<MonitoringBloc>();

  @override
  void dispose() {
    _bloc.add(StopMonitoring());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        body: BlocBuilder<MonitoringBloc, MonitoringState>(
          builder: (context, state) {
            final l10n = AppLocalizations.of(context)!;
            double downloadMbps = 0;
            double uploadMbps = 0;
            bool isActive = false;

            if (state is MonitoringActive) {
              final sample = state.latestBandwidth;
              if (sample != null) {
                downloadMbps = (sample.rxBps * 8) / 1000000;
                uploadMbps = (sample.txBps * 8) / 1000000;
              }
              isActive = true;
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                // ── Section 1: ACTIVE MONITORING ──
                StaggeredEntry(
                  delay: const Duration(milliseconds: 50),
                  child: NeonSectionHeader(
                    label: l10n.activeMonitoring,
                    icon: Icons.radar_rounded,
                    color: AppColors.neonCyan,
                  ),
                ),
                const SizedBox(height: 16),
                
                StaggeredEntry(
                  delay: const Duration(milliseconds: 100),
                  child: NeonCard(
                    glowColor: AppColors.neonCyan,
                    glowIntensity: 0.1,
                    onTap: () {
                      if (isActive) {
                        _bloc.add(StopMonitoring());
                      } else {
                        _bloc.add(const StartBandwidthMonitoring('wlan0'));
                      }
                    },
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isActive ? l10n.deactivate : l10n.initializeLink,
                              style: GoogleFonts.orbitron(
                                color: isActive ? AppColors.neonRed : AppColors.neonCyan,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            if (isActive) const PulsingDot(),
                          ],
                        ),
                        SizedBox(
                          height: 180,
                          child: SpeedCommandGauge(
                            download: downloadMbps,
                            upload: uploadMbps,
                            maxSpeed: math.max(100.0, downloadMbps * 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),

                // ── Section 2: COMMAND CENTERS ──
                StaggeredEntry(
                  delay: const Duration(milliseconds: 200),
                  child: NeonSectionHeader(
                    label: l10n.commandCenters,
                    icon: Icons.hub_rounded,
                    color: AppColors.neonPurple,
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
                      title: l10n.defenseTitle,
                      subtitle: l10n.activeShielding,
                      icon: Icons.shield_rounded,
                      color: AppColors.neonRed,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SecurityCenterPage()),
                      ),
                      delay: 300,
                    ),
                    _OperationCard(
                      title: l10n.logisticsTitle,
                      subtitle: l10n.intelMetrics,
                      icon: Icons.analytics_outlined,
                      color: AppColors.neonOrange,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ReportsPage()),
                      ),
                      delay: 400,
                    ),
                    _OperationCard(
                      title: l10n.topologyLabel,
                      subtitle: l10n.networkMesh,
                      icon: Icons.device_hub_rounded,
                      color: AppColors.neonGreen,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const TopologyPage()),
                      ),
                      delay: 500,
                    ),
                    _OperationCard(
                      title: l10n.tuningTitle,
                      subtitle: l10n.systemConfig,
                      icon: Icons.settings_suggest_rounded,
                      color: AppColors.neonCyan,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      ),
                      delay: 600,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),

                // ── Section 3: ADVANCED TOOLS ──
                StaggeredEntry(
                  delay: const Duration(milliseconds: 700),
                  child: NeonSectionHeader(
                    label: l10n.technicalTools,
                    icon: Icons.terminal_rounded,
                    color: AppColors.neonCyan.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAdvancedTools(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdvancedTools() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _ToolTile(
          label: l10n.packetLogs,
          icon: Icons.list_alt_rounded,
          color: AppColors.neonPurple,
          delay: 750,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PacketLogsPage()),
          ),
        ),
        const SizedBox(height: 12),
        _ToolTile(
          label: l10n.aiInsights,
          icon: Icons.psychology_rounded,
          color: AppColors.neonGreen,
          delay: 850,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AIInsightsPage()),
          ),
        ),
      ],
    );
  }
}

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
      child: NeonCard(
        glowColor: color,
        glowIntensity: 0.06,
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.rajdhani(
                color: AppColors.textMuted,
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

class _ToolTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int delay;
  final VoidCallback onTap;

  const _ToolTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredEntry(
      delay: Duration(milliseconds: delay),
      slideOffset: 10,
      child: NeonCard(
        onTap: onTap,
        glowColor: color,
        glowIntensity: 0.05,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.orbitron(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.interactiveSimulation,
                  style: GoogleFonts.shareTechMono(
                    color: color.withValues(alpha: 0.4),
                    fontSize: 8,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: color.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
