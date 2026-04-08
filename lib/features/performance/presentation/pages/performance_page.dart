import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../bloc/performance_bloc.dart';
import '../widgets/speedometer_arc.dart';
import '../../domain/entities/speed_test_progress.dart';
import '../../domain/entities/speed_test_result.dart';
import '../../domain/repositories/speed_test_history_repository.dart';

class PerformancePage extends StatelessWidget {
  const PerformancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PerformanceBloc>(),
      child: const _PerformanceView(),
    );
  }
}

class _PerformanceView extends StatelessWidget {
  const _PerformanceView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: BlocBuilder<PerformanceBloc, PerformanceState>(
          builder: (context, state) {
            final progress = _getProgressFromState(state);
            final isRunning = state is PerformanceRunning;
            final isInitial = state is PerformanceInitial;

            return Column(
              children: [
                // ── Header ──
                _buildHeader(context),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // ── Main Gauge ──
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: SpeedometerArc(
                            download: progress.downloadMbps,
                            upload: progress.uploadMbps,
                            phase: progress.phase,
                            maxSpeed: _autoScale(progress),
                          ),
                        ),

                        // ── Phase Indicator ──
                        _buildPhaseIndicator(context, progress),

                        const SizedBox(height: 32),

                        // ── Stats Grid ──
                        _buildStatsGrid(context, progress),

                        const SizedBox(height: 24),

                        // ── Interpretation Cards ──
                        if (state is PerformanceSuccess)
                          _InterpretationSection(result: progress),

                        const SizedBox(height: 24),

                        // ── Action Button ──
                        if (isInitial || !isRunning)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: NeonButton(
                              onPressed:
                                  () => context.read<PerformanceBloc>().add(
                                    StartSpeedTest(),
                                  ),
                              label:
                                  isInitial
                                      ? context.l10n.performanceStart
                                      : context.l10n.performanceRetry,
                              icon: Icons.bolt_rounded,
                              color: AppColors.neonCyan,
                            ),
                          ),

                        const SizedBox(height: 32),

                        // ── Speed Test History ──
                        _SpeedTestHistorySection(
                          refreshKey: state is PerformanceSuccess,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        children: [
          Text(
            context.l10n.performanceTitle.toUpperCase(),
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator(
    BuildContext context,
    SpeedTestProgress progress,
  ) {
    final phaseText = _getPhaseText(context, progress.phase);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.glassWhite.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassWhite.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (progress.phase != SpeedTestPhase.idle &&
              progress.phase != SpeedTestPhase.done) ...[
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress.phase.index > 0 ? AppColors.neonCyan : Colors.white24,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            phaseText.toUpperCase(),
            style: GoogleFonts.orbitron(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, SpeedTestProgress progress) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: BentoStatTile(
                  label: context.l10n.latencyLabel,
                  value: '${progress.latencyMs.toStringAsFixed(0)} MS',
                  icon: Icons.timer_outlined,
                  color: AppColors.neonCyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BentoStatTile(
                  label: context.l10n.jitterLabel,
                  value: '${progress.jitterMs.toStringAsFixed(1)} MS',
                  icon: Icons.grain_rounded,
                  color: AppColors.neonPurple,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: BentoStatTile(
                  label: 'PACKET LOSS',
                  value: '${progress.packetLoss.toStringAsFixed(1)} %',
                  icon: Icons.signal_cellular_connected_no_internet_4_bar_rounded,
                  color: progress.packetLoss > 1 ? AppColors.neonRed : AppColors.neonGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BentoStatTile(
                  label: 'LOADED LATENCY',
                  value: progress.loadedLatencyMs > 0
                      ? '${progress.loadedLatencyMs.toStringAsFixed(0)} MS'
                      : '--',
                  icon: Icons.speed_rounded,
                  color: AppColors.neonOrange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getPhaseText(BuildContext context, SpeedTestPhase phase) {
    switch (phase) {
      case SpeedTestPhase.idle:
        return context.l10n.phaseIdle;
      case SpeedTestPhase.latency:
        return context.l10n.phasePing;
      case SpeedTestPhase.download:
        return context.l10n.phaseDownload;
      case SpeedTestPhase.upload:
        return context.l10n.phaseUpload;
      case SpeedTestPhase.done:
        return context.l10n.phaseDone;
    }
  }

  SpeedTestProgress _getProgressFromState(PerformanceState state) {
    if (state is PerformanceRunning) return state.progress;
    if (state is PerformanceSuccess) return state.result;
    return const SpeedTestProgress.idle();
  }

  /// Round up to the next clean scale: 100, 200, 500, 1000 …
  double _autoScale(SpeedTestProgress p) {
    final peak = math.max(p.downloadMbps, p.uploadMbps);
    if (peak <= 0) return 100;
    final padded = peak * 1.25;
    for (final step in [50, 100, 200, 500, 1000, 2000, 5000, 10000]) {
      if (padded <= step) return step.toDouble();
    }
    return (padded / 1000).ceil() * 1000.0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Interpretation cards shown after test completion
// ─────────────────────────────────────────────────────────────────────────────

class _InterpretationSection extends StatelessWidget {
  final SpeedTestProgress result;
  const _InterpretationSection({required this.result});

  @override
  Widget build(BuildContext context) {
    final cards = _buildCards(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: NeonSectionHeader(
            label: context.l10n.whatThisMeans,
            icon: Icons.lightbulb_outline_rounded,
            color: AppColors.neonCyan,
          ),
        ),
        ...cards.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: c,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCards(BuildContext context) {
    return [
      _InterpretationCard(
        icon: Icons.timer_outlined,
        color: _latencyColor(result.latencyMs),
        title: _latencyTitle(result.latencyMs),
        body: _latencyBody(result.latencyMs),
      ),
      if (result.jitterMs > 0)
        _InterpretationCard(
          icon: Icons.grain_rounded,
          color: _jitterColor(result.jitterMs),
          title: _jitterTitle(result.jitterMs),
          body: _jitterBody(result.jitterMs),
        ),
      _InterpretationCard(
        icon: Icons.download_rounded,
        color: _downloadColor(result.downloadMbps),
        title: _downloadTitle(result.downloadMbps),
        body: _downloadBody(result.downloadMbps),
      ),
      _InterpretationCard(
        icon: Icons.upload_rounded,
        color: _uploadColor(result.uploadMbps),
        title: _uploadTitle(result.uploadMbps),
        body: _uploadBody(result.uploadMbps),
      ),
      _InterpretationCard(
        icon: Icons.signal_cellular_no_sim_rounded,
        color: _packetLossColor(result.packetLoss),
        title: _packetLossTitle(result.packetLoss),
        body: _packetLossBody(result.packetLoss),
      ),
      if (result.loadedLatencyMs > 0)
        _InterpretationCard(
          icon: Icons.speed_rounded,
          color: _loadedLatencyColor(result.loadedLatencyMs, result.latencyMs),
          title: _loadedLatencyTitle(result.loadedLatencyMs, result.latencyMs),
          body: _loadedLatencyBody(result.loadedLatencyMs, result.latencyMs),
        ),
    ];
  }

  // ── Latency ──
  Color _latencyColor(double ms) {
    if (ms <= 20) return AppColors.neonGreen;
    if (ms <= 50) return AppColors.neonCyan;
    if (ms <= 100) return Colors.orange;
    return AppColors.neonRed;
  }

  String _latencyTitle(double ms) {
    if (ms <= 20) return 'Latency: ${ms.toStringAsFixed(0)} ms — Excellent';
    if (ms <= 50) return 'Latency: ${ms.toStringAsFixed(0)} ms — Good';
    if (ms <= 100) return 'Latency: ${ms.toStringAsFixed(0)} ms — Acceptable';
    return 'Latency: ${ms.toStringAsFixed(0)} ms — High';
  }

  String _latencyBody(double ms) {
    if (ms <= 20) return 'Near-instant response. Ideal for gaming, video calls, and real-time apps.';
    if (ms <= 50) return 'Good for video calls and streaming. Most apps will feel responsive.';
    if (ms <= 100) return 'Fine for browsing and streaming, but video calls may have slight delays.';
    return 'Noticeable lag. Video calls and gaming may feel sluggish. Try moving closer to your router.';
  }

  // ── Jitter ──
  Color _jitterColor(double ms) {
    if (ms <= 5) return AppColors.neonGreen;
    if (ms <= 15) return AppColors.neonCyan;
    if (ms <= 30) return Colors.orange;
    return AppColors.neonRed;
  }

  String _jitterTitle(double ms) {
    if (ms <= 5) return 'Jitter: ${ms.toStringAsFixed(1)} ms — Stable';
    if (ms <= 15) return 'Jitter: ${ms.toStringAsFixed(1)} ms — Good';
    if (ms <= 30) return 'Jitter: ${ms.toStringAsFixed(1)} ms — Moderate';
    return 'Jitter: ${ms.toStringAsFixed(1)} ms — Unstable';
  }

  String _jitterBody(double ms) {
    if (ms <= 5) return 'Very consistent connection. Your packets arrive with minimal timing variation.';
    if (ms <= 15) return 'Stable enough for calls and streaming. Minor variation is normal on Wi-Fi.';
    if (ms <= 30) return 'Some inconsistency detected. Voice calls may sound choppy during spikes.';
    return 'High variation — audio and video calls will likely break up. This can be caused by interference or a congested channel.';
  }

  // ── Download ──
  Color _downloadColor(double mbps) {
    if (mbps >= 100) return AppColors.neonGreen;
    if (mbps >= 25) return AppColors.neonCyan;
    if (mbps >= 5) return Colors.orange;
    return AppColors.neonRed;
  }

  String _downloadTitle(double mbps) {
    if (mbps >= 100) return 'Download: ${mbps.toStringAsFixed(1)} Mbps — Fast';
    if (mbps >= 25) return 'Download: ${mbps.toStringAsFixed(1)} Mbps — Good';
    if (mbps >= 5) return 'Download: ${mbps.toStringAsFixed(1)} Mbps — Moderate';
    return 'Download: ${mbps.toStringAsFixed(1)} Mbps — Slow';
  }

  String _downloadBody(double mbps) {
    final streams = (mbps / 5).floor().clamp(0, 50);
    if (mbps >= 100) return 'Handles $streams+ simultaneous HD streams with ease. Great for large households.';
    if (mbps >= 25) return 'Supports $streams simultaneous HD streams. Good for most households.';
    if (mbps >= 5) return 'Enough for browsing and one or two SD streams. Large downloads will be slow.';
    return 'Very limited. Consider moving closer to your router or checking for interference.';
  }

  // ── Upload ──
  Color _uploadColor(double mbps) {
    if (mbps >= 20) return AppColors.neonGreen;
    if (mbps >= 5) return AppColors.neonCyan;
    if (mbps >= 1) return Colors.orange;
    return AppColors.neonRed;
  }

  String _uploadTitle(double mbps) {
    if (mbps >= 20) return 'Upload: ${mbps.toStringAsFixed(1)} Mbps — Fast';
    if (mbps >= 5) return 'Upload: ${mbps.toStringAsFixed(1)} Mbps — Good';
    if (mbps >= 1) return 'Upload: ${mbps.toStringAsFixed(1)} Mbps — Limited';
    return 'Upload: ${mbps.toStringAsFixed(1)} Mbps — Slow';
  }

  String _uploadBody(double mbps) {
    if (mbps >= 20) return 'Excellent for video conferencing, cloud backups, and live streaming.';
    if (mbps >= 5) return 'Good for video calls and sharing files. Cloud uploads will be reasonable.';
    if (mbps >= 1) return 'Enough for basic video calls. Large file uploads will take a while.';
    return 'Very slow upload. Live video and cloud sync will struggle.';
  }
  // ── Packet Loss ──
  Color _packetLossColor(double percent) {
    if (percent == 0) return AppColors.neonGreen;
    if (percent <= 1) return AppColors.neonCyan;
    if (percent <= 2) return Colors.orange;
    return AppColors.neonRed;
  }

  String _packetLossTitle(double percent) {
    if (percent == 0) return 'Packet Loss: 0% — Perfect';
    if (percent <= 1) return 'Packet Loss: ${percent.toStringAsFixed(1)}% — Minimal';
    return 'Packet Loss: ${percent.toStringAsFixed(1)}% — High';
  }

  String _packetLossBody(double percent) {
    if (percent == 0) return 'Solid connection. No data packets were lost during the assessment.';
    if (percent <= 1) return 'Very minor loss. Likely unnoticeable for most activities.';
    return 'Data is being dropped. This causes stuttering in calls and gaming. Check for Wi-Fi interference.';
  }

  // ── Loaded Latency (Bufferbloat) ──
  Color _loadedLatencyColor(double loaded, double idle) {
    final diff = loaded - idle;
    if (diff <= 10) return AppColors.neonGreen;
    if (diff <= 50) return AppColors.neonCyan;
    if (diff <= 150) return Colors.orange;
    return AppColors.neonRed;
  }

  String _loadedLatencyTitle(double loaded, double idle) {
    final diff = loaded - idle;
    final prefix = 'Loaded Latency: ${loaded.toStringAsFixed(0)} ms';
    if (diff <= 10) return '$prefix — Excellent';
    if (diff <= 50) return '$prefix — Good';
    if (diff <= 150) return '$prefix — Fair';
    return '$prefix — Poor';
  }

  String _loadedLatencyBody(double loaded, double idle) {
    final diff = loaded - idle;
    if (diff <= 10) return 'Your network stays responsive even when downloading. Excellent router quality.';
    if (diff <= 50) return 'Response time increases slightly under load, but stays very usable.';
    if (diff <= 150) return 'Noticeable delay when others are using the network. Gaming while downloading may suffer.';
    return 'High Bufferbloat. Connection becomes unresponsive during large downloads. Consider enabling QoS on your router.';
  }
}

class _InterpretationCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _InterpretationCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      glowColor: color,
      glowIntensity: 0.06,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.rajdhani(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.4,
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

// ─────────────────────────────────────────────────────────────────────────────
// Speed Test History Section
// ─────────────────────────────────────────────────────────────────────────────

class _SpeedTestHistorySection extends StatefulWidget {
  /// Flipping this from false→true triggers a reload (called after a new result).
  final bool refreshKey;
  const _SpeedTestHistorySection({required this.refreshKey});

  @override
  State<_SpeedTestHistorySection> createState() =>
      _SpeedTestHistorySectionState();
}

class _SpeedTestHistorySectionState extends State<_SpeedTestHistorySection> {
  List<SpeedTestResult> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_SpeedTestHistorySection old) {
    super.didUpdateWidget(old);
    if (widget.refreshKey != old.refreshKey && widget.refreshKey) _load();
  }

  Future<void> _load() async {
    final repo = getIt<SpeedTestHistoryRepository>();
    final results = await repo.getRecent(limit: 10);
    if (mounted) setState(() { _results = results; _loading = false; });
  }

  Future<void> _deleteOne(int id) async {
    await getIt<SpeedTestHistoryRepository>().deleteById(id);
    _load();
  }

  Future<void> _deleteAll(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'CLEAR ALL HISTORY',
          style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Delete all speed test records? This cannot be undone.',
          style: GoogleFonts.rajdhani(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL', style: GoogleFonts.orbitron(fontSize: 10)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('DELETE ALL',
                style: GoogleFonts.orbitron(
                    fontSize: 10, color: AppColors.neonRed)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await getIt<SpeedTestHistoryRepository>().deleteAll();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: NeonSectionHeader(
                label: l10n.speedTestHistory,
                icon: Icons.history_rounded,
                color: AppColors.neonPurple,
              ),
            ),
            if (_results.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep_rounded,
                    size: 18, color: AppColors.neonRed),
                tooltip: 'Clear all history',
                onPressed: () => _deleteAll(context),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_results.isEmpty)
          NeonCard(
            glowColor: AppColors.neonPurple,
            glowIntensity: 0.03,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                l10n.noSpeedTestHistory,
                style: GoogleFonts.rajdhani(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ..._results.map((r) => _HistoryRow(
                result: r,
                onDelete: r.id != null ? () => _deleteOne(r.id!) : null,
              )),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final SpeedTestResult result;
  final VoidCallback? onDelete;
  const _HistoryRow({required this.result, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ts = result.recordedAt;
    final label =
        '${ts.day.toString().padLeft(2, '0')}.${ts.month.toString().padLeft(2, '0')} '
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NeonCard(
        glowColor: AppColors.neonPurple,
        glowIntensity: 0.04,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.orbitron(
                color: scheme.onSurfaceVariant,
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            _Stat('↓', result.downloadMbps, AppColors.neonCyan),
            const SizedBox(width: 12),
            _Stat('↑', result.uploadMbps, AppColors.neonPurple),
            const SizedBox(width: 12),
            _Stat('ms', result.latencyMs, AppColors.neonGreen),
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: AppColors.neonRed.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _Stat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            color: color.withValues(alpha: 0.6),
            fontSize: 8,
          ),
        ),
        Text(
          value < 1000
              ? value.toStringAsFixed(1)
              : '${(value / 1000).toStringAsFixed(1)}G',
          style: GoogleFonts.orbitron(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
