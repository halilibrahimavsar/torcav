import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/wifi_scan/domain/entities/wifi_network.dart';
import '../bloc/monitoring_bloc.dart';

class SignalGraphPage extends StatelessWidget {
  final WifiNetwork network;

  const SignalGraphPage({super.key, required this.network});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => GetIt.I<MonitoringBloc>()..add(StartMonitoring(network.bssid)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('SIGNAL MONITORING: ${network.ssid}'),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(child: _SignalChart()),
              const SizedBox(height: 20),
              _buildStats(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return BlocBuilder<MonitoringBloc, MonitoringState>(
      builder: (context, state) {
        if (state is MonitoringActive) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'SIGNAL',
                  '${state.currentData.signalStrength} dBm',
                ),
                _buildStatItem('CHANNEL', '${state.currentData.channel}'),
                _buildStatItem('FREQ', '${state.currentData.frequency} MHz'),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.rajdhani(color: Colors.grey, fontSize: 14),
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}

class _SignalChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonitoringBloc, MonitoringState>(
      builder: (context, state) {
        if (state is MonitoringLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MonitoringActive) {
          return LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine:
                    (value) => FlLine(color: Colors.white10, strokeWidth: 1),
                getDrawingVerticalLine:
                    (value) => FlLine(color: Colors.white10, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d)),
              ),
              minX: 0,
              maxX: 20, // Display last 20 points
              minY: -100,
              maxY: -30,
              lineBarsData: [
                LineChartBarData(
                  spots:
                      state.signalHistory.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.toDouble());
                      }).toList(),
                  isCurved: true,
                  color: AppTheme.primaryColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          );
        } else if (state is MonitoringFailure) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const Center(child: Text('Waiting for data...'));
      },
    );
  }
}
