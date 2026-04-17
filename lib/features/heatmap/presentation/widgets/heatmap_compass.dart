import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/heatmap_bloc.dart' show HeatmapBloc, HeatmapState;
import '../../../../core/theme/app_theme.dart';

/// A premium, rotating compass ring that reflects the real device heading.
/// Tapping it recalibrates the AR heading.
///
/// When [heading] is provided (e.g., forwarded from a parent BlocSelector),
/// the internal BlocSelector subscription is skipped, avoiding a redundant
/// second subscription that could fire at a different frame than the parent.
class HeatmapCompass extends StatelessWidget {
  final double size;

  /// Optional pre-resolved heading from a parent listener.
  /// When null, the widget subscribes to [HeatmapBloc] directly.
  final double? heading;

  const HeatmapCompass({
    this.size = 56,
    this.heading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (heading != null) {
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _CompassPainter(
            heading: heading!,
            theme: Theme.of(context),
          ),
        ),
      );
    }
    return BlocSelector<HeatmapBloc, HeatmapState, double>(
      selector: (s) => s.currentHeading,
      builder: (context, resolvedHeading) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _CompassPainter(
              heading: resolvedHeading,
              theme: Theme.of(context),
            ),
          ),
        );
      },
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({
    required this.heading,
    required this.theme,
  });

  final double heading;
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final isLight = theme.brightness == Brightness.light;

    // 1. Fixed Elements (Background + Lubber Line)
    
    // Glass backing disc with inner glow
    final bgPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [
          theme.colorScheme.surface.withValues(alpha: isLight ? 0.95 : 0.8),
          theme.colorScheme.surface.withValues(alpha: isLight ? 0.6 : 0.4),
        ],
      );
    canvas.drawCircle(center, radius, bgPaint);

    final outerRingPaint = Paint()
      ..color = theme.colorScheme.primary.withValues(alpha: isLight ? 0.25 : 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, outerRingPaint);

    // Fixed Lubber Line (Top indicator)
    final lubberPaint = Paint()
      ..color = isLight ? theme.colorScheme.secondary : const Color(0xFFFFD60A) // Warning Amber or secondary
      ..style = PaintingStyle.fill;
    final lubberPath = Path()
      ..moveTo(center.dx - 3, 2)
      ..lineTo(center.dx + 3, 2)
      ..lineTo(center.dx, 8)
      ..close();
    canvas.drawPath(lubberPath, lubberPaint);

    // 2. Rotating Elements (Dial + North Arrow)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * math.pi / 180); // Rotate entire dial
    canvas.translate(-center.dx, -center.dy);

    final dialPaint = Paint()
      ..color = theme.colorScheme.primary.withValues(alpha: isLight ? 0.8 : 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Cardinal Points + Degree Ticks
    for (var i = 0; i < 72; i++) {
      final angle = (i * 5) * math.pi / 180;
      final isCardinal = i % 18 == 0; // 0, 90, 180, 270
      final isMajor = i % 6 == 0; // Every 30 degrees
      
      final tickLen = isCardinal ? 8.0 : (isMajor ? 5.0 : 3.0);
      dialPaint.color = isCardinal 
          ? theme.colorScheme.primary 
          : theme.colorScheme.primary.withValues(alpha: 0.3);
      
      final inner = center + Offset(math.sin(angle) * (radius - tickLen), -math.cos(angle) * (radius - tickLen));
      final outer = center + Offset(math.sin(angle) * radius, -math.cos(angle) * radius);
      canvas.drawLine(inner, outer, dialPaint);

      if (isCardinal) {
        final label = const ['N', 'E', 'S', 'W'][i ~/ 18];
        _drawLabel(canvas, center, angle, radius - 18, label, 11, true);
      } else if (isMajor) {
        final degrees = (i * 5).toString();
        _drawLabel(canvas, center, angle, radius - 15, degrees, 7, false);
      }
    }

    // High Vis North Arrow (fixed to the dial's North position)
    final needlePaint = Paint()
      ..color = AppColors.neonRed
      ..style = PaintingStyle.fill;
    final arrowPath = Path()
      ..moveTo(center.dx, center.dy - radius + 10)
      ..lineTo(center.dx - 5, center.dy - radius + 22)
      ..lineTo(center.dx + 5, center.dy - radius + 22)
      ..close();
    canvas.drawPath(arrowPath, needlePaint);

    canvas.restore();
  }

  void _drawLabel(
    Canvas canvas, 
    Offset center, 
    double angle, 
    double r, 
    String text, 
    double fontSize,
    bool isBold,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.orbitron(
          color: isBold 
              ? theme.colorScheme.onSurface 
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final pos = center + Offset(math.sin(angle) * r, -math.cos(angle) * r);
    
    // Rotate text so it's always upright relative to the DIAL center
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    // Note: if we want text always upright for the USER even when dial rotates, 
    // we would need to rotate it by +heading. But for premium feel, 
    // rotating with the dial is often more "mechanical" and consistent.
    // Let's keep it rotating with the dial for now as a "pro instrument" look.
    canvas.translate(-tp.width / 2, -tp.height / 2);
    tp.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.heading != heading;
}

