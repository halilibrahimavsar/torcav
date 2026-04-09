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

/// Tier → accent color from the neon palette.
Color signalTierColor(SignalTier tier) {
  switch (tier) {
    case SignalTier.excellent:
      return AppColors.neonGreen;
    case SignalTier.good:
      return AppColors.neonCyan;
    case SignalTier.fair:
      return AppColors.neonYellow;
    case SignalTier.weak:
      return AppColors.neonOrange;
    case SignalTier.poor:
      return AppColors.neonRed;
  }
}

/// Smooth gradient version used for gauges/spheres where a binned tier
/// would look blocky. Red at -90 dBm → green at -35 dBm, clamped.
Color signalGradientColor(int rssi) {
  final normalized = ((rssi + 90) / 55).clamp(0.0, 1.0);
  return Color.lerp(
    const Color(0xFFFF3B30),
    const Color(0xFF00E676),
    normalized,
  )!;
}
