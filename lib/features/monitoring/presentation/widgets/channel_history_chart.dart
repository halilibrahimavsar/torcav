import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../features/wifi_scan/domain/entities/channel_rating_sample.dart';

/// Displays a time-series line chart of channel ratings from historical data.
/// Each line represents one Wi-Fi channel; the Y-axis is the rating (0–100).
class ChannelHistoryChart extends StatelessWidget {
  final List<ChannelRatingSample> samples;

  const ChannelHistoryChart({super.key, required this.samples});

  @override
  Widget build(BuildContext context) {
    if (samples.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No history yet. Channel ratings are recorded each time you '
            'open the Channel Rating screen.',
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

    // Group samples by channel.
    final byChannel = <int, List<ChannelRatingSample>>{};
    for (final s in samples) {
      byChannel.putIfAbsent(s.channel, () => []).add(s);
    }

    // Sort each channel's samples by time.
    for (final list in byChannel.values) {
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }

    // Normalise timestamps to a 0-based X axis (hours ago from earliest sample).
    final earliest = samples.map((s) => s.timestamp).reduce(
          (a, b) => a.isBefore(b) ? a : b,
        );

    final colorPalette = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      const Color(0xFFFF6D00),
      const Color(0xFF00BFA5),
      const Color(0xFFAA00FF),
    ];

    final channels = byChannel.keys.toList()..sort();

    final lines = channels.asMap().entries.map((entry) {
      final channel = entry.value;
      final color = colorPalette[entry.key % colorPalette.length];
      final spots = byChannel[channel]!.map((s) {
        final hours = s.timestamp.difference(earliest).inMinutes / 60.0;
        return FlSpot(hours, s.rating.clamp(0.0, 100.0));
      }).toList();

      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 2,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: color.withValues(alpha: 0.06),
        ),
      );
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: channels.asMap().entries.map((entry) {
            final color = colorPalette[entry.key % colorPalette.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 3,
                  color: color,
                ),
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
        ),
        const SizedBox(height: 16),
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
                  axisNameWidget: Text(
                    'Hours ago',
                    style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      color: onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) =>
                      Theme.of(context).colorScheme.surfaceContainerHigh,
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      final ch = channels[lines.indexOf(
                        lines.firstWhere((l) => l.spots.contains(FlSpot(spot.x, spot.y))),
                      )];
                      return LineTooltipItem(
                        'CH $ch: ${spot.y.toStringAsFixed(0)}',
                        GoogleFonts.rajdhani(
                          color: spot.bar.color ?? Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Higher rating = less congested channel. '
          'Based on ${samples.length} recorded samples.',
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
