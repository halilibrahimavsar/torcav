import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../features/wifi_scan/domain/entities/wifi_network.dart';
import 'package:torcav/features/heatmap/presentation/pages/heatmap_page.dart';
import '../bloc/monitoring_bloc.dart';

class SignalGraphPage extends StatefulWidget {
  final WifiNetwork network;

  const SignalGraphPage({super.key, required this.network});

  @override
  State<SignalGraphPage> createState() => _SignalGraphPageState();
}

class _SignalGraphPageState extends State<SignalGraphPage>
    with WidgetsBindingObserver {
  bool _wasMonitoring = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _wasMonitoring = true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final bloc = context.read<MonitoringBloc>();
    if (state == AppLifecycleState.paused && _wasMonitoring) {
      bloc.add(StopMonitoring());
    } else if (state == AppLifecycleState.resumed && _wasMonitoring) {
      bloc.add(StartMonitoring(widget.network.bssid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              GetIt.I<MonitoringBloc>()
                ..add(StartMonitoring(widget.network.bssid)),
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(
                context.l10n.signalMonitoringTitle(widget.network.ssid),
              ),
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.map_outlined),
                  tooltip: context.l10n.heatmapTooltip,
                  onPressed: () {
                    Navigator.of(innerContext).push(
                      MaterialPageRoute(builder: (_) => const HeatmapPage()),
                    );
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(child: _SignalChart()),
                  const SizedBox(height: 20),
                  _buildStats(innerContext),
                ],
              ),
            ),
          );
        },
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
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  context.l10n.signalCaps,
                  '${state.currentData.signalStrength} dBm',
                ),
                _buildStatItem(
                  context,
                  context.l10n.channelCaps,
                  '${state.currentData.channel}',
                ),
                _buildStatItem(
                  context,
                  context.l10n.frequencyCaps,
                  '${state.currentData.frequency} MHz',
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.rajdhani(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: Theme.of(context).colorScheme.primary,
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
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
                    (value) => FlLine(
                      color: onSurface.withValues(alpha: 0.12),
                      strokeWidth: 1,
                    ),
                getDrawingVerticalLine:
                    (value) => FlLine(
                      color: onSurface.withValues(alpha: 0.12),
                      strokeWidth: 1,
                    ),
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
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.72),
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
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.12),
                ),
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
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          );
        } else if (state is MonitoringFailure) {
          return Center(child: Text(context.l10n.errorPrefix(state.message)));
        }
        return Center(child: Text(context.l10n.waitingForData));
      },
    );
  }
}
