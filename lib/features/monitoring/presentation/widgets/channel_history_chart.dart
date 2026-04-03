import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../features/wifi_scan/domain/entities/channel_rating_sample.dart';

/// Displays channel rating history.
///
/// * Single session  → bar chart (ratings per channel, most useful at-a-glance)
/// * Multiple sessions → line chart (time series per channel)
class ChannelHistoryChart extends StatelessWidget {
  final List<ChannelRatingSample> samples;

  const ChannelHistoryChart({super.key, required this.samples});

  // ── Palette ────────────────────────────────────────────────────────
  static const _palette = [
    Color(0xFF00E5FF),
    Color(0xFF76FF03),
    Color(0xFFEEFF41),
    Color(0xFFFF6D00),
    Color(0xFF00BFA5),
    Color(0xFFAA00FF),
    Color(0xFFFF4081),
    Color(0xFF40C4FF),
  ];

  // ── Session grouping ───────────────────────────────────────────────
  /// Collapses timestamps that are within [windowSec] of the previous one
  /// into the same session bucket.
  List<DateTime> _buildSessions(List<ChannelRatingSample> all,
      {int windowSec = 10}) {
    final sorted = all.map((s) => s.timestamp).toSet().toList()
      ..sort((a, b) => a.compareTo(b));
    final sessions = <DateTime>[];
    for (final ts in sorted) {
      if (sessions.isEmpty ||
          ts.difference(sessions.last).inSeconds.abs() > windowSec) {
        sessions.add(ts);
      }
    }
    return sessions;
  }

