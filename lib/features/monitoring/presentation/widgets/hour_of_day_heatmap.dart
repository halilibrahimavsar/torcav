import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../wifi_scan/domain/entities/channel_rating_sample.dart';
import 'spectrum_colors.dart';

/// 24h × channel grid that aggregates the rating history into the average
/// score each channel had during each hour of the day. Useful to spot
/// "this channel is great in the morning but terrible in the evening".
class HourOfDayHeatmap extends StatelessWidget {
  final List<ChannelRatingSample> samples;
  const HourOfDayHeatmap({super.key, required this.samples});

  static const int _minHoursWithData = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (samples.isEmpty) {
      return _empty(context, l10n.hourlyHeatmapInsufficient);
    }

    // Build matrix: channel -> hour(0..23) -> [sum, count] for averaging.
    final byChannelHour = <int, List<List<double>>>{};
    for (final s in samples) {
      final ch = s.channel;
      final h = s.timestamp.hour;
      final row = byChannelHour.putIfAbsent(
        ch,
        () => List.generate(24, (_) => <double>[]),
      );
      row[h].add(s.rating);
    }

    final hoursWithData =
        List.generate(24, (h) => h)
            .where((h) => byChannelHour.values.any((row) => row[h].isNotEmpty))
            .length;
    if (hoursWithData < _minHoursWithData) {
      return _empty(context, l10n.hourlyHeatmapInsufficient);
    }

    final channels = byChannelHour.keys.toList()..sort();

    return LayoutBuilder(
      builder: (ctx, constraints) {
        const labelW = 38.0;
        const minCellW = 14.0;
        final available = constraints.maxWidth - 8;
        final cellW = math.max(minCellW, (available - labelW) / 24);
        final cellH = math.min(22.0, math.max(14.0, cellW));
        final totalH = channels.length * cellH + 26;
        final totalW = labelW + 24 * cellW;

        return SizedBox(
          height: totalH,
          width: totalW,
          child: CustomPaint(
            painter: _HourlyPainter(
              channels: channels,
              byChannelHour: byChannelHour,
              cellW: cellW,
              cellH: cellH,
              labelW: labelW,
              textColor: onSurface,
              isDark: isDark,
            ),
          ),
        );
      },
    );
  }

  Widget _empty(BuildContext context, String text) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: onSurface.withValues(alpha: 0.04),
      ),
      child: Text(
        text,
        style: GoogleFonts.rajdhani(
          fontSize: 12,
          color: onSurface.withValues(alpha: 0.6),
          height: 1.4,
        ),
      ),
    );
  }
}

class _HourlyPainter extends CustomPainter {
  final List<int> channels;
  final Map<int, List<List<double>>> byChannelHour;
  final double cellW;
  final double cellH;
  final double labelW;
  final Color textColor;
  final bool isDark;

  _HourlyPainter({
    required this.channels,
    required this.byChannelHour,
    required this.cellW,
    required this.cellH,
    required this.labelW,
    required this.textColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(textDirection: TextDirection.ltr);

    // Hour header row (every 3 hours: 0, 3, 6, 9, 12, 15, 18, 21).
    for (var h = 0; h < 24; h += 3) {
      tp.text = TextSpan(
        text: '$h',
        style: GoogleFonts.rajdhani(
          fontSize: 9,
          color: textColor.withValues(alpha: 0.5),
        ),
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(labelW + h * cellW + (cellW * 1.5 - tp.width) / 2, 4),
      );
    }

    const headerH = 22.0;
    for (var ci = 0; ci < channels.length; ci++) {
      final ch = channels[ci];
      final y = headerH + ci * cellH;

      // Channel label
      tp.text = TextSpan(
        text: 'CH$ch',
        style: GoogleFonts.rajdhani(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor.withValues(alpha: 0.7),
        ),
      );
      tp.layout(maxWidth: labelW - 4);
      tp.paint(canvas, Offset(0, y + (cellH - tp.height) / 2));

      // 24 cells
      final hourly = byChannelHour[ch]!;
      for (var h = 0; h < 24; h++) {
        final values = hourly[h];
        final x = labelW + h * cellW;
        final rect = Rect.fromLTWH(x + 1, y + 1, cellW - 2, cellH - 2);
        if (values.isEmpty) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(2)),
            Paint()..color = textColor.withValues(alpha: 0.04),
          );
        } else {
          final avg = values.reduce((a, b) => a + b) / values.length;
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(2)),
            Paint()
              ..color = ratingHeatmapColor(
                avg,
                isDark: isDark,
              ).withValues(alpha: 0.85),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HourlyPainter old) =>
      old.channels != channels ||
      old.byChannelHour != byChannelHour ||
      old.cellW != cellW ||
      old.cellH != cellH ||
      old.isDark != isDark;
}
