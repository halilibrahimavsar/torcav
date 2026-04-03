import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/di/injection.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../monitoring/presentation/bloc/monitoring_hub_bloc.dart';
import '../../../monitoring/domain/entities/speed_test_progress.dart';
import '../../../monitoring/presentation/widgets/speed_command_gauge.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../security/presentation/pages/security_center_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../monitoring/presentation/pages/topology_page.dart';
import 'package:torcav/core/l10n/app_localizations.dart';

class OperationsHubPage extends StatefulWidget {
  const OperationsHubPage({super.key, required this.onNavigate});

  final Function(String route) onNavigate;

  @override
  State<OperationsHubPage> createState() => _OperationsHubPageState();
}

class _OperationsHubPageState extends State<OperationsHubPage> {
  late final MonitoringHubBloc _hubBloc = getIt<MonitoringHubBloc>();

  @override
  void dispose() {
    _hubBloc.close();
    super.dispose();
  }

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
                    color: Theme.of(context).colorScheme.primary,
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
                      bool isDone = false;
                      String phaseLabel = l10n.startTest;
                      SpeedTestPhase phase = SpeedTestPhase.idle;

                      if (state is SpeedTestRunning) {
                        downloadMbps = state.progress.downloadMbps;
                        uploadMbps = state.progress.uploadMbps;
                        latencyMs = state.progress.latencyMs;
                        isRunning = true;
                        phase = state.progress.phase;
                        phaseLabel = _phaseLabel(phase, l10n);
                      } else if (state is SpeedTestSuccess) {
                        downloadMbps = state.progress.downloadMbps;
                        uploadMbps = state.progress.uploadMbps;
                        latencyMs = state.progress.latencyMs;
                        phase = SpeedTestPhase.done;
                        isDone = true;
                        phaseLabel = l10n.testAgain;
                      } else if (state is SpeedTestFailure) {
                        phaseLabel = l10n.retry;
                      }

                      return NeonCard(
                        glowColor: Theme.of(context).colorScheme.primary,
                        glowIntensity: isDone ? 0.18 : 0.1,
                        onTap:
                            isRunning
                                ? null
                                : () => context.read<MonitoringHubBloc>().add(
                                  RunSpeedTest(),
                                ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // ── Header row ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    phaseLabel,
                                    style: GoogleFonts.orbitron(
                                      color:
                                          isRunning
                                              ? Theme.of(context).colorScheme.outline
                                              : isDone
                                              ? Theme.of(context).colorScheme.tertiary
                                              : Theme.of(context).colorScheme.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isRunning)
                                  const PulsingDot()
                                else if (isDone)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 14,
                                    color: Theme.of(context).colorScheme.tertiary.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                              ],
                            ),

                            // ── Phase progress indicator while running ──
                            if (isRunning) ...[
                              const SizedBox(height: 8),
                              _PhaseSteps(phase: phase),
                            ],

                            const SizedBox(height: 4),

                            // ── Gauge ──
                            SizedBox(
                              height: 180,
                              child: SpeedCommandGauge(
                                download: downloadMbps,
                                upload: uploadMbps,
                                maxSpeed: math.max(100.0, downloadMbps * 1.5),
                                phase: phase,
                              ),
                            ),

                            // ── Results panel (only after completion) ──
                            AnimatedSize(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              child:
                                  isDone
                                      ? Column(
                                        children: [
                                          const SizedBox(height: 16),
                                          _ResultsRow(
                                            downloadMbps: downloadMbps,
                                            uploadMbps: uploadMbps,
                                            latencyMs: latencyMs,
                                          ),
                                        ],
                                      )
                                      : const SizedBox.shrink(),
                            ),

                            // ── Error state ──
                            if (state is SpeedTestFailure) ...[
                              const SizedBox(height: 12),
                              Text(
                                state.message,
                                style: GoogleFonts.rajdhani(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
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
                      title: l10n.defenseTitle,
                      subtitle: l10n.activeShielding,
                      icon: Icons.shield_rounded,
                      color: Theme.of(context).colorScheme.error,
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
                      title: l10n.topologyLabel,
                      subtitle: l10n.networkMesh,
                      icon: Icons.device_hub_rounded,
                      color: Theme.of(context).colorScheme.tertiary,
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
                      color: Theme.of(context).colorScheme.primary,
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
}

// ── Phase step indicator shown during active test ──────────────────────────

class _PhaseSteps extends StatelessWidget {
  final SpeedTestPhase phase;

  const _PhaseSteps({required this.phase});

  @override
  Widget build(BuildContext context) {
    final phases = [
      (SpeedTestPhase.latency, Icons.network_ping_rounded, 'PING'),
      (SpeedTestPhase.download, Icons.download_rounded, 'DL'),
      (SpeedTestPhase.upload, Icons.upload_rounded, 'UL'),
    ];

    final currentIndex = phases
        .indexWhere((p) => p.$1 == phase)
        .clamp(0, phases.length - 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(phases.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIndex = i ~/ 2;
          return Expanded(
            child: Container(
              height: 1,
              color:
                  stepIndex < currentIndex
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)
                      : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final (_, icon, label) = phases[stepIndex];
        final isActive = stepIndex == currentIndex;
        final isDone = stepIndex < currentIndex;
        final color =
            isDone
                ? Theme.of(context).colorScheme.primary
                : isActive
                ? Theme.of(context).colorScheme.outline
                : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.orbitron(
                fontSize: 7,
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Results row shown after completion ─────────────────────────────────────

class _ResultsRow extends StatelessWidget {
  final double downloadMbps;
  final double uploadMbps;
  final double latencyMs;

  const _ResultsRow({
    required this.downloadMbps,
    required this.uploadMbps,
    required this.latencyMs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            label: 'DOWNLOAD',
            value: downloadMbps.toStringAsFixed(1),
            unit: 'Mbps',
            icon: Icons.download_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            label: 'UPLOAD',
            value: uploadMbps.toStringAsFixed(1),
            unit: 'Mbps',
            icon: Icons.upload_rounded,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            label: 'PING',
            value: latencyMs.toStringAsFixed(0),
            unit: 'ms',
            icon: Icons.network_ping_rounded,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.rajdhani(
              fontSize: 10,
              color: color.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 7,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
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
