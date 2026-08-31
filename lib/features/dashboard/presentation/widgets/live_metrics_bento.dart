import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../core/presentation/widgets/cyber_neomorphic_button.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../security/domain/entities/security_event.dart';
import '../../../wifi_scan/domain/entities/channel_rating.dart';

/// 2x3 bento grid surfacing the most actionable live metrics from across the
/// app: signal waveform, security trend, channel congestion, new devices,
/// threat severity, and last speed test.
class LiveMetricsBento extends StatelessWidget {
  final int? signalQualityPct; // 0..100 nullable
  final List<int> rssiHistory; // recent RSSI dBm samples (oldest -> newest)
  final List<int> scoreHistory;
  final List<ChannelRating> channelRatings;
  final int newDeviceCount;
  final List<SecurityEvent> recentEvents;
  final double? lastDownloadMbps;
  final double? lastUploadMbps;
  final DateTime? lastSpeedTestAt;

  final VoidCallback onTapSignal;
  final VoidCallback onTapScore;
  final VoidCallback onTapChannels;
  final VoidCallback onTapDevices;
  final VoidCallback onTapThreats;
  final VoidCallback onTapSpeed;

  const LiveMetricsBento({
    super.key,
    required this.signalQualityPct,
    required this.rssiHistory,
    required this.scoreHistory,
    required this.channelRatings,
    required this.newDeviceCount,
    required this.recentEvents,
    required this.lastDownloadMbps,
    required this.lastUploadMbps,
    required this.lastSpeedTestAt,
    required this.onTapSignal,
    required this.onTapScore,
    required this.onTapChannels,
    required this.onTapDevices,
    required this.onTapThreats,
    required this.onTapSpeed,
  });

