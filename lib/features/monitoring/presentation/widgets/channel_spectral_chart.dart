import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../features/wifi_scan/domain/entities/channel_rating.dart';
import 'spectrum_colors.dart';

class ChannelSpectralChart extends StatelessWidget {
  final List<ChannelRating> ratings;
  final Color accentColor;

  const ChannelSpectralChart({
    super.key,
    required this.ratings,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (ratings.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final screenH = MediaQuery.of(context).size.height;

    // Responsive height: tall enough for bars + rotated labels.
    final chartHeight = math.min(360.0, math.max(220.0, screenH * 0.32));
    final manyChannels = ratings.length > 10;
    final barWidth = manyChannels ? 12.0 : 18.0;

    return Container(
      height: chartHeight,
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
      decoration: BoxDecoration(
        color:
            isDark
                ? const Color(0xFF0F172A)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: onSurface.withValues(alpha: 0.12)),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10,
          minY: 0,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipColor:
                  (_) =>
                      isDark
                          ? const Color(0xFF1E293B)
                          : Theme.of(context).colorScheme.surface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final rating = ratings[groupIndex];
                return BarTooltipItem(
                  'CH ${rating.channel}\n',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '${rating.rating.toStringAsFixed(1)}/10',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: manyChannels ? 36 : 22,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= ratings.length) {
                    return const SizedBox.shrink();
                  }
                  final label = '${ratings[index].channel}';
                  final color = onSurface.withValues(alpha: 0.62);
                  if (manyChannels) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Transform.rotate(
                        angle: -0.65, // ~ -37°
                        alignment: Alignment.topCenter,
                        child: Text(
                          label,
                          style: GoogleFonts.rajdhani(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      label,
                      style: GoogleFonts.rajdhani(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: 2,
                getTitlesWidget:
                    (value, _) => Text(
                      value.toInt().toString(),
                      style: GoogleFonts.rajdhani(
                        color: onSurface.withValues(alpha: 0.45),
                        fontSize: 10,
                      ),
                    ),
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine:
                (_) => FlLine(
                  color: onSurface.withValues(alpha: 0.06),
                  strokeWidth: 1,
                ),
          ),
          borderData: FlBorderData(show: false),
          barGroups:
              ratings.asMap().entries.map((entry) {
                final index = entry.key;
                final rating = entry.value;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: rating.rating,
                      color: ratingScoreColor(rating.rating, accentColor),
                      width: barWidth,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 10,
                        color: onSurface.withValues(alpha: 0.05),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

}
