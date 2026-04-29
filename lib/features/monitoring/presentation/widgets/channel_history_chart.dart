import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../features/wifi_scan/domain/entities/channel_rating_sample.dart';
import '../../../../features/wifi_scan/domain/entities/wifi_band.dart';

// ── Duration options for time-range filter ────────────────────────────
const _timeRanges = <Duration>[
  Duration(hours: 1),
  Duration(hours: 6),
  Duration(hours: 24),
  Duration(days: 7),
];
const _timeRangeLabels = ['1H', '6H', '24H', '7D'];

/// A channel is considered unstable when its rating fluctuates by more than
/// this many points across the visible sessions.
const double _unstableThreshold = 1.5;

/// Displays channel rating history with filtering, stats, and multiple
/// chart modes (bar / line / heatmap).
class ChannelHistoryChart extends StatefulWidget {
  final List<ChannelRatingSample> samples;

  const ChannelHistoryChart({super.key, required this.samples});

  @override
  State<ChannelHistoryChart> createState() => _ChannelHistoryChartState();
}

class _ChannelHistoryChartState extends State<ChannelHistoryChart> {
  WifiBand? _selectedBand; // null = all bands
  int _timeRangeIdx = 3; // default 7D
  Set<int> _highlightedChannels = {};
  bool _heatmapMode = false;

  // ── Filtering ───────────────────────────────────────────────────────

  List<ChannelRatingSample> get _filtered {
    final cutoff = DateTime.now().subtract(_timeRanges[_timeRangeIdx]);
    return widget.samples.where((s) {
      if (s.timestamp.isBefore(cutoff)) return false;
      if (_selectedBand != null &&
          bandFromChannel(s.channel) != _selectedBand) {
        return false;
      }
      return true;
    }).toList();
  }

  // ── Session grouping ────────────────────────────────────────────────

