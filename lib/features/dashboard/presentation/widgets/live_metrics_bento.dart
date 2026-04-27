import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../core/presentation/widgets/cyber_neomorphic_button.dart';
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

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      _MetricTile(
        delayMs: 0,
        accent: AppColors.neonCyan,
        title: 'SIGNAL',
        onTap: onTapSignal,
        child: _SignalWaveform(
          rssiHistory: rssiHistory,
          qualityPct: signalQualityPct,
        ),
      ),
      _MetricTile(
        delayMs: 80,
        accent: AppColors.neonGreen,
        title: 'SCORE TREND',
        onTap: onTapScore,
        child: _ScoreSparkline(scores: scoreHistory),
      ),
      _MetricTile(
        delayMs: 160,
        accent: AppColors.neonPurple,
        title: 'CHANNELS',
        onTap: onTapChannels,
        child: _ChannelBars(ratings: channelRatings),
      ),
      _MetricTile(
        delayMs: 240,
        accent: AppColors.neonOrange,
        title: 'NEW DEVICES',
        onTap: onTapDevices,
        child: _NewDeviceCounter(count: newDeviceCount),
      ),
      _MetricTile(
        delayMs: 320,
        accent: AppColors.neonRed,
        title: 'THREATS',
        onTap: onTapThreats,
        child: _ThreatSeverity(events: recentEvents),
      ),
      _MetricTile(
        delayMs: 400,
        accent: AppColors.neonBlue,
        title: 'SPEED',
        onTap: onTapSpeed,
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

  const _MetricTile({
    required this.delayMs,
    required this.accent,
    required this.title,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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

    final spots = rssiHistory.isEmpty
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

    final color = (pct ?? 60) >= 60
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
                  barWidth: 2,
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
              'Waiting for history',
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
    final spots = scores
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
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (s, _, __, i) => FlDotCirclePainter(
                      radius: i == spots.length - 1 ? 3 : 0,
                      color: color,
                      strokeWidth: 0,
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
          'No scan data',
          style: GoogleFonts.rajdhani(
            color: scheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      );
    }
    // Pick top 6 channels by network count to show congestion.
    final sorted = [...ratings]..sort(
        (a, b) => b.networkCount.compareTo(a.networkCount),
      );
    final top = sorted.take(6).toList();
    final maxCount =
        top.map((r) => r.networkCount).fold<int>(0, math.max).clamp(1, 999);

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
                    final color = r.rating >= 7
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
                              colors: [
                                color.withValues(alpha: 0.3),
                                color,
                              ],
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
            count == 0 ? 'no change' : 'since last scan',
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
    final critical = events
        .where((e) => e.severity == SecurityEventSeverity.critical)
        .length;
    final high =
        events.where((e) => e.severity == SecurityEventSeverity.high).length;
    final medium =
        events.where((e) => e.severity == SecurityEventSeverity.medium).length;
    final other = events.length - critical - high - medium;

    final entries = [
      (label: 'CRIT', count: critical, color: AppColors.neonRed),
      (label: 'HIGH', count: high, color: AppColors.neonOrange),
      (label: 'MED', count: medium, color: const Color(0xFFFFB300)),
      (label: 'INFO', count: other, color: AppColors.neonCyan),
    ];

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_rounded,
                color: AppColors.neonGreen.withValues(alpha: 0.8), size: 24),
            const SizedBox(height: 4),
            Text(
              'all clear',
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
            Icon(Icons.speed_rounded,
                color: AppColors.neonBlue.withValues(alpha: 0.5), size: 22),
            const SizedBox(height: 4),
            Text(
              'tap to test',
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
            Icon(Icons.arrow_downward_rounded,
                size: 12, color: AppColors.neonCyan),
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
                'Mbps',
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
            Icon(Icons.arrow_upward_rounded,
                size: 12, color: AppColors.neonPurple),
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
                'Mbps',
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
            _formatRelative(recordedAt!),
            style: GoogleFonts.rajdhani(
              color: scheme.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
        ],
      ],
    );
  }

  String _formatRelative(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
