import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../features/wifi_scan/domain/entities/channel_rating.dart';

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

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      decoration: BoxDecoration(
        color:
            isDark
                ? const Color(0xFF0F172A)
                : Theme.of(context).colorScheme.surface,
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
              getTooltipColor: (_) => const Color(0xFF1E293B),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final rating = ratings[groupIndex];
                return BarTooltipItem(
                  'CH ${rating.channel}\n',
                  const TextStyle(
                    color: Colors.white,
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
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= ratings.length) {
                    return const SizedBox();
                  }
                  // Show every 2nd or 3rd label to avoid crowding
                  if (ratings.length > 10 && index % 2 != 0) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${ratings[index].channel}',
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
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
                      color: _getColorForRating(rating.rating, accentColor),
                      width: 8,
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

  Color _getColorForRating(double r, Color defaultColor) {
    if (r >= 8) return defaultColor;
    if (r >= 5) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}
