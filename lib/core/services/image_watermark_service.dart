import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ImageWatermarkService {
  /// Adds a Torcav watermark and a gradient overlay to the provided [sourceImage].
  /// Returns the composite image as a [ui.Image].
  Future<ui.Image> addWatermark(
    ui.Image sourceImage, {
    required String titleText,
    required String subtitleText,
  }) async {
    final width = sourceImage.width.toDouble();
    final height = sourceImage.height.toDouble();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    // 1. Draw the original image
    final paint = Paint();
    canvas.drawImage(sourceImage, Offset.zero, paint);

    // 2. Draw a dark gradient overlay at the bottom for readability
    final gradientHeight = height * 0.35;
    final gradientRect = Rect.fromLTWH(
      0,
      height - gradientHeight,
      width,
      gradientHeight,
    );
    final gradientPaint =
        Paint()
          ..shader = ui.Gradient.linear(
            gradientRect.topCenter,
            gradientRect.bottomCenter,
            [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.8),
              Colors.black,
            ],
          );
    canvas.drawRect(gradientRect, gradientPaint);

    // 3. Draw the texts
    final titleStyle = TextStyle(
      color: Colors.white,
      fontSize: width * 0.04,
      fontWeight: FontWeight.bold,
      fontFamily: 'Orbitron',
      shadows: [
        Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4),
      ],
    );

    final subtitleStyle = TextStyle(
      color: Colors.white70,
      fontSize: width * 0.025,
      fontFamily: 'Outfit',
      shadows: [
        Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4),
      ],
    );

    final titlePainter =
        TextPainter(
          text: TextSpan(text: titleText, style: titleStyle),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: width * 0.9);

    final subtitlePainter =
        TextPainter(
          text: TextSpan(text: subtitleText, style: subtitleStyle),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: width * 0.9);

    final marginX = width * 0.05;
    final marginY = height * 0.05;

    // Draw bottom-left: Title and Subtitle
    final titleY =
        height - marginY - subtitlePainter.height - titlePainter.height - 4;
    titlePainter.paint(canvas, Offset(marginX, titleY));

    final subtitleY = height - marginY - subtitlePainter.height;
    subtitlePainter.paint(canvas, Offset(marginX, subtitleY));

    // Draw Torcav LOGO in bottom-right
    final logoStyle = TextStyle(
      color: const Color(0xFF00FFFF), // AppColors.neonCyan
      fontSize: width * 0.05,
      fontWeight: FontWeight.w900,
      fontFamily: 'Orbitron',
      letterSpacing: 2.0,
      shadows: [
        Shadow(
          color: const Color(0xFF00FFFF).withValues(alpha: 0.5),
          blurRadius: 8,
        ),
      ],
    );

    final logoPainter =
        TextPainter(
          text: TextSpan(text: 'TORCAV', style: logoStyle),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: width * 0.4);

    final logoX = width - marginX - logoPainter.width;
    final logoY = height - marginY - logoPainter.height;
    logoPainter.paint(canvas, Offset(logoX, logoY));

    // Finish recording
    final picture = recorder.endRecording();
    return picture.toImage(width.toInt(), height.toInt());
  }
}
