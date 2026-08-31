import 'dart:math' as math;
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../wifi_scan/domain/entities/wifi_network.dart';

/// Classic Wi-Fi-Analyzer-style spectrum view: each network is rendered as a
/// trapezoidal bell over the frequency axis (centre = its frequency, width =
/// channelWidthMhz, height ∝ signal strength). Overlapping shapes visually
/// reveal interference between neighbouring APs.
class SpectrumOverlapChart extends StatefulWidget {
  /// Networks belonging to a single band — the band is inferred from the
  /// frequency range of the supplied list.
  final List<WifiNetwork> networks;
  final Color accentColor;

  /// Optional BSSID of the user's currently-connected router; if present,
  /// that network is drawn with a thicker outline and a star marker.
  final String? connectedBssid;

  const SpectrumOverlapChart({
    super.key,
    required this.networks,
    required this.accentColor,
    this.connectedBssid,
  });

  @override
  State<SpectrumOverlapChart> createState() => _SpectrumOverlapChartState();
}

class _SpectrumOverlapChartState extends State<SpectrumOverlapChart> {
  WifiNetwork? _selected;

  // Visual constants
  static const double _minDbm = -100;
  static const double _maxDbm = -30;
  // Side padding (px) for axis labels.
  static const double _padLeft = 36;
  static const double _padRight = 8;
  static const double _padTop = 8;
  static const double _padBottom = 22;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (widget.networks.isEmpty) {
      return Container(
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: onSurface.withValues(alpha: 0.04),
          border: Border.all(color: onSurface.withValues(alpha: 0.08)),
        ),
        child: Text(
          l10n.spectrumOverlapEmptyHint,
          style: GoogleFonts.rajdhani(
            fontSize: 13,
            color: onSurface.withValues(alpha: 0.55),
          ),
        ),
      );
    }

    // Determine the visible frequency range from the band of the first net.
    final range = _bandRangeFor(widget.networks);
    final screenH = MediaQuery.of(context).size.height;
    final height = math.min(320.0, math.max(220.0, screenH * 0.32));

    final connectedBssid = widget.connectedBssid?.toUpperCase();

    return Container(
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            isDark
                ? const Color(0xFF0F172A)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: onSurface.withValues(alpha: 0.12)),
      ),
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              final selected = _hitTest(
                details.localPosition,
                size: _innerSize(context),
                range: range,
              );
              setState(() => _selected = selected);
            },
            child: Semantics(
              // The plot is the evidence behind the channel recommendation;
              // its shape means nothing read aloud, its census does.
              label: context.l10n.a11ySpectrumChart(widget.networks.length),
              child: ExcludeSemantics(
              child: CustomPaint(
              size: Size.infinite,
              painter: _SpectrumPainter(
                networks: widget.networks,
                range: range,
                accentColor: widget.accentColor,
                onSurface: onSurface,
                isDark: isDark,
                selectedBssid: _selected?.bssid,
                connectedBssid: connectedBssid,
                connectedLabel: l10n.connectedChannelGuideLabel,
                padLeft: _padLeft,
                padRight: _padRight,
                padTop: _padTop,
                padBottom: _padBottom,
                minDbm: _minDbm,
                maxDbm: _maxDbm,
              ),
            ),
              ),
            ),
          ),
          if (_selected != null)
            Positioned(
              top: 4,
              right: 4,
              child: _SelectedNetworkChip(
                network: _selected!,
                accentColor: widget.accentColor,
                onClose: () => setState(() => _selected = null),
              ),
            ),
        ],
      ),
    );
  }

  /// Hit-test: find a network whose drawn shape contains the tap point.
  /// Picks the network with the strongest signal at that frequency.
  WifiNetwork? _hitTest(
    Offset tap, {
    required Size size,
    required _FreqRange range,
  }) {
    final w = size.width - _padLeft - _padRight;
    final h = size.height - _padTop - _padBottom;
    if (w <= 0 || h <= 0) return null;

    final tapFreq =
        range.low + ((tap.dx - _padLeft) / w) * (range.high - range.low);
    final tapY = tap.dy;

    WifiNetwork? best;
    int bestSignal = -200;
    for (final n in widget.networks) {
      if (n.frequency <= 0) continue;
      final width = (n.channelWidthMhz ?? 20).toDouble();
      final low = n.frequency - width / 2;
      final high = n.frequency + width / 2;
      if (tapFreq < low || tapFreq > high) continue;

      // Y range of the bell at the tap frequency (linear taper to edges).
      final dyRatio =
          1.0 - (2 * (tapFreq - n.frequency).abs() / width).clamp(0.0, 1.0);
      final topNorm = ((n.signalStrength - _minDbm) / (_maxDbm - _minDbm))
          .clamp(0.0, 1.0);
      final shapeTop = _padTop + (1 - topNorm) * h;
      // Linear taper means the shape rises from baseline at edges to topNorm
      // at centre; we mirror that by interpolating the y-top.
      final shapeY = _padTop + h - dyRatio * (h * topNorm);
      final baseline = _padTop + h;
      if (tapY >= shapeY && tapY <= baseline) {
        if (n.signalStrength > bestSignal) {
          best = n;
          bestSignal = n.signalStrength;
        }
      }
      // Suppress unused-local warning; included to clarify the math above.
      assert(shapeTop >= 0);
    }
    return best;
  }

  Size _innerSize(BuildContext context) {
    final box = context.findRenderObject();
    if (box is RenderBox) return box.size;
    return MediaQuery.of(context).size;
  }
}