  @override
  Widget build(BuildContext context) {
    if (samples.isEmpty) return _empty(context);

    // Group by channel, sort by time
    final byChannel = <int, List<ChannelRatingSample>>{};
    for (final s in samples) {
      byChannel.putIfAbsent(s.channel, () => []).add(s);
    }
    for (final list in byChannel.values) {
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
    final channels = byChannel.keys.toList()..sort();
    final sessions = _buildSessions(samples);

    if (sessions.length <= 1) {
      // Only one point in time → bar chart
      return _BarView(
        channels: channels,
        byChannel: byChannel,
        palette: _palette,
      );
    }

    // Multiple sessions → line chart
    return _LineView(
      channels: channels,
      byChannel: byChannel,
      sessions: sessions,
      palette: _palette,
      totalSamples: samples.length,
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          context.l10n.noHistoryPlaceholder,
          textAlign: TextAlign.center,
          style: GoogleFonts.rajdhani(
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

// ── Bar chart (single session) ─────────────────────────────────────

class _BarView extends StatelessWidget {
  final List<int> channels;
  final Map<int, List<ChannelRatingSample>> byChannel;
  final List<Color> palette;

  const _BarView({
    required this.channels,
    required this.byChannel,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final groups = channels.asMap().entries.map((entry) {
      final i = entry.key;
      final ch = entry.value;
      final rating = byChannel[ch]!.last.rating.clamp(0.0, 100.0);
      final color = palette[i % palette.length];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: rating,
            color: color,
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: color.withValues(alpha: 0.07),
            ),
          ),
        ],
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Legend(channels: channels, palette: palette),
        const SizedBox(height: 12),
        Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F172A)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: onSurface.withValues(alpha: 0.12)),
          ),
          child: BarChart(
            BarChartData(
              barGroups: groups,
              maxY: 100,
              gridData: FlGridData(
                drawHorizontalLine: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: onSurface.withValues(alpha: 0.08),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= channels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'CH${channels[idx]}',
                          style: GoogleFonts.rajdhani(
                            fontSize: 10,
                            color: palette[idx % palette.length],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 25,
                    getTitlesWidget: (v, _) => Text(
                      v.toInt().toString(),
                      style: GoogleFonts.rajdhani(
                        fontSize: 10,
                        color: onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) =>
                      Theme.of(context).colorScheme.surfaceContainerHigh,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final ch = channels[group.x];
                    return BarTooltipItem(
                      'CH $ch\n${rod.toY.toStringAsFixed(0)}',
                      GoogleFonts.rajdhani(
                        color: palette[groupIndex % palette.length],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.currentSessionInfo,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

// ── Line chart (multi-session) ─────────────────────────────────────

class _LineView extends StatelessWidget {
  final List<int> channels;
  final Map<int, List<ChannelRatingSample>> byChannel;
  final List<DateTime> sessions;
  final List<Color> palette;
  final int totalSamples;

  const _LineView({
    required this.channels,
    required this.byChannel,
    required this.sessions,
    required this.palette,
    required this.totalSamples,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // Build one line per channel. X = session index, Y = rating.
    final lines = channels.asMap().entries.map((entry) {
      final i = entry.key;
      final ch = entry.value;
      final color = palette[i % palette.length];
      final chSamples = byChannel[ch]!;

      final spots = <FlSpot>[];
      for (var si = 0; si < sessions.length; si++) {
        final sessionTs = sessions[si];
        // Find sample closest to this session timestamp (within 30 s)
        ChannelRatingSample? best;
        int bestDiff = 999999;
        for (final s in chSamples) {
          final diff = s.timestamp.difference(sessionTs).inSeconds.abs();
          if (diff < bestDiff) {
            bestDiff = diff;
            best = s;
          }
        }
        if (best != null && bestDiff <= 30) {
          spots.add(FlSpot(si.toDouble(), best.rating.clamp(0.0, 100.0)));
        }
      }

      return LineChartBarData(
        spots: spots,
        isCurved: spots.length > 2,
        color: color,
        barWidth: 2,
        dotData: FlDotData(show: spots.length <= 5),
        belowBarData: BarAreaData(
          show: true,
          color: color.withValues(alpha: 0.06),
        ),
      );
    }).toList();

    // X-axis labels: time of session
    String sessionLabel(int idx) {
      if (idx < 0 || idx >= sessions.length) return '';
      final ts = sessions[idx];
      return '${ts.hour.toString().padLeft(2, '0')}:'
          '${ts.minute.toString().padLeft(2, '0')}';
    }

    // Show at most ~5 x labels to avoid crowding
    final labelStep =
        (sessions.length / 5).ceil().clamp(1, sessions.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Legend(channels: channels, palette: palette),
        const SizedBox(height: 12),
        Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F172A)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: onSurface.withValues(alpha: 0.12)),
          ),
          child: LineChart(
            LineChartData(
              lineBarsData: lines,
              minY: 0,
              maxY: 100,
              minX: 0,
              maxX: (sessions.length - 1).toDouble(),
              gridData: FlGridData(
                drawHorizontalLine: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: onSurface.withValues(alpha: 0.08),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 25,
                    getTitlesWidget: (v, _) => Text(
                      v.toInt().toString(),
                      style: GoogleFonts.rajdhani(
                        fontSize: 10,
                        color: onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: labelStep.toDouble(),
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx % labelStep != 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          sessionLabel(idx),
                          style: GoogleFonts.rajdhani(
                            fontSize: 9,
                            color: onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) =>
                      Theme.of(context).colorScheme.surfaceContainerHigh,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      // spot.barIndex is the line index → maps directly to channel
                      final ch = channels[spot.barIndex];
                      final time = sessionLabel(spot.x.toInt());
                      return LineTooltipItem(
                        'CH $ch: ${spot.y.toStringAsFixed(0)}'
                        '${time.isNotEmpty ? '\n$time' : ''}',
                        GoogleFonts.rajdhani(
                          color: spot.bar.color ?? Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.historySummaryInfo(sessions.length, totalSamples),
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

// ── Shared legend ──────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  final List<int> channels;
  final List<Color> palette;

  const _Legend({required this.channels, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: channels.asMap().entries.map((entry) {
        final color = palette[entry.key % palette.length];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 3, color: color),
            const SizedBox(width: 4),
            Text(
              'CH ${entry.value}',
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
