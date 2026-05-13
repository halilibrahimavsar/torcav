import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../domain/entities/live_stats.dart';

class LiveJitterChart extends StatelessWidget {
  final LiveStats stats;

  const LiveJitterChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final samples = stats.samples;
    if (samples.isEmpty) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text('—', style: TextStyle(color: scheme.onSurfaceVariant)),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < samples.length; i++) {
      spots.add(FlSpot(i.toDouble(), samples[i].latencyMs));
    }
    final maxY =
        samples.map((s) => s.latencyMs).reduce((a, b) => a > b ? a : b) * 1.2;

    return SizedBox(
      height: 140,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY < 50 ? 50 : maxY,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: scheme.primary,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: scheme.primary.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
