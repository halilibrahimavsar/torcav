import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/features/heatmap/domain/services/signal_tier.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';

/// Left rail dBm gauge showing current RSSI and signal strength gradient.
class DbmGauge extends StatelessWidget {
  const DbmGauge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HeatmapBloc, HeatmapState, int?>(
      selector: (s) => s.currentRssi,
      builder: (context, rssi) {
        final tier = signalTierFor(rssi);
        final color = signalTierColor(tier);
        return SizedBox(
          width: 48,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                rssi == null ? '-- dBm' : '$rssi dBm',
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: CustomPaint(
                  painter: _GaugePainter(rssi: rssi),
                  size: Size.infinite,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'RSSI',
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.rssi});

  final int? rssi;

  @override
  void paint(Canvas canvas, Size size) {
    final trackRect = Rect.fromLTWH(size.width / 2 - 6, 0, 12, size.height);
    final rrect = RRect.fromRectAndRadius(trackRect, const Radius.circular(6));

    // Gradient background (red at bottom → green at top).
    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: const [
        Color(0xFFFF1744),
        Color(0xFFFF6E27),
        Color(0xFFEEFF41),
        Color(0xFF00F5FF),
        Color(0xFF39FF14),
      ],
    );
    canvas.drawRRect(rrect, Paint()..shader = gradient.createShader(trackRect));

    // Border.
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    if (rssi == null) return;

    // Tick marker.
    final normalized = ((rssi! + 90) / 55).clamp(0.0, 1.0);
    final tickY = size.height - size.height * normalized;
    final color = signalGradientColor(rssi!);
    final tickPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, tickY), 7, tickPaint);

    final glowPaint =
        Paint()
          ..color = color.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(size.width / 2, tickY), 10, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.rssi != rssi;
}
