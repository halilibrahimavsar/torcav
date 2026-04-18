import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../features/wifi_scan/domain/entities/wifi_network.dart';
import '../bloc/heatmap_bloc.dart';
import '../bloc/monitoring_bloc.dart';
import 'temporal_heatmap_page.dart';

class SignalGraphPage extends StatelessWidget {
  final WifiNetwork network;

  const SignalGraphPage({super.key, required this.network});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) =>
                  GetIt.I<MonitoringBloc>()
                    ..add(StartMonitoring(network.bssid)),
        ),
        BlocProvider(create: (_) => GetIt.I<HeatmapBloc>()),
      ],
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(context.l10n.signalMonitoringTitle(network.ssid)),
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.map_outlined),
                  tooltip: context.l10n.heatmapTooltip,
                  onPressed: () {
                    Navigator.of(innerContext).push(
                      MaterialPageRoute(
                        builder:
                            (_) => TemporalHeatmapPage(bssid: network.bssid),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add_location_alt_outlined),
                  tooltip: context.l10n.tagCurrentPointTooltip,
                  onPressed: () => _addHeatmapPoint(innerContext),
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

  Future<void> _addHeatmapPoint(BuildContext context) async {
    final zone = await showDialog<String>(
      context: context,
      builder: (context) => const _ZoneInputDialog(),
    );

    if (!context.mounted || zone == null || zone.isEmpty) return;

    final state = context.read<MonitoringBloc>().state;
    if (state is! MonitoringActive) return;

    context.read<HeatmapBloc>().add(
      LogHeatmapPoint(
        bssid: network.bssid,
        zoneTag: zone,
        signalDbm: state.currentData.signalStrength,
      ),
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.heatmapPointAdded(zone))),
    );
  }
}

class _ZoneInputDialog extends StatefulWidget {
  const _ZoneInputDialog();

  @override
  State<_ZoneInputDialog> createState() => _ZoneInputDialogState();
}

class _ZoneInputDialogState extends State<_ZoneInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.addZonePoint),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: context.l10n.zoneTagLabel),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isNotEmpty) {
              Navigator.of(context).pop(text);
            }
          },
          child: Text(context.l10n.save),
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
