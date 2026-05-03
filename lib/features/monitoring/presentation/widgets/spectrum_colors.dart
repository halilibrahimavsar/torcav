import 'package:flutter/material.dart';

import '../../../wifi_scan/domain/entities/wifi_band.dart';

/// Shared color helpers for the Spectrum / Channel feature. Keeping these in
/// one place means the rating bar chart, history line chart, hour-of-day
/// heatmap and the band chips on the page header all stay visually aligned.

const Color _band24Color = Color(0xFF00E5FF); // cyan
const Color _band5Color = Color(0xFF76FF03); // lime
const Color _band6Color = Color(0xFFEEFF41); // yellow

/// Per-band accent color used on chips, headers, and tab tints.
Color bandAccentColor(WifiBand band) => switch (band) {
  WifiBand.ghz24 => _band24Color,
  WifiBand.ghz5 => _band5Color,
  WifiBand.ghz6 => _band6Color,
};

/// Bar/line color for a channel rating score (0..10). Threshold-based: green
/// for clear (>=8), orange for marginal (>=5), red below.
Color ratingScoreColor(double rating, Color highColor) {
  if (rating >= 8) return highColor;
  if (rating >= 5) return Colors.orangeAccent;
  return Colors.redAccent;
}

/// Continuous heatmap color for a rating in [0..10]. The mid stop is theme
/// aware — the fluorescent yellow used in dark mode disappears on a white
/// background so we substitute a saturated orange for light mode.
Color ratingHeatmapColor(double rating, {required bool isDark}) {
  final t = (rating / 10).clamp(0.0, 1.0);
  const low = Color(0xFFFF1744);
  final mid = isDark ? const Color(0xFFEEFF41) : const Color(0xFFFF8F00);
  final high = isDark ? const Color(0xFF39FF14) : const Color(0xFF2E7D32);
  if (t < 0.5) return Color.lerp(low, mid, t * 2)!;
  return Color.lerp(mid, high, (t - 0.5) * 2)!;
}