/// Inferred horizontal frequency range of the chart from the supplied
/// networks. Snaps to canonical band edges + a small margin so individual
/// shapes never touch the chart border.
class _FreqRange {
  final double low;
  final double high;
  final List<int> labelChannels;
  const _FreqRange(this.low, this.high, this.labelChannels);
}

_FreqRange _bandRangeFor(List<WifiNetwork> networks) {
  final freqs = networks.map((n) => n.frequency).where((f) => f > 0).toList();
  if (freqs.isEmpty) {
    return const _FreqRange(2400, 2500, [1, 6, 11]);
  }
  final maxF = freqs.reduce(math.max);
  if (maxF < 2500) {
    // 2.4 GHz: span the regulated channels with a small visual margin.
    return const _FreqRange(2400, 2495, [1, 3, 6, 9, 11, 13]);
  }
  if (maxF < 5925) {
    // 5 GHz: cover the practical band span.
    return const _FreqRange(5150, 5870, [36, 52, 64, 100, 116, 132, 149, 161]);
  }
  // 6 GHz
  return const _FreqRange(5925, 7125, [1, 33, 65, 97, 129, 161, 193, 225]);
}

class _SpectrumPainter extends CustomPainter {
  final List<WifiNetwork> networks;
  final _FreqRange range;
  final Color accentColor;
  final Color onSurface;
  final bool isDark;
  final String? selectedBssid;
  final String? connectedBssid;
  final String connectedLabel;
  final double padLeft;
  final double padRight;
  final double padTop;
  final double padBottom;
  final double minDbm;
  final double maxDbm;

