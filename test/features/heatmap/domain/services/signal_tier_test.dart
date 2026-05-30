import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/features/heatmap/domain/services/signal_tier.dart';

void main() {
  group('signalTierFor', () {
    test('returns poor for null rssi', () {
      expect(signalTierFor(null), SignalTier.poor);
    });

    test('classifies the documented thresholds', () {
      expect(signalTierFor(-49), SignalTier.excellent);
      expect(signalTierFor(-50), SignalTier.excellent);
      expect(signalTierFor(-55), SignalTier.good);
      expect(signalTierFor(-60), SignalTier.good);
      expect(signalTierFor(-65), SignalTier.fair);
      expect(signalTierFor(-70), SignalTier.fair);
      expect(signalTierFor(-75), SignalTier.weak);
      expect(signalTierFor(-80), SignalTier.weak);
      expect(signalTierFor(-85), SignalTier.poor);
      expect(signalTierFor(-90), SignalTier.poor);
    });
  });

  group('signalTierLabel', () {
    test('returns the documented label for each tier', () {
      expect(signalTierLabel(SignalTier.excellent), 'Excellent');
      expect(signalTierLabel(SignalTier.good), 'Good');
      expect(signalTierLabel(SignalTier.fair), 'Fair');
      expect(signalTierLabel(SignalTier.weak), 'Weak');
      expect(signalTierLabel(SignalTier.poor), 'Poor');
    });
  });

  group('signalTierColor', () {
    test('returns the neon palette for dark brightness (default)', () {
      expect(
        signalTierColor(SignalTier.excellent),
        AppColors.neonGreen,
      );
      expect(signalTierColor(SignalTier.fair), AppColors.neonYellow);
      expect(signalTierColor(SignalTier.poor), AppColors.neonRed);
    });

    test('returns the ink palette for light brightness', () {
      expect(
        signalTierColor(SignalTier.excellent, Brightness.light),
        AppColors.inkGreen,
      );
      expect(
        signalTierColor(SignalTier.poor, Brightness.light),
        AppColors.inkRed,
      );
    });
  });

  group('signalGradientColor', () {
    test('clamps rssi below -90 to the low-end colour', () {
      final dark = signalGradientColor(-120);
      // Lower end colour: const Color(0xFFFF3B30) in dark theme.
      expect(dark.toARGB32(), const Color(0xFFFF3B30).toARGB32());
    });

    test('clamps rssi above -35 to the high-end colour', () {
      final dark = signalGradientColor(0);
      expect(dark.toARGB32(), const Color(0xFF00E676).toARGB32());
    });

    test('interpolates roughly mid-range for rssi around -62', () {
      // ((-62) + 90) / 55 ≈ 0.51
      final mid = signalGradientColor(-62);
      const low = Color(0xFFFF3B30);
      const high = Color(0xFF00E676);
      expect(mid.toARGB32(), isNot(low.toARGB32()));
      expect(mid.toARGB32(), isNot(high.toARGB32()));
    });

    test('honors brightness override', () {
      final light = signalGradientColor(-120, Brightness.light);
      expect(light.toARGB32(), AppColors.inkRed.toARGB32());
    });
  });
}
