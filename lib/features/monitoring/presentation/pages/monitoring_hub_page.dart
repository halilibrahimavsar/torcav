import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/speed_test_progress.dart';
import '../bloc/monitoring_hub_bloc.dart';

class MonitoringHubPage extends StatelessWidget {
  const MonitoringHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<MonitoringHubBloc>(),
      child: const _MonitoringHubView(),
    );
  }
}

class _MonitoringHubView extends StatelessWidget {
  const _MonitoringHubView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<MonitoringHubBloc, MonitoringHubState>(
      listener: (context, state) {
        if (state is SpeedTestFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speed test failed: ${state.message}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Monitoring Hub',
            style: GoogleFonts.orbitron(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bandwidth, anomaly detection, and heatmap streams.',
            style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 15),
          ),
          const SizedBox(height: 20),
          const _SpeedTestSection(),
          const SizedBox(height: 16),
          _featureCard(
            icon: Icons.show_chart,
            title: 'Signal Trends',
            subtitle: 'Live dBm history and fluctuation spread',
          ),
          _featureCard(
            icon: Icons.route,
            title: 'Topology and Mesh',
            subtitle: 'Device relationships and path visibility',
          ),
          _featureCard(
            icon: Icons.warning_amber_rounded,
            title: 'Anomaly Alerts',
            subtitle: 'Threshold-based detections with rate-limiting',
          ),
        ],
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF121E31),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
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
                Text(
                  subtitle,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Speed Test Section ──────────────────────────────────────────────

class _SpeedTestSection extends StatelessWidget {
  const _SpeedTestSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonitoringHubBloc, MonitoringHubState>(
      builder: (context, state) {
        final isRunning = state is SpeedTestRunning;
        final progress = switch (state) {
          SpeedTestRunning(:final progress) => progress,
          SpeedTestSuccess(:final progress) => progress,
          _ => null,
        };
        final isDone = state is SpeedTestSuccess;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
            ),
            border: Border.all(
              color: AppTheme.secondaryColor.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondaryColor.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.speed_rounded,
                      color: AppTheme.secondaryColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SPEED TEST',
                      style: GoogleFonts.orbitron(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    if (isRunning && progress != null)
                      _PhaseChip(phase: progress.phase),
                  ],
                ),
                const SizedBox(height: 20),

                // Content
                if (progress != null)
                  _LiveGauges(progress: progress, isRunning: isRunning)
                else if (!isRunning)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Test your connection speed',
                        style: GoogleFonts.rajdhani(
                          color: Colors.white38,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 18),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isRunning
                            ? null
                            : () => context.read<MonitoringHubBloc>().add(
                              RunSpeedTest(),
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: AppTheme.secondaryColor
                          .withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isRunning
                          ? 'TESTING…'
                          : isDone
                          ? 'TEST AGAIN'
                          : 'START TEST',
                      style: GoogleFonts.orbitron(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Phase Chip ──────────────────────────────────────────────────────

class _PhaseChip extends StatelessWidget {
  final SpeedTestPhase phase;
  const _PhaseChip({required this.phase});

  @override
  Widget build(BuildContext context) {
    final label = switch (phase) {
      SpeedTestPhase.latency => 'PING',
      SpeedTestPhase.download => 'DOWNLOAD',
      SpeedTestPhase.upload => 'UPLOAD',
      SpeedTestPhase.done => 'DONE',
      SpeedTestPhase.idle => '',
    };

    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.secondaryColor.withValues(alpha: 0.15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.secondaryColor,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              color: AppTheme.secondaryColor,
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Live Gauges ─────────────────────────────────────────────────────

class _LiveGauges extends StatelessWidget {
  final SpeedTestProgress progress;
  final bool isRunning;

  const _LiveGauges({required this.progress, required this.isRunning});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GaugeCard(
            label: 'DOWNLOAD',
            value: progress.downloadMbps,
            unit: 'Mbps',
            maxValue: 200,
            color: const Color(0xFF00E5FF),
            icon: Icons.arrow_downward_rounded,
            isActive: isRunning && progress.phase == SpeedTestPhase.download,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GaugeCard(
            label: 'UPLOAD',
            value: progress.uploadMbps,
            unit: 'Mbps',
            maxValue: 100,
            color: const Color(0xFF76FF03),
            icon: Icons.arrow_upward_rounded,
            isActive: isRunning && progress.phase == SpeedTestPhase.upload,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GaugeCard(
            label: 'PING',
            value: progress.latencyMs,
            unit: 'ms',
            maxValue: 200,
            color: const Color(0xFFFFAB40),
            icon: Icons.timer_outlined,
            isActive: isRunning && progress.phase == SpeedTestPhase.latency,
          ),
        ),
      ],
    );
  }
}

class _GaugeCard extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double maxValue;
  final Color color;
  final IconData icon;
  final bool isActive;

  const _GaugeCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.maxValue,
    required this.color,
    required this.icon,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = (value / maxValue).clamp(0.0, 1.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color:
            isActive
                ? color.withValues(alpha: 0.12)
                : color.withValues(alpha: 0.06),
        border: Border.all(
          color:
              isActive
                  ? color.withValues(alpha: 0.4)
                  : color.withValues(alpha: 0.15),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(
              painter: _ArcGaugePainter(fraction: fraction, color: color),
              child: Center(
                child:
                    isActive
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        )
                        : Icon(icon, color: color, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value > 0 ? value.toStringAsFixed(1) : '—',
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.rajdhani(
              color: color.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              color: Colors.white38,
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Arc Gauge Painter ───────────────────────────────────────────────

class _ArcGaugePainter extends CustomPainter {
  final double fraction;
  final Color color;

  _ArcGaugePainter({required this.fraction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const startAngle = math.pi * 0.75;
    const sweepFull = math.pi * 1.5;

    // Track
    final trackPaint =
        Paint()
          ..color = color.withValues(alpha: 0.12)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepFull,
      false,
      trackPaint,
    );

    // Active arc
    if (fraction > 0) {
      final activePaint =
          Paint()
            ..color = color
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepFull * fraction,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcGaugePainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.color != color;
}
