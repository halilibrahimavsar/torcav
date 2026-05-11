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

class _PerformanceView extends StatefulWidget {
  const _PerformanceView();

  @override
  State<_PerformanceView> createState() => _PerformanceViewState();
}

class _PerformanceViewState extends State<_PerformanceView> {
  Future<void> _startTestWithWarning() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Theme.of(ctx).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              l10n.dataUsageWarningTitle,
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.neonOrange,
                letterSpacing: 1,
              ),
            ),
            content: Text(
              l10n.dataUsageWarningBody,
              style: GoogleFonts.rajdhani(fontSize: 14, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  l10n.cancel,
                  style: GoogleFonts.orbitron(fontSize: 10),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  l10n.continueAction,
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    color: AppColors.neonCyan,
                  ),
                ),
              ),
            ],
          ),
    );
    if (confirmed == true && mounted) {
      context.read<PerformanceBloc>().add(StartSpeedTest());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: BlocBuilder<PerformanceBloc, PerformanceState>(
          builder: (context, state) {
            final progress = _getProgressFromState(state);
            final isRunning = state is PerformanceRunning;

            return Column(
              children: [
                // ── Header ──
                _buildHeader(context),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // ── Main Gauge (tap to start/stop) ──
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: SpeedometerArc(
                            download: progress.downloadMbps,
                            upload: progress.uploadMbps,
                            phase: progress.phase,
                            maxSpeed: _autoScale(progress),
                            onTap: isRunning
                                ? () => context
                                    .read<PerformanceBloc>()
                                    .add(StopSpeedTest())
                                : _startTestWithWarning,
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

                        // ── Disclaimer ──
                        if (state is PerformanceSuccess)
                          _DisclaimerCard(),

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
                  progress.phase.index > 0
                      ? AppColors.neonCyan
                      : Colors.white24,
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
                  label: context.l10n.packetLossLabel,
                  value: '${progress.packetLoss.toStringAsFixed(1)} %',
                  icon:
                      Icons.signal_cellular_connected_no_internet_4_bar_rounded,
                  color:
                      progress.packetLoss > 1
                          ? AppColors.neonRed
                          : AppColors.neonGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BentoStatTile(
                  label: context.l10n.loadedLatencyLabel,
                  value:
                      progress.loadedLatencyMs > 0
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
          (c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: c),
        ),
      ],
    );
  }

  List<Widget> _buildCards(BuildContext context) {
    return [
      _InterpretationCard(
        icon: Icons.timer_outlined,
        color: _latencyColor(result.latencyMs),
        title: _latencyTitle(context, result.latencyMs),
        body: _latencyBody(context, result.latencyMs),
      ),
      if (result.jitterMs > 0)
        _InterpretationCard(
          icon: Icons.grain_rounded,
          color: _jitterColor(result.jitterMs),
          title: _jitterTitle(context, result.jitterMs),
          body: _jitterBody(context, result.jitterMs),
        ),
      _InterpretationCard(
        icon: Icons.download_rounded,
        color: _downloadColor(result.downloadMbps),
        title: _downloadTitle(context, result.downloadMbps),
        body: _downloadBody(context, result.downloadMbps),
      ),
      _InterpretationCard(
        icon: Icons.upload_rounded,
        color: _uploadColor(result.uploadMbps),
        title: _uploadTitle(context, result.uploadMbps),
        body: _uploadBody(context, result.uploadMbps),
      ),
      _InterpretationCard(
        icon: Icons.signal_cellular_no_sim_rounded,
        color: _packetLossColor(result.packetLoss),
        title: _packetLossTitle(context, result.packetLoss),
        body: _packetLossBody(context, result.packetLoss),
      ),
      if (result.loadedLatencyMs > 0) ...[
        _InterpretationCard(
          icon: Icons.speed_rounded,
          color: _loadedLatencyColor(result.loadedLatencyMs, result.latencyMs),
          title: _loadedLatencyTitle(context, result.loadedLatencyMs, result.latencyMs),
          body: _loadedLatencyBody(context, result.loadedLatencyMs, result.latencyMs),
        ),
        _BufferbloatGradeCard(
          loadedLatencyMs: result.loadedLatencyMs,
          idleLatencyMs: result.latencyMs,
        ),
      ],
    ];
  }

  // ── Latency ──
  Color _latencyColor(double ms) {
    if (ms <= 20) return AppColors.neonGreen;
    if (ms <= 50) return AppColors.neonCyan;
    if (ms <= 100) return Colors.orange;
    return AppColors.neonRed;
  }

  String _latencyTitle(BuildContext context, double ms) {
    final l10n = context.l10n;
    final msStr = ms.toStringAsFixed(0);
    if (ms <= 20) return l10n.latencyExcellentTitle(msStr);
    if (ms <= 50) return l10n.latencyGoodTitle(msStr);
    if (ms <= 100) return l10n.latencyAcceptableTitle(msStr);
    return l10n.latencyHighTitle(msStr);
  }

  String _latencyBody(BuildContext context, double ms) {
    final l10n = context.l10n;
    if (ms <= 20) return l10n.latencyExcellentBody;
    if (ms <= 50) return l10n.latencyGoodBody;
    if (ms <= 100) return l10n.latencyAcceptableBody;
    return l10n.latencyHighBody;
  }

  // ── Jitter ──
  Color _jitterColor(double ms) {
    if (ms <= 5) return AppColors.neonGreen;
    if (ms <= 15) return AppColors.neonCyan;
    if (ms <= 30) return Colors.orange;
    return AppColors.neonRed;
  }

  String _jitterTitle(BuildContext context, double ms) {
    final l10n = context.l10n;
    final msStr = ms.toStringAsFixed(1);
    if (ms <= 5) return l10n.jitterStableTitle(msStr);
    if (ms <= 15) return l10n.jitterGoodTitle(msStr);
    if (ms <= 30) return l10n.jitterModerateTitle(msStr);
    return l10n.jitterUnstableTitle(msStr);
  }

  String _jitterBody(BuildContext context, double ms) {
    final l10n = context.l10n;
    if (ms <= 5) return l10n.jitterStableBody;
    if (ms <= 15) return l10n.jitterGoodBody;
    if (ms <= 30) return l10n.jitterModerateBody;
    return l10n.jitterUnstableBody;
  }

  // ── Download ──
  Color _downloadColor(double mbps) {
    if (mbps >= 100) return AppColors.neonGreen;
    if (mbps >= 25) return AppColors.neonCyan;
    if (mbps >= 5) return Colors.orange;
    return AppColors.neonRed;
  }

  String _downloadTitle(BuildContext context, double mbps) {
    final l10n = context.l10n;
    final mbpsStr = mbps.toStringAsFixed(1);
    if (mbps >= 100) return l10n.downloadFastTitle(mbpsStr);
    if (mbps >= 25) return l10n.downloadGoodTitle(mbpsStr);
    if (mbps >= 5) return l10n.downloadModerateTitle(mbpsStr);
    return l10n.downloadSlowTitle(mbpsStr);
  }

  String _downloadBody(BuildContext context, double mbps) {
    final l10n = context.l10n;
    final streams = (mbps / 5).floor().clamp(0, 50);
    if (mbps >= 100) return l10n.downloadFastBody(streams);
    if (mbps >= 25) return l10n.downloadGoodBody(streams);
    if (mbps >= 5) return l10n.downloadModerateBody;
    return l10n.downloadSlowBody;
  }

  // ── Upload ──
  Color _uploadColor(double mbps) {
    if (mbps >= 20) return AppColors.neonGreen;
    if (mbps >= 5) return AppColors.neonCyan;
    if (mbps >= 1) return Colors.orange;
    return AppColors.neonRed;
  }

  String _uploadTitle(BuildContext context, double mbps) {
    final l10n = context.l10n;
    final mbpsStr = mbps.toStringAsFixed(1);
    if (mbps >= 20) return l10n.uploadFastTitle(mbpsStr);
    if (mbps >= 5) return l10n.uploadGoodTitle(mbpsStr);
    if (mbps >= 1) return l10n.uploadLimitedTitle(mbpsStr);
    return l10n.uploadSlowTitle(mbpsStr);
  }

  String _uploadBody(BuildContext context, double mbps) {
    final l10n = context.l10n;
    if (mbps >= 20) return l10n.uploadFastBody;
    if (mbps >= 5) return l10n.uploadGoodBody;
    if (mbps >= 1) return l10n.uploadLimitedBody;
    return l10n.uploadSlowBody;
  }

  // ── Packet Loss ──
  Color _packetLossColor(double percent) {
    if (percent == 0) return AppColors.neonGreen;
    if (percent <= 1) return AppColors.neonCyan;
    if (percent <= 2) return Colors.orange;
    return AppColors.neonRed;
  }

  String _packetLossTitle(BuildContext context, double percent) {
    final l10n = context.l10n;
    if (percent == 0) return l10n.packetLossPerfectTitle;
    if (percent <= 1) return l10n.packetLossMinimalTitle(percent.toStringAsFixed(1));
    return l10n.packetLossHighTitle(percent.toStringAsFixed(1));
  }

  String _packetLossBody(BuildContext context, double percent) {
    final l10n = context.l10n;
    if (percent == 0) return l10n.packetLossPerfectBody;
    if (percent <= 1) return l10n.packetLossMinimalBody;
    return l10n.packetLossHighBody;
  }

  // ── Loaded Latency (Bufferbloat) ──
  Color _loadedLatencyColor(double loaded, double idle) {
    final diff = loaded - idle;
    if (diff <= 10) return AppColors.neonGreen;
    if (diff <= 50) return AppColors.neonCyan;
    if (diff <= 150) return Colors.orange;
    return AppColors.neonRed;
  }

  String _loadedLatencyTitle(BuildContext context, double loaded, double idle) {
    final l10n = context.l10n;
    final diff = loaded - idle;
    final msStr = loaded.toStringAsFixed(0);
    if (diff <= 10) return l10n.loadedLatencyExcellentTitle(msStr);
    if (diff <= 50) return l10n.loadedLatencyGoodTitle(msStr);
    if (diff <= 150) return l10n.loadedLatencyFairTitle(msStr);
    return l10n.loadedLatencyPoorTitle(msStr);
  }

  String _loadedLatencyBody(BuildContext context, double loaded, double idle) {
    final l10n = context.l10n;
    final diff = loaded - idle;
    if (diff <= 10) return l10n.loadedLatencyExcellentBody;
    if (diff <= 50) return l10n.loadedLatencyGoodBody;
    if (diff <= 150) return l10n.loadedLatencyFairBody;
    return l10n.loadedLatencyPoorBody;
  }
}

// ── Bufferbloat A-F Grade Card ────────────────────────────────────────────────

/// Displays the Waveform-style A-F bufferbloat grade based on added latency
/// under load (loadedLatencyMs - idleLatencyMs).
class _BufferbloatGradeCard extends StatelessWidget {
  final double loadedLatencyMs;
  final double idleLatencyMs;

  const _BufferbloatGradeCard({
    required this.loadedLatencyMs,
    required this.idleLatencyMs,
  });

  static const _grades = ['A', 'B', 'C', 'D', 'E', 'F'];

  /// Added latency thresholds (ms) for grades A–F (Waveform standard).
  static const _thresholds = [5.0, 30.0, 60.0, 200.0, 400.0];

  String get _grade {
    final added = loadedLatencyMs - idleLatencyMs;
    for (var i = 0; i < _thresholds.length; i++) {
      if (added <= _thresholds[i]) return _grades[i];
    }
    return 'F';
  }

  Color get _color {
    switch (_grade) {
      case 'A':
        return AppColors.neonGreen;
      case 'B':
        return AppColors.neonCyan;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      default:
        return AppColors.neonRed;
    }
  }

  String _description(BuildContext context) {
    final l10n = context.l10n;
    switch (_grade) {
      case 'A':
        return l10n.bufferbloatGradeA;
      case 'B':
        return l10n.bufferbloatGradeB;
      case 'C':
        return l10n.bufferbloatGradeC;
      case 'D':
        return l10n.bufferbloatGradeD;
      case 'E':
        return l10n.bufferbloatGradeE;
      default:
        return l10n.bufferbloatGradeF;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return NeonCard(
      glowColor: color,
      glowIntensity: 0.08,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
            ),
            child: Center(
              child: Text(
                _grade,
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.bufferbloatGradeLabel,
                  style: GoogleFonts.orbitron(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _description(context),
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
// Disclaimer card shown after test completion
// ─────────────────────────────────────────────────────────────────────────────

class _DisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeonCard(
      glowColor: Colors.white24,
      glowIntensity: 0.02,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.speedTestDisclaimer,
              style: GoogleFonts.rajdhani(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 12,
                height: 1.4,
              ),
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
    if (mounted) {
      setState(() {
        _results = results;
        _loading = false;
      });
    }
  }

  Future<void> _deleteOne(int id) async {
    await getIt<SpeedTestHistoryRepository>().deleteById(id);
    _load();
  }

  Future<void> _deleteAll(BuildContext context) async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Theme.of(ctx).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              l10n.clearAllHistoryAction,
              style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              l10n.deleteAllHistoryConfirm,
              style: GoogleFonts.rajdhani(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  l10n.cancel,
                  style: GoogleFonts.orbitron(fontSize: 10),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  l10n.deleteAllAction,
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    color: AppColors.neonRed,
                  ),
                ),
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
                icon: const Icon(
                  Icons.delete_sweep_rounded,
                  size: 18,
                  color: AppColors.neonRed,
                ),
                tooltip: l10n.clearHistoryTooltip,
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
          ..._results.map(
            (r) => _HistoryRow(
              result: r,
              onDelete: r.id != null ? () => _deleteOne(r.id!) : null,
            ),
          ),
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