  _SpectrumPainter({
    required this.networks,
    required this.range,
    required this.accentColor,
    required this.onSurface,
    required this.isDark,
    required this.selectedBssid,
    required this.connectedBssid,
    required this.connectedLabel,
    required this.padLeft,
    required this.padRight,
    required this.padTop,
    required this.padBottom,
    required this.minDbm,
    required this.maxDbm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width - padLeft - padRight;
    final h = size.height - padTop - padBottom;
    if (w <= 0 || h <= 0) return;

    _drawAxes(canvas, size, w, h);

    // Draw networks back-to-front, weakest first so strong (large) shapes
    // don't completely hide weak ones — opposite of real signal "dominance"
    // but better readability.
    final sorted = [...networks]
      ..sort((a, b) => a.signalStrength.compareTo(b.signalStrength));

    for (final n in sorted) {
      if (n.frequency <= 0) continue;
      _drawNetwork(canvas, n, w, h);
    }

    // "YOU" guide line — drawn last so it sits above bell curves.
    _drawConnectedGuide(canvas, w, h);
  }

  void _drawConnectedGuide(Canvas canvas, double w, double h) {
    final bssid = connectedBssid;
    if (bssid == null) return;
    WifiNetwork? me;
    for (final n in networks) {
      if (n.bssid.toUpperCase() == bssid) {
        me = n;
        break;
      }
    }
    if (me == null || me.frequency <= 0) return;
    if (me.frequency < range.low || me.frequency > range.high) return;

    final x =
        padLeft + ((me.frequency - range.low) / (range.high - range.low)) * w;
    const color = AppColors.neonCyan;

    // Dashed vertical line.
    final dashPaint =
        Paint()
          ..color = color.withValues(alpha: 0.85)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
    const dashLen = 4.0;
    const gapLen = 3.0;
    double y = padTop + 14;
    final yMax = padTop + h;
    while (y < yMax) {
      final yEnd = math.min(y + dashLen, yMax);
      canvas.drawLine(Offset(x, y), Offset(x, yEnd), dashPaint);
      y = yEnd + gapLen;
    }

    // Downward triangle marker at top.
    final triPath =
        Path()
          ..moveTo(x - 4, padTop + 4)
          ..lineTo(x + 4, padTop + 4)
          ..lineTo(x, padTop + 12)
          ..close();
    canvas.drawPath(triPath, Paint()..color = color);

    // YOU label centred on top of the line.
    final label = TextPainter(
      text: TextSpan(
        text: connectedLabel,
        style: GoogleFonts.orbitron(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // Background plate for readability over busy areas.
    final bgRect = Rect.fromLTWH(
      x - label.width / 2 - 4,
      0,
      label.width + 8,
      label.height + 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(3)),
      Paint()
        ..color = (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(
          alpha: 0.85,
        ),
    );
    label.paint(canvas, Offset(x - label.width / 2, 1));
  }

  void _drawAxes(Canvas canvas, Size size, double w, double h) {
    // Y-axis (signal) reference lines + labels
    const dbmSteps = [-30, -50, -70, -90];
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final gridPaint =
        Paint()
          ..color = onSurface.withValues(alpha: 0.07)
          ..strokeWidth = 1;
    for (final dbm in dbmSteps) {
      final norm = (dbm - minDbm) / (maxDbm - minDbm);
      final y = padTop + (1 - norm) * h;
      canvas.drawLine(Offset(padLeft, y), Offset(padLeft + w, y), gridPaint);
      tp.text = TextSpan(
        text: '$dbm',
        style: GoogleFonts.rajdhani(
          fontSize: 9,
          color: onSurface.withValues(alpha: 0.4),
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(padLeft - tp.width - 4, y - tp.height / 2));
    }

    // X-axis (channel) tick labels
    for (final ch in range.labelChannels) {
      final f = _frequencyOfChannel(ch);
      if (f < range.low || f > range.high) continue;
      final norm = (f - range.low) / (range.high - range.low);
      final x = padLeft + norm * w;
      canvas.drawLine(
        Offset(x, padTop + h),
        Offset(x, padTop + h + 3),
        gridPaint..color = onSurface.withValues(alpha: 0.2),
      );
      tp.text = TextSpan(
        text: 'CH$ch',
        style: GoogleFonts.rajdhani(
          fontSize: 9,
          color: onSurface.withValues(alpha: 0.5),
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, padTop + h + 6));
    }
  }

  double _frequencyOfChannel(int ch) {
    if (range.low < 2500) {
      // 2.4 GHz
      if (ch == 14) return 2484;
      return 2412 + (ch - 1) * 5;
    }
    if (range.low < 5925) {
      return 5000 + ch * 5;
    }
    return 5950 + ch * 5;
  }

  void _drawNetwork(Canvas canvas, WifiNetwork n, double w, double h) {
    final width = (n.channelWidthMhz ?? 20).toDouble();
    final low = (n.frequency - width / 2).clamp(range.low, range.high);
    final high = (n.frequency + width / 2).clamp(range.low, range.high);

    final xLow = padLeft + ((low - range.low) / (range.high - range.low)) * w;
    final xHigh = padLeft + ((high - range.low) / (range.high - range.low)) * w;
    final xCentre =
        padLeft + ((n.frequency - range.low) / (range.high - range.low)) * w;

    final norm = ((n.signalStrength - minDbm) / (maxDbm - minDbm)).clamp(
      0.0,
      1.0,
    );
    final yTop = padTop + (1 - norm) * h;
    final yBase = padTop + h;

    final isSelected = selectedBssid != null && selectedBssid == n.bssid;
    final isConnected =
        connectedBssid != null && connectedBssid == n.bssid.toUpperCase();
    final color = _colorForBssid(n.bssid);

    // Trapezoidal bell: vertices at (xLow, yBase), (xCentre, yTop),
    // (xHigh, yBase). For wider channels we curve slightly.
    final path =
        Path()
          ..moveTo(xLow, yBase)
          ..lineTo(xCentre, yTop)
          ..lineTo(xHigh, yBase)
          ..close();

    final fill =
        Paint()
          ..color = color.withValues(
            alpha: isSelected ? 0.5 : (isConnected ? 0.42 : 0.28),
          )
          ..style = PaintingStyle.fill;
    canvas.drawPath(path, fill);

    final outline =
        Paint()
          ..color = color.withValues(
            alpha: isSelected || isConnected ? 1.0 : 0.85,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 2.5 : (isConnected ? 2.0 : 1.2);
    canvas.drawPath(path, outline);

    // Connected-router marker: a small star at the apex.
    if (isConnected) {
      final markerPaint =
          Paint()
            ..color = color
            ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(xCentre, yTop - 2), 3.5, markerPaint);
      canvas.drawPoints(
        PointMode.points,
        [Offset(xCentre, yTop - 2)],
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2,
      );
    }

    // SSID label at apex if there's enough vertical room.
    if (norm > 0.2 && (xHigh - xLow) > 28) {
      final isHidden = n.ssid.isEmpty || n.isHidden;
      final ssid = isHidden ? '[Hidden]' : n.ssid;
      final tp = TextPainter(
        text: TextSpan(
          text: ssid,
          style: GoogleFonts.rajdhani(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: color,
            fontStyle: isHidden ? FontStyle.italic : FontStyle.normal,
          ),
        ),
        maxLines: 1,
        ellipsis: '…',
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: math.max(20.0, xHigh - xLow));
      tp.paint(canvas, Offset(xCentre - tp.width / 2, yTop - tp.height - 2));
    }
  }

  /// Stable color from BSSID hash so each network has the same color across
  /// rebuilds.
  Color _colorForBssid(String bssid) {
    if (bssid.isEmpty) return accentColor;
    final h = bssid.codeUnits.fold<int>(0, (acc, c) => (acc * 31 + c) & 0xFFFF);
    final hue = (h % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.75, isDark ? 0.65 : 0.45).toColor();
  }

  @override
  bool shouldRepaint(covariant _SpectrumPainter old) {
    return old.networks != networks ||
        old.selectedBssid != selectedBssid ||
        old.connectedBssid != connectedBssid ||
        old.isDark != isDark;
  }
}

class _SelectedNetworkChip extends StatelessWidget {
  final WifiNetwork network;
  final Color accentColor;
  final VoidCallback onClose;
  const _SelectedNetworkChip({
    required this.network,
    required this.accentColor,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final width = network.channelWidthMhz ?? 20;
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
        decoration: BoxDecoration(
          color:
              isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accentColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    network.ssid.isEmpty ? '<hidden>' : network.ssid,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                  Text(
                    'CH ${network.channel} · ${network.frequency} MHz · '
                    '${width}MHz · ${network.signalStrength} dBm',
                    style: GoogleFonts.rajdhani(
                      fontSize: 10,
                      color: onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 16,
                color: onSurface.withValues(alpha: 0.6),
              ),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
