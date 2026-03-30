import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../monitoring/presentation/bloc/monitoring_hub_bloc.dart';
import '../../../monitoring/domain/entities/speed_test_progress.dart';
import '../../../monitoring/presentation/widgets/speed_command_gauge.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../security/presentation/pages/security_center_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../monitoring/presentation/pages/topology_page.dart';
import '../../../monitoring/presentation/pages/packet_logs_page.dart';
import '../../../monitoring/presentation/pages/ai_insights_page.dart';
import '../../../../l10n/generated/app_localizations.dart';

class OperationsHubPage extends StatefulWidget {
  const OperationsHubPage({super.key, required this.onNavigate});

  final Function(String route) onNavigate;

  @override
  State<OperationsHubPage> createState() => _OperationsHubPageState();
}

class _OperationsHubPageState extends State<OperationsHubPage> {
  final MonitoringHubBloc _hubBloc = getIt<MonitoringHubBloc>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _hubBloc,
      child: Scaffold(
        body: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                // ── Section 1: SPEED TEST ──
                StaggeredEntry(
                  delay: const Duration(milliseconds: 50),
                  child: NeonSectionHeader(
                    label: l10n.speedTestHeader,
                    icon: Icons.speed_rounded,
                    color: AppColors.neonCyan,
                  ),
                ),
                const SizedBox(height: 16),

                StaggeredEntry(
                  delay: const Duration(milliseconds: 100),
                  child: BlocBuilder<MonitoringHubBloc, MonitoringHubState>(
                    builder: (context, state) {
                      double downloadMbps = 0;
                      double uploadMbps = 0;
                      double latencyMs = 0;
                      bool isRunning = false;
                      String phaseLabel = l10n.startTest;

                      if (state is SpeedTestRunning) {
                        downloadMbps = state.progress.downloadMbps;
                        uploadMbps = state.progress.uploadMbps;
                        latencyMs = state.progress.latencyMs;
                        isRunning = true;
                        phaseLabel = _phaseLabel(state.progress.phase, l10n);
                      } else if (state is SpeedTestSuccess) {
                        downloadMbps = state.progress.downloadMbps;
                        uploadMbps = state.progress.uploadMbps;
                        latencyMs = state.progress.latencyMs;
                        phaseLabel = l10n.testAgain;
                      } else if (state is SpeedTestFailure) {
                        phaseLabel = l10n.retry;
                      }

                      return NeonCard(
                        glowColor: AppColors.neonCyan,
                        glowIntensity: 0.1,
                        onTap: isRunning
                            ? null
                            : () => context
                                .read<MonitoringHubBloc>()
                                .add(RunSpeedTest()),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    phaseLabel,
                                    style: GoogleFonts.orbitron(
                                      color: isRunning
                                          ? AppColors.neonOrange
                                          : AppColors.neonCyan,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isRunning) const PulsingDot(),
                                if (!isRunning && latencyMs > 0) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '${latencyMs.toStringAsFixed(0)} ms',
                                    style: GoogleFonts.rajdhani(
                                      color: AppColors.neonGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
                      );
                    },
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
                      onTap:
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SecurityCenterPage(),
                            ),
                          ),
                      delay: 300,
                    ),
                    _OperationCard(
                      title: l10n.logisticsTitle,
                      subtitle: l10n.intelMetrics,
                      icon: Icons.analytics_outlined,
                      color: AppColors.neonOrange,
                      onTap:
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ReportsPage(),
                            ),
                          ),
                      delay: 400,
                    ),
                    _OperationCard(
                      title: l10n.topologyLabel,
                      subtitle: l10n.networkMesh,
                      icon: Icons.device_hub_rounded,
                      color: AppColors.neonGreen,
                      onTap:
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TopologyPage(),
                            ),
                          ),
                      delay: 500,
                    ),
                    _OperationCard(
                      title: l10n.tuningTitle,
                      subtitle: l10n.systemConfig,
                      icon: Icons.settings_suggest_rounded,
                      color: AppColors.neonCyan,
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

  String _phaseLabel(SpeedTestPhase phase, AppLocalizations l10n) {
    switch (phase) {
      case SpeedTestPhase.latency:
        return l10n.phasePing;
      case SpeedTestPhase.download:
        return l10n.phaseDownload;
      case SpeedTestPhase.upload:
        return l10n.phaseUpload;
      case SpeedTestPhase.done:
        return l10n.phaseDone;
      case SpeedTestPhase.idle:
        return l10n.startTest;
    }
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
          onTap:
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PacketLogsPage()),
              ),
        ),
        const SizedBox(height: 12),
        _ToolTile(
          label: l10n.aiInsights,
          icon: Icons.psychology_rounded,
          color: AppColors.neonGreen,
          delay: 850,
          onTap:
              () => Navigator.of(context).push(
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
            Expanded(
              child: Column(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppLocalizations.of(context)!.interactiveSimulation,
                    style: GoogleFonts.shareTechMono(
                      color: color.withValues(alpha: 0.4),
                      fontSize: 8,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
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
