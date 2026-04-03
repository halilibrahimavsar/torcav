import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../domain/entities/heatmap_point.dart';
import '../../domain/entities/heatmap_session.dart';

/// Renders signal-strength data as a colour-gradient heatmap.
///
/// Each [HeatmapPoint] is painted as a radial gradient blob; points are
/// alpha-blended so dense areas show a richer colour. The colour palette
/// maps signal strength from −90 dBm (cold, blue) to −30 dBm (hot, red),
/// matching the conventional "Wi-Fi heat map" convention.
class HeatmapCanvas extends StatelessWidget {
  const HeatmapCanvas({
    required this.session,
    this.onTap,
    super.key,
  });

  final HeatmapSession session;

  /// Called with the normalised [Offset] when the user taps to add a point.
  final void Function(Offset normalised)? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:
          onTap == null
              ? null
              : (d) {
                  final box = context.findRenderObject()! as RenderBox;
                  final local = d.localPosition;
                  final norm = Offset(
                    local.dx / box.size.width,
                    local.dy / box.size.height,
                  );
                  onTap!(norm);
                },
      child: CustomPaint(
        painter: _HeatmapPainter(session: session),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({required this.session});

  final HeatmapSession session;

  @override
  void paint(Canvas canvas, Size size) {
    // Grid backdrop
    _drawGrid(canvas, size);

    if (session.points.isEmpty) return;

    final rssiRange = math.max(1, session.maxRssi - session.minRssi);

    for (final point in session.points) {
      final t = ((point.rssi - session.minRssi) / rssiRange).clamp(0.0, 1.0);
      final centre = Offset(point.x * size.width, point.y * size.height);
      final radius = size.shortestSide * 0.12;

      final paint = Paint()
        ..shader = ui.Gradient.radial(
          centre,
          radius,
          [
            _signalColour(t).withValues(alpha: 0.75),
            _signalColour(t).withValues(alpha: 0.0),
          ],
        );
      canvas.drawCircle(centre, radius, paint);

      // Dot marker
      canvas.drawCircle(
        centre,
        4,
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;
    const divisions = 10;
    for (var i = 1; i < divisions; i++) {
      final x = size.width * i / divisions;
      final y = size.height * i / divisions;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  /// Maps a normalised signal quality [t] (0=weak → 1=strong) to a colour.
  Color _signalColour(double t) {
    // Cold–Warm gradient: blue → cyan → green → yellow → red
    const stops = [
      Color(0xFF0000FF), // blue   — very weak
      Color(0xFF00FFFF), // cyan
      Color(0xFF00FF00), // green
      Color(0xFFFFFF00), // yellow
      Color(0xFFFF0000), // red    — very strong
    ];
    final scaled = t * (stops.length - 1);
    final idx = scaled.floor().clamp(0, stops.length - 2);
    final frac = scaled - idx;
    return Color.lerp(stops[idx], stops[idx + 1], frac)!;
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) => old.session != session;
}