  /// Best channel plus how many were rated — the bars alone convey neither.
  String _channelSummary(BuildContext context) {
    if (channelRatings.isEmpty) return context.l10n.a11yChannelBarsEmpty;
    final best = channelRatings.reduce(
      (a, b) => a.rating >= b.rating ? a : b,
    );
    return context.l10n.a11yChannelBars(
      channelRatings.length,
      best.channel,
      best.rating.toStringAsFixed(1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      _MetricTile(
        delayMs: 0,
        accent: AppColors.neonCyan,
        title: context.l10n.metricSignal,
        onTap: onTapSignal,
        semanticValue:
            signalQualityPct == null || rssiHistory.isEmpty
                ? context.l10n.a11ySignalTrendUnknown
                : context.l10n.a11ySignalTrend(
                  signalQualityPct!,
                  rssiHistory.length,
                  rssiHistory.last,
                ),
        child: _SignalWaveform(
          rssiHistory: rssiHistory,
          qualityPct: signalQualityPct,
        ),
      ),
      _MetricTile(
        delayMs: 80,
        accent: AppColors.neonGreen,
        title: context.l10n.metricScoreTrend,
        onTap: onTapScore,
        semanticValue:
            scoreHistory.isEmpty
                ? context.l10n.a11yScoreTrendEmpty
                : context.l10n.a11yScoreTrend(
                  scoreHistory.last,
                  scoreHistory.length,
                ),
        child: _ScoreSparkline(scores: scoreHistory),
      ),
      _MetricTile(
        delayMs: 160,
        accent: AppColors.neonPurple,
        title: context.l10n.metricChannels,
        onTap: onTapChannels,
        semanticValue: _channelSummary(context),
        child: _ChannelBars(ratings: channelRatings),
      ),
      _MetricTile(
        delayMs: 240,
        accent: AppColors.neonOrange,
        title: context.l10n.metricNewDevices,
        onTap: onTapDevices,
        semanticValue: context.l10n.a11yNewDevices(newDeviceCount),
        child: _NewDeviceCounter(count: newDeviceCount),
      ),
      _MetricTile(
        delayMs: 320,
        accent: AppColors.neonRed,
        title: context.l10n.metricThreats,
        onTap: onTapThreats,
        semanticValue: context.l10n.a11yThreatEvents(recentEvents.length),
        child: _ThreatSeverity(events: recentEvents),
      ),
      _MetricTile(
        delayMs: 400,
        accent: AppColors.neonBlue,
        title: context.l10n.metricSpeed,
        onTap: onTapSpeed,
        semanticValue:
            lastDownloadMbps == null
                ? context.l10n.a11ySpeedSnapshotEmpty
                : context.l10n.a11ySpeedSnapshot(
                  lastDownloadMbps!.toStringAsFixed(1),
                  (lastUploadMbps ?? 0).toStringAsFixed(1),
                ),
        child: _SpeedSnapshot(
          downloadMbps: lastDownloadMbps,
          uploadMbps: lastUploadMbps,
          recordedAt: lastSpeedTestAt,
        ),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: tiles,
    );
  }
}

// ── Tile shell ───────────────────────────────────────────────────────

class _MetricTile extends StatelessWidget {
  final int delayMs;
  final Color accent;
  final String title;
  final VoidCallback onTap;
  final Widget child;

  /// Spoken value for the tile. The visuals are sparklines and bars that a
  /// screen reader cannot interpret, so the number has to be said out loud.
  final String semanticValue;

  const _MetricTile({
    required this.delayMs,
    required this.accent,
    required this.title,
    required this.onTap,
    required this.semanticValue,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title: $semanticValue',
      child: ExcludeSemantics(child: _visual(context)),
    );
  }

  Widget _visual(BuildContext context) {
    return StaggeredEntry(
      delay: Duration(milliseconds: delayMs),
      slideOffset: 16,
      child: CyberNeomorphicButton(
        onPressed: onTap,
        borderRadius: 18,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: ScanlinePainter(
                      color: accent.withValues(alpha: 0.04),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent,
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.6),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          title,
                          style: GoogleFonts.orbitron(
                            color: accent.withValues(alpha: 0.9),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tile contents ────────────────────────────────────────────────────

class _SignalWaveform extends StatelessWidget {
  final List<int> rssiHistory;
  final int? qualityPct;

  const _SignalWaveform({required this.rssiHistory, required this.qualityPct});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pct = qualityPct;

    final spots =
        rssiHistory.isEmpty
            ? <FlSpot>[
              const FlSpot(0, 50),
              const FlSpot(1, 55),
              const FlSpot(2, 52),
              const FlSpot(3, 58),
            ]
            : rssiHistory.asMap().entries.map((e) {
              // Map RSSI dBm (-100..-30) to 0..100 percentage
              final rssi = e.value.toDouble();
              final mapped = ((rssi + 100) / 70 * 100).clamp(0.0, 100.0);
              return FlSpot(e.key.toDouble(), mapped);
            }).toList();

    final color =
        (pct ?? 60) >= 60
            ? AppColors.neonCyan
            : (pct ?? 0) >= 40
            ? const Color(0xFFFFB300)
            : AppColors.neonRed;

    return Stack(
      children: [
        Positioned.fill(
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: false),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.4,
                  color: color,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.25),
                        color.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            pct != null ? '$pct%' : '—',
            style: GoogleFonts.orbitron(
              color: scheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreSparkline extends StatelessWidget {
  final List<int> scores;
  const _ScoreSparkline({required this.scores});

  Color _colorFor(int s) {
    if (s >= 85) return AppColors.neonGreen;
    if (s >= 60) return const Color(0xFFFFB300);
    return AppColors.neonRed;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (scores.length < 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              scores.isEmpty ? '—' : '${scores.last}%',
              style: GoogleFonts.orbitron(
                color: scheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              context.l10n.waitingForHistory,
              style: GoogleFonts.rajdhani(
                color: scheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }
    final color = _colorFor(scores.last);
    final spots =
        scores
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
            .toList();
    final delta = scores.last - scores.first;
    return Stack(
      children: [
        Positioned.fill(
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: false),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: color,
                  dotData: FlDotData(
                    getDotPainter:
                        (s, _, __, i) => FlDotCirclePainter(
                          radius: i == spots.length - 1 ? 3 : 0,
                          color: color,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${scores.last}%',
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  delta >= 0 ? '+$delta' : '$delta',
                  style: GoogleFonts.rajdhani(
                    color: delta >= 0 ? AppColors.neonGreen : AppColors.neonRed,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChannelBars extends StatelessWidget {
  final List<ChannelRating> ratings;
  const _ChannelBars({required this.ratings});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (ratings.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noScanData,
          style: GoogleFonts.rajdhani(
            color: scheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      );
    }
    // Pick top 6 channels by network count to show congestion.
    final sorted = [...ratings]
      ..sort((a, b) => b.networkCount.compareTo(a.networkCount));
    final top = sorted.take(6).toList();
    final maxCount = top
        .map((r) => r.networkCount)
        .fold<int>(0, math.max)
        .clamp(1, 999);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final r in top) ...[
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: r.networkCount / maxCount),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) {
                    final color =
                        r.rating >= 7
                            ? AppColors.neonGreen
                            : r.rating >= 4
                            ? AppColors.neonPurple
                            : AppColors.neonRed;
                    final h = constraints.maxHeight * 0.7 * v;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color.withValues(alpha: 0.3), color],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${r.channel}',
                          style: GoogleFonts.orbitron(
                            color: scheme.onSurfaceVariant,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 3),
            ],
          ],
        );
      },
    );
  }
}

class _NewDeviceCounter extends StatelessWidget {
  final int count;
  const _NewDeviceCounter({required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: count.toDouble()),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) {
              return NeonText(
                '${v.round()}',
                style: GoogleFonts.orbitron(
                  color: AppColors.neonOrange,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
                glowColor: AppColors.neonOrange,
                glowRadius: count > 0 ? 8 : 0,
              );
            },
          ),
          const SizedBox(height: 2),
          Text(
            count == 0
                ? context.l10n.noChangeLabel
                : context.l10n.sinceLastScanLabel,
            style: GoogleFonts.rajdhani(
              color: scheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreatSeverity extends StatelessWidget {
  final List<SecurityEvent> events;
  const _ThreatSeverity({required this.events});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final critical =
        events
            .where((e) => e.severity == SecurityEventSeverity.critical)
            .length;
    final high =
        events.where((e) => e.severity == SecurityEventSeverity.high).length;
    final medium =
        events.where((e) => e.severity == SecurityEventSeverity.medium).length;
    final other = events.length - critical - high - medium;

    final entries = [
      (
        label: context.l10n.severityCrit,
        count: critical,
        color: AppColors.neonRed,
      ),
      (
        label: context.l10n.severityHighShort,
        count: high,
        color: AppColors.neonOrange,
      ),
      (
        label: context.l10n.severityMedShort,
        count: medium,
        color: const Color(0xFFFFB300),
      ),
      (
        label: context.l10n.severityInfoShort,
        count: other,
        color: AppColors.neonCyan,
      ),
    ];

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_rounded,
              color: AppColors.neonGreen.withValues(alpha: 0.8),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.allClearLabel,
              style: GoogleFonts.rajdhani(
                color: scheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final e in entries)
          if (e.count > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: e.color,
                      boxShadow: [
                        BoxShadow(
                          color: e.color.withValues(alpha: 0.7),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    e.label,
                    style: GoogleFonts.orbitron(
                      color: e.color,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${e.count}',
                    style: GoogleFonts.orbitron(
                      color: scheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

class _SpeedSnapshot extends StatelessWidget {
  final double? downloadMbps;
  final double? uploadMbps;
  final DateTime? recordedAt;

  const _SpeedSnapshot({
    required this.downloadMbps,
    required this.uploadMbps,
    required this.recordedAt,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (downloadMbps == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.speed_rounded,
              color: AppColors.neonBlue.withValues(alpha: 0.5),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.tapToTestLabel,
              style: GoogleFonts.rajdhani(
                color: scheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Icon(
              Icons.arrow_downward_rounded,
              size: 12,
              color: AppColors.neonCyan,
            ),
            const SizedBox(width: 2),
            Text(
              downloadMbps!.toStringAsFixed(1),
              style: GoogleFonts.orbitron(
                color: AppColors.neonCyan,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                context.l10n.mbps,
                style: GoogleFonts.rajdhani(
                  color: scheme.onSurfaceVariant,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Icon(
              Icons.arrow_upward_rounded,
              size: 12,
              color: AppColors.neonPurple,
            ),
            const SizedBox(width: 2),
            Text(
              (uploadMbps ?? 0).toStringAsFixed(1),
              style: GoogleFonts.orbitron(
                color: AppColors.neonPurple,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                context.l10n.mbps,
                style: GoogleFonts.rajdhani(
                  color: scheme.onSurfaceVariant,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
        if (recordedAt != null) ...[
          const SizedBox(height: 4),
          Text(
            _formatRelative(recordedAt!, context),
            style: GoogleFonts.rajdhani(
              color: scheme.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
        ],
      ],
    );
  }

  String _formatRelative(DateTime t, BuildContext context) {
    final diff = DateTime.now().difference(t);
    final l10n = context.l10n;
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
    return l10n.daysAgo(diff.inDays);
  }
}