  List<DateTime> _buildSessions(
    List<ChannelRatingSample> all, {
    int windowSec = 10,
  }) {
    final sorted =
        all.map((s) => s.timestamp).toSet().toList()
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

  Map<int, List<ChannelRatingSample>> _groupByChannel(
    List<ChannelRatingSample> data,
  ) {
    final map = <int, List<ChannelRatingSample>>{};
    for (final s in data) {
      map.putIfAbsent(s.channel, () => []).add(s);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
    return map;
  }

  /// Channels whose rating spread (max-min) across sessions exceeds the
  /// unstable threshold. Useful to flag channels that swing wildly.
  Set<int> _unstableChannels(Map<int, List<ChannelRatingSample>> byChannel) {
    final result = <int>{};
    for (final entry in byChannel.entries) {
      if (entry.value.length < 3) continue;
      double minR = double.infinity;
      double maxR = -double.infinity;
      for (final s in entry.value) {
        if (s.rating < minR) minR = s.rating;
        if (s.rating > maxR) maxR = s.rating;
      }
      if (maxR - minR > _unstableThreshold) result.add(entry.key);
    }
    return result;
  }

  // ── Color generation ────────────────────────────────────────────────

  static Color _colorForIndex(int i, int total) {
    if (total <= _kFixedPalette.length) return _kFixedPalette[i];
    final hue = (i * 360.0 / total) % 360;
    return HSLColor.fromAHSL(1.0, hue, 0.85, 0.6).toColor();
  }

  static const _kFixedPalette = [
    Color(0xFF00E5FF),
    Color(0xFF76FF03),
    Color(0xFFEEFF41),
    Color(0xFFFF6D00),
    Color(0xFF00BFA5),
    Color(0xFFAA00FF),
    Color(0xFFFF4081),
    Color(0xFF40C4FF),
  ];

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.samples.isEmpty) return _empty(context);

    final filtered = _filtered;
    if (filtered.isEmpty) return _emptyFilter(context);

    final byChannel = _groupByChannel(filtered);
    final channels = byChannel.keys.toList()..sort();
    final sessions = _buildSessions(filtered);
    final unstable = _unstableChannels(byChannel);

    // Stats
    final bestEntry = _bestChannel(byChannel);
    final avgRating =
        filtered.map((s) => s.rating).reduce((a, b) => a + b) / filtered.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ControlBar(
          selectedBand: _selectedBand,
          onBandChanged:
              (b) => setState(() {
                _selectedBand = b;
                _highlightedChannels = {};
              }),
          timeRangeIdx: _timeRangeIdx,
          onTimeRangeChanged:
              (i) => setState(() {
                _timeRangeIdx = i;
                _highlightedChannels = {};
              }),
          showModeToggle: sessions.length > 1,
          heatmapMode: _heatmapMode,
          onModeToggled: () => setState(() => _heatmapMode = !_heatmapMode),
        ),
        const SizedBox(height: 12),
        _SummaryStatsRow(
          bestChannel: bestEntry?.key,
          bestRating: bestEntry?.value,
          avgRating: avgRating,
          sessionCount: sessions.length,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: NeonSectionHeader(
                label: context.l10n.historyChannelRatings,
                icon: Icons.bar_chart_rounded,
              ),
            ),
            if (_heatmapMode && sessions.length > 1)
              InfoIconButton(
                title: context.l10n.historyHeatmapInfoTitle,
                body: context.l10n.historyHeatmapInfoBody,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildChart(
            context,
            channels: channels,
            byChannel: byChannel,
            sessions: sessions,
          ),
        ),
        const SizedBox(height: 8),
        _InteractiveLegend(
          channels: channels,
          colorForIndex: _colorForIndex,
          highlighted: _highlightedChannels,
          unstable: unstable,
          onToggle: _toggleChannel,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.historySummaryInfo(sessions.length, filtered.length),
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(
    BuildContext context, {
    required List<int> channels,
    required Map<int, List<ChannelRatingSample>> byChannel,
    required List<DateTime> sessions,
  }) {
    if (sessions.length <= 1) {
      return _BarView(
        key: const ValueKey('bar'),
        channels: channels,
        byChannel: byChannel,
        colorForIndex: _colorForIndex,
        highlighted: _highlightedChannels,
      );
    }
    if (_heatmapMode) {
      return _HeatmapView(
        key: const ValueKey('heatmap'),
        channels: channels,
        byChannel: byChannel,
        sessions: sessions,
        highlighted: _highlightedChannels,
      );
    }
    return _LineView(
      key: const ValueKey('line'),
      channels: channels,
      byChannel: byChannel,
      sessions: sessions,
      colorForIndex: _colorForIndex,
      totalSamples: _filtered.length,
      highlighted: _highlightedChannels,
    );
  }

  MapEntry<int, double>? _bestChannel(
    Map<int, List<ChannelRatingSample>> byChannel,
  ) {
    if (byChannel.isEmpty) return null;
    MapEntry<int, double>? best;
    for (final e in byChannel.entries) {
      final avg =
          e.value.map((s) => s.rating).reduce((a, b) => a + b) / e.value.length;
      if (best == null || avg > best.value) {
        best = MapEntry(e.key, avg);
      }
    }
    return best;
  }

  void _toggleChannel(int ch) {
    setState(() {
      if (_highlightedChannels.contains(ch)) {
        _highlightedChannels = {};
      } else {
        _highlightedChannels = {ch};
      }
    });
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

  Widget _emptyFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ControlBar(
          selectedBand: _selectedBand,
          onBandChanged:
              (b) => setState(() {
                _selectedBand = b;
                _highlightedChannels = {};
              }),
          timeRangeIdx: _timeRangeIdx,
          onTimeRangeChanged:
              (i) => setState(() {
                _timeRangeIdx = i;
                _highlightedChannels = {};
              }),
          showModeToggle: false,
          heatmapMode: _heatmapMode,
          onModeToggled: () {},
        ),
        const SizedBox(height: 48),
        Center(
          child: Text(
            context.l10n.historyNoDataForFilter,
            style: GoogleFonts.rajdhani(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Returns a responsive chart height bounded by reasonable min/max so the
/// chart never collapses on small screens nor wastes space on tablets.
double _chartHeight(BuildContext context) {
  final h = MediaQuery.of(context).size.height;
  return math.min(420.0, math.max(280.0, h * 0.42));
}

// ═══════════════════════════════════════════════════════════════════════
//  Control Bar
// ═══════════════════════════════════════════════════════════════════════

class _ControlBar extends StatelessWidget {
  final WifiBand? selectedBand;
  final ValueChanged<WifiBand?> onBandChanged;
  final int timeRangeIdx;
  final ValueChanged<int> onTimeRangeChanged;
  final bool showModeToggle;
  final bool heatmapMode;
  final VoidCallback onModeToggled;

  const _ControlBar({
    required this.selectedBand,
    required this.onBandChanged,
    required this.timeRangeIdx,
    required this.onTimeRangeChanged,
    required this.showModeToggle,
    required this.heatmapMode,
    required this.onModeToggled,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        // Band chips row
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _bandChip(context, null, context.l10n.historyAllBands, primary),
              const SizedBox(width: 6),
              _bandChip(
                context,
                WifiBand.ghz24,
                '2.4',
                const Color(0xFF00E5FF),
              ),
              const SizedBox(width: 6),
              _bandChip(context, WifiBand.ghz5, '5', const Color(0xFF76FF03)),
              const SizedBox(width: 6),
              _bandChip(context, WifiBand.ghz6, '6', const Color(0xFFEEFF41)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Time range + mode toggle row
        Row(
          children: [
            for (var i = 0; i < _timeRangeLabels.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              _timeChip(context, i, onSurface, primary),
            ],
            const Spacer(),
            if (showModeToggle)
              _ModeToggle(heatmapMode: heatmapMode, onToggled: onModeToggled),
          ],
        ),
      ],
    );
  }

  Widget _bandChip(
    BuildContext context,
    WifiBand? band,
    String label,
    Color color,
  ) {
    final isSelected = selectedBand == band;
    return GestureDetector(
      onTap: () => onBandChanged(band),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? color : color.withValues(alpha: 0.5),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _timeChip(
    BuildContext context,
    int idx,
    Color onSurface,
    Color primary,
  ) {
    final isSelected = timeRangeIdx == idx;
    return GestureDetector(
      onTap: () => onTimeRangeChanged(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color:
              isSelected ? primary.withValues(alpha: 0.15) : Colors.transparent,
        ),
        child: Text(
          _timeRangeLabels[idx],
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? primary : onSurface.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool heatmapMode;
  final VoidCallback onToggled;

  const _ModeToggle({required this.heatmapMode, required this.onToggled});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          heatmapMode
              ? context.l10n.historyLineChart
              : context.l10n.historyHeatmap,
      child: GestureDetector(
        onTap: onToggled,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            heatmapMode ? Icons.show_chart_rounded : Icons.grid_view_rounded,
            key: ValueKey(heatmapMode),
            size: 20,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Summary Stats Row
// ═══════════════════════════════════════════════════════════════════════

class _SummaryStatsRow extends StatelessWidget {
  final int? bestChannel;
  final double? bestRating;
  final double avgRating;
  final int sessionCount;

  const _SummaryStatsRow({
    required this.bestChannel,
    required this.bestRating,
    required this.avgRating,
    required this.sessionCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          Expanded(
            child: BentoStatTile(
              label: l10n.historyBestChannel,
              value: bestChannel != null ? 'CH $bestChannel' : '—',
              icon: Icons.star_rounded,
              color: AppColors.neonGreen,
              subValue: bestRating?.toStringAsFixed(1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: BentoStatTile(
              label: l10n.historyAvgRating,
              value: avgRating.toStringAsFixed(1),
              icon: Icons.analytics_outlined,
              color: AppColors.neonCyan,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: BentoStatTile(
              label: l10n.historySessions,
              value: '$sessionCount',
              icon: Icons.timeline_rounded,
              color: AppColors.neonPurple,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Interactive Legend (Wrap so many channels overflow to next line)
// ═══════════════════════════════════════════════════════════════════════

class _InteractiveLegend extends StatelessWidget {
  final List<int> channels;
  final Color Function(int index, int total) colorForIndex;
  final Set<int> highlighted;
  final Set<int> unstable;
  final ValueChanged<int> onToggle;

  const _InteractiveLegend({
    required this.channels,
    required this.colorForIndex,
    required this.highlighted,
    required this.unstable,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < channels.length; i++)
          _legendChip(context, i, channels[i], l10n.unstableChannelTooltip),
      ],
    );
  }

  Widget _legendChip(
    BuildContext context,
    int i,
    int ch,
    String unstableTooltip,
  ) {
    final color = colorForIndex(i, channels.length);
    final isActive = highlighted.isEmpty || highlighted.contains(ch);
    final isUnstable = unstable.contains(ch);

    final chip = AnimatedOpacity(
      opacity: isActive ? 1.0 : 0.35,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color.withValues(alpha: isActive ? 0.15 : 0.05),
          border: Border.all(
            color: color.withValues(alpha: isActive ? 0.6 : 0.25),
            width: isUnstable ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CH $ch',
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isUnstable) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.warning_amber_rounded,
                size: 12,
                color: AppColors.neonOrange,
              ),
            ],
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: () => onToggle(ch),
      child: isUnstable ? Tooltip(message: unstableTooltip, child: chip) : chip,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Bar Chart (single session)
// ═══════════════════════════════════════════════════════════════════════

class _BarView extends StatelessWidget {
  final List<int> channels;
  final Map<int, List<ChannelRatingSample>> byChannel;
  final Color Function(int index, int total) colorForIndex;
  final Set<int> highlighted;

  const _BarView({
    super.key,
    required this.channels,
    required this.byChannel,
    required this.colorForIndex,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final manyChannels = channels.length > 12;

    final groups =
        channels.asMap().entries.map((entry) {
          final i = entry.key;
          final ch = entry.value;
          final rating = byChannel[ch]!.last.rating.clamp(0.0, 10.0);
          final color = colorForIndex(i, channels.length);
          final isActive = highlighted.isEmpty || highlighted.contains(ch);

          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: rating,
                color: color.withValues(alpha: isActive ? 1.0 : 0.25),
                width: manyChannels ? 12 : 18,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 10,
                  color: color.withValues(alpha: 0.05),
                ),
              ),
            ],
          );
        }).toList();

    return NeonCard(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      child: SizedBox(
        height: _chartHeight(context),
        child: BarChart(
          swapAnimationDuration: const Duration(milliseconds: 300),
          swapAnimationCurve: Curves.easeOutCubic,
          BarChartData(
            barGroups: groups,
            maxY: 10,
            gridData: FlGridData(
              drawHorizontalLine: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine:
                  (_) => FlLine(
                    color: onSurface.withValues(alpha: 0.08),
                    strokeWidth: 1,
                  ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: manyChannels ? 38 : 24,
                  getTitlesWidget: (v, _) {
                    final idx = v.toInt();
                    if (idx < 0 || idx >= channels.length) {
                      return const SizedBox.shrink();
                    }
                    final color = colorForIndex(idx, channels.length);
                    final text = Text(
                      'CH${channels[idx]}',
                      style: GoogleFonts.rajdhani(
                        fontSize: 9,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                    if (manyChannels) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Transform.rotate(
                          angle: -0.65,
                          alignment: Alignment.topCenter,
                          child: text,
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: text,
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 2,
                  getTitlesWidget:
                      (v, _) => Text(
                        v.toInt().toString(),
                        style: GoogleFonts.rajdhani(
                          fontSize: 10,
                          color: onSurface.withValues(alpha: 0.5),
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
                  final ch = channels[group.x];
                  return BarTooltipItem(
                    'CH $ch\n${rod.toY.toStringAsFixed(0)}',
                    GoogleFonts.rajdhani(
                      color: colorForIndex(groupIndex, channels.length),
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Line Chart (multi-session)
// ═══════════════════════════════════════════════════════════════════════

class _LineView extends StatelessWidget {
  final List<int> channels;
  final Map<int, List<ChannelRatingSample>> byChannel;
  final List<DateTime> sessions;
  final Color Function(int index, int total) colorForIndex;
  final int totalSamples;
  final Set<int> highlighted;

  const _LineView({
    super.key,
    required this.channels,
    required this.byChannel,
    required this.sessions,
    required this.colorForIndex,
    required this.totalSamples,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final lines =
        channels.asMap().entries.map((entry) {
          final i = entry.key;
          final ch = entry.value;
          final color = colorForIndex(i, channels.length);
          final chSamples = byChannel[ch]!;
          final isActive = highlighted.isEmpty || highlighted.contains(ch);

          final spots = <FlSpot>[];
          for (var si = 0; si < sessions.length; si++) {
            final sessionTs = sessions[si];
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
              spots.add(FlSpot(si.toDouble(), best.rating.clamp(0.0, 10.0)));
            }
          }

          // Only paint a fill below the line when this channel is the
          // *only* highlighted one — otherwise every channel's fill area
          // (0..rating) stacks and the highest-scoring channel's fill
          // hides every line beneath it.
          final isFocused = highlighted.contains(ch);
          return LineChartBarData(
            spots: spots,
            isCurved: spots.length > 2,
            color: color.withValues(alpha: isActive ? 1.0 : 0.25),
            barWidth: isActive ? 2.5 : 1.2,
            dotData: FlDotData(
              show: isFocused || spots.length <= 10,
            ),
            belowBarData: BarAreaData(
              show: isFocused,
              color: color.withValues(alpha: 0.18),
            ),
          );
        }).toList();

    // X-axis labels
    String sessionLabel(int idx) {
      if (idx < 0 || idx >= sessions.length) return '';
      final ts = sessions[idx];
      // Show date if sessions span multiple days
      final first = sessions.first;
      final last = sessions.last;
      final multiDay = last.difference(first).inHours > 24;
      if (multiDay) {
        return '${ts.day}/${ts.month}\n${ts.hour.toString().padLeft(2, '0')}:'
            '${ts.minute.toString().padLeft(2, '0')}';
      }
      return '${ts.hour.toString().padLeft(2, '0')}:'
          '${ts.minute.toString().padLeft(2, '0')}';
    }

    final labelStep = (sessions.length / 5).ceil().clamp(1, sessions.length);

    return NeonCard(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      child: SizedBox(
        height: _chartHeight(context),
        child: LineChart(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          LineChartData(
            lineBarsData: lines,
            minY: 0,
            maxY: 10,
            minX: 0,
            maxX: (sessions.length - 1).toDouble(),
            gridData: FlGridData(
              drawHorizontalLine: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine:
                  (_) => FlLine(
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
                  interval: 2,
                  getTitlesWidget:
                      (v, _) => Text(
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
                  reservedSize: 32,
                  interval: labelStep.toDouble(),
                  getTitlesWidget: (v, _) {
                    final idx = v.toInt();
                    if (idx % labelStep != 0) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        sessionLabel(idx),
                        textAlign: TextAlign.center,
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
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipColor:
                    (_) =>
                        isDark
                            ? const Color(0xFF1E293B)
                            : Theme.of(context).colorScheme.surface,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final ch = channels[spot.barIndex];
                    final time = sessionLabel(spot.x.toInt());
                    return LineTooltipItem(
                      'CH $ch: ${spot.y.toStringAsFixed(0)}'
                      '${time.isNotEmpty ? '\n$time' : ''}',
                      GoogleFonts.rajdhani(
                        color:
                            spot.bar.color ??
                            Theme.of(context).colorScheme.primary,
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Heatmap View (multi-session) — adaptive cells, single horizontal scroll
//  containing both header (time labels) and grid so they stay in sync.
// ═══════════════════════════════════════════════════════════════════════

class _HeatmapView extends StatelessWidget {
  final List<int> channels;
  final Map<int, List<ChannelRatingSample>> byChannel;
  final List<DateTime> sessions;
  final Set<int> highlighted;

  const _HeatmapView({
    super.key,
    required this.channels,
    required this.byChannel,
    required this.sessions,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // Build rating matrix: [channelIdx][sessionIdx] → rating (or null)
    final matrix = <int, Map<int, double>>{};
    for (var ci = 0; ci < channels.length; ci++) {
      final ch = channels[ci];
      final samples = byChannel[ch]!;
      matrix[ci] = {};
      for (var si = 0; si < sessions.length; si++) {
        final sessionTs = sessions[si];
        ChannelRatingSample? best;
        int bestDiff = 999999;
        for (final s in samples) {
          final diff = s.timestamp.difference(sessionTs).inSeconds.abs();
          if (diff < bestDiff) {
            bestDiff = diff;
            best = s;
          }
        }
        if (best != null && bestDiff <= 30) {
          matrix[ci]![si] = best.rating.clamp(0.0, 10.0);
        }
      }
    }

    final maxH = _chartHeight(context);

    return NeonCard(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const labelW = 48.0;
          const headerH = 22.0;
          const minCellW = 24.0;
          const minCellH = 16.0;
          const maxCellH = 32.0;

          final available = constraints.maxWidth;
          final available5 = available - labelW;
          // Fit-to-width if possible; otherwise fall back to minCellW and let
          // the user scroll horizontally.
          final cellW = math.max(minCellW, available5 / sessions.length);

          // Available vertical space for the grid itself (minus header & legend).
          final gridSpace = maxH - headerH - 32;
          final cellH = (gridSpace / channels.length).clamp(
            minCellH,
            maxCellH,
          );
          final totalGridW = labelW + sessions.length * cellW;
          final totalGridH = channels.length * cellH;
          final needsHScroll = totalGridW > available + 0.5;

          // The grid + time-label header live in the same horizontal scroll
          // view so they stay perfectly aligned. Step adapts to actual cell
          // width so wider screens show more labels without crowding.
          // Each label needs ~36px of horizontal room.
          const minLabelGap = 36.0;
          final stepFromWidth = (minLabelGap / cellW).ceil();
          final timeStep = math.max(1, stepFromWidth);
          final body = SizedBox(
            width: totalGridW,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: headerH,
                  child: Padding(
                    padding: const EdgeInsets.only(left: labelW),
                    child: Row(
                      children: [
                        for (var si = 0; si < sessions.length; si++)
                          SizedBox(
                            width: cellW,
                            child:
                                si % timeStep == 0
                                    ? Text(
                                      '${sessions[si].hour.toString().padLeft(2, '0')}:'
                                      '${sessions[si].minute.toString().padLeft(2, '0')}',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.rajdhani(
                                        fontSize: 8,
                                        color: onSurface.withValues(alpha: 0.5),
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: totalGridW,
                  height: totalGridH,
                  child: CustomPaint(
                    painter: _HeatmapPainter(
                      channels: channels,
                      sessions: sessions,
                      matrix: matrix,
                      highlighted: highlighted,
                      cellW: cellW,
                      cellH: cellH,
                      labelW: labelW,
                      textColor: onSurface,
                      isDark: isDark,
                    ),
                  ),
                ),
              ],
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (needsHScroll)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: body,
                )
              else
                body,
              const SizedBox(height: 8),
              _HeatmapColorScale(textColor: onSurface, isDark: isDark),
            ],
          );
        },
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final List<int> channels;
  final List<DateTime> sessions;
  final Map<int, Map<int, double>> matrix;
  final Set<int> highlighted;
  final double cellW;
  final double cellH;
  final double labelW;
  final Color textColor;
  final bool isDark;

  _HeatmapPainter({
    required this.channels,
    required this.sessions,
    required this.matrix,
    required this.highlighted,
    required this.cellW,
    required this.cellH,
    required this.labelW,
    required this.textColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final labelPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var ci = 0; ci < channels.length; ci++) {
      final ch = channels[ci];
      final isActive = highlighted.isEmpty || highlighted.contains(ch);
      final y = ci * cellH;

      // Channel label
      labelPainter.text = TextSpan(
        text: 'CH $ch',
        style: GoogleFonts.rajdhani(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor.withValues(alpha: isActive ? 0.7 : 0.2),
        ),
      );
      labelPainter.layout(maxWidth: labelW - 4);
      labelPainter.paint(
        canvas,
        Offset(0, y + (cellH - labelPainter.height) / 2),
      );

      // Cells
      for (var si = 0; si < sessions.length; si++) {
        final x = labelW + si * cellW;
        final rating = matrix[ci]?[si];
        final rect = Rect.fromLTWH(x + 1, y + 1, cellW - 2, cellH - 2);

        if (rating != null) {
          final color = _ratingColor(
            rating,
            isDark,
          ).withValues(alpha: isActive ? 0.85 : 0.18);
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(3)),
            Paint()..color = color,
          );
        } else {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(3)),
            Paint()..color = textColor.withValues(alpha: 0.04),
          );
        }
      }
    }
  }

  /// Light theme uses a more saturated orange mid-stop because the
  /// fluorescent yellow used for dark theme nearly disappears on white.
  static Color _ratingColor(double rating, bool isDark) {
    final t = (rating / 10).clamp(0.0, 1.0);
    final low = const Color(0xFFFF1744);
    final mid = isDark ? const Color(0xFFEEFF41) : const Color(0xFFFF8F00);
    final high =
        isDark ? const Color(0xFF39FF14) : const Color(0xFF2E7D32);
    if (t < 0.5) {
      return Color.lerp(low, mid, t * 2)!;
    }
    return Color.lerp(mid, high, (t - 0.5) * 2)!;
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) =>
      oldDelegate.matrix != matrix ||
      oldDelegate.highlighted != highlighted ||
      oldDelegate.channels != channels ||
      oldDelegate.cellW != cellW ||
      oldDelegate.cellH != cellH ||
      oldDelegate.isDark != isDark;
}

class _HeatmapColorScale extends StatelessWidget {
  final Color textColor;
  final bool isDark;

  const _HeatmapColorScale({required this.textColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final low = const Color(0xFFFF1744);
    final mid = isDark ? const Color(0xFFEEFF41) : const Color(0xFFFF8F00);
    final high = isDark ? const Color(0xFF39FF14) : const Color(0xFF2E7D32);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '0',
          style: GoogleFonts.rajdhani(
            fontSize: 10,
            color: textColor.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 120,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(colors: [low, mid, high]),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '10',
          style: GoogleFonts.rajdhani(
            fontSize: 10,
            color: textColor.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
