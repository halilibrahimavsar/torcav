import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/heatmap_bloc.dart';
import '../../../../core/theme/app_theme.dart';

/// A premium, rotating compass ring that reflects the real device heading.
/// Tapping it recalibrates the AR heading.
class HeatmapCompass extends StatelessWidget {
  final double size;

  const HeatmapCompass({
    this.size = 56,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, double>(
      selector: (s) => s.currentHeading,
      builder: (context, heading) {
        return GestureDetector(
          onTap: () => context.read<HeatmapBloc>().recalibrateHeading(),
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(painter: _CompassPainter(heading: heading)),
          ),
        );
      },
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({required this.heading});

  final double heading;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Glass backing disc with a deeper blur effect.
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.65);
    canvas.drawCircle(center, radius, bgPaint);

    // Outer glow/ring.
    final ringPaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, ringPaint);

    // Cardinal ticks.
    final tickPaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final isMajor = i % 3 == 0;
      final tickLen = isMajor ? 5.0 : 3.0;
      
      final inner = center +
          Offset(
            math.sin(angle) * (radius - tickLen),
            -math.cos(angle) * (radius - tickLen),
          );
      final outer = center + Offset(math.sin(angle) * radius, -math.cos(angle) * radius);
      canvas.drawLine(inner, outer, tickPaint);
    }

    // North indicator (rotates opposite to heading).
    final headingRad = -heading * math.pi / 180;
    final needlePaint = Paint()
      ..color = AppColors.neonRed
      ..style = PaintingStyle.fill;
      
    final path = Path()
      ..moveTo(
        center.dx + math.sin(headingRad) * (radius - 5),
        center.dy - math.cos(headingRad) * (radius - 5),
      )
      ..lineTo(
        center.dx + math.sin(headingRad + 0.35) * 6,
        center.dy - math.cos(headingRad + 0.35) * 6,
      )
      ..lineTo(
        center.dx + math.sin(headingRad - 0.35) * 6,
        center.dy - math.cos(headingRad - 0.35) * 6,
      )
      ..close();
    canvas.drawPath(path, needlePaint);

    // "N" label (always at top of the ring, but rotates with heading relative to indicators).
    // Actually, usually N is fixed to the ring and the ring rotates, OR the needle rotates.
    // In our implementation, the NEEDLE rotates to show true North relative to phone screen top.
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'N',
        style: TextStyle(
          color: AppColors.neonCyan,
          fontSize: (size.width / 5.6).clamp(8.0, 12.0),
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    // We position 'N' just below the top edge of the circle.
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, 4));
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.heading != heading;
}
