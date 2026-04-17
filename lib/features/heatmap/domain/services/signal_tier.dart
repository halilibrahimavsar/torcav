import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Discrete RSSI quality tiers used by the AR HUD and any guidance copy.
///
/// Thresholds (dBm):
///   excellent ≥ -50
///   good      ≥ -60
///   fair      ≥ -70
///   weak      ≥ -80
///   poor      < -80
enum SignalTier { excellent, good, fair, weak, poor }

/// Maps a raw RSSI reading to a [SignalTier]. A null reading returns [SignalTier.poor]
/// so callers can safely render a disabled/empty state without special-casing.
SignalTier signalTierFor(int? rssi) {
  if (rssi == null) return SignalTier.poor;
  if (rssi >= -50) return SignalTier.excellent;
  if (rssi >= -60) return SignalTier.good;
  if (rssi >= -70) return SignalTier.fair;
  if (rssi >= -80) return SignalTier.weak;
  return SignalTier.poor;
}

/// Short human-readable label for a tier.
String signalTierLabel(SignalTier tier) {
  switch (tier) {
    case SignalTier.excellent:
      return 'Excellent';
    case SignalTier.good:
      return 'Good';
    case SignalTier.fair:
      return 'Fair';
    case SignalTier.weak:
      return 'Weak';
    case SignalTier.poor:
      return 'Poor';
  }
}

/// Tier → accent color. Supports both dark (neon) and light (ink) themes.
Color signalTierColor(SignalTier tier, [Brightness brightness = Brightness.dark]) {
  final isLight = brightness == Brightness.light;
  switch (tier) {
    case SignalTier.excellent:
      return isLight ? AppColors.inkGreen : AppColors.neonGreen;
    case SignalTier.good:
      return isLight ? AppColors.inkCyan : AppColors.neonCyan;
    case SignalTier.fair:
      return isLight ? AppColors.inkYellow : AppColors.neonYellow;
    case SignalTier.weak:
      return isLight ? AppColors.inkOrange : AppColors.neonOrange;
    case SignalTier.poor:
      return isLight ? AppColors.inkRed : AppColors.neonRed;
  }
}

/// Smooth gradient version used for gauges/spheres.
/// Now theme-aware to ensure visibility against light/dark backgrounds.
Color signalGradientColor(int rssi, [Brightness brightness = Brightness.dark]) {
  final normalized = ((rssi + 90) / 55).clamp(0.0, 1.0);
  final isLight = brightness == Brightness.light;

  final lowColor = isLight ? AppColors.inkRed : const Color(0xFFFF3B30);
  final highColor = isLight ? AppColors.inkGreen : const Color(0xFF00E676);

  return Color.lerp(lowColor, highColor, normalized)!;
}

