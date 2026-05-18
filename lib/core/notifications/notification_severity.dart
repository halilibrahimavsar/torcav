import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/theme/app_theme.dart';

/// Severity classifier for [AppNotifier] snackbars. Drives background color,
/// default duration, and icon. Kept as an enum (not a class) so it can be used
/// in switch expressions without boilerplate.
enum NotificationSeverity { error, warning, success, info }

extension NotificationSeverityX on NotificationSeverity {
  Color backgroundColor() => switch (this) {
    NotificationSeverity.error => AppColors.neonRed.withValues(alpha: 0.92),
    NotificationSeverity.warning =>
      AppColors.neonOrange.withValues(alpha: 0.92),
    NotificationSeverity.success =>
      AppColors.neonGreen.withValues(alpha: 0.92),
    NotificationSeverity.info => AppColors.neonCyan.withValues(alpha: 0.92),
  };

  Duration defaultDuration() => switch (this) {
    NotificationSeverity.error => const Duration(seconds: 6),
    NotificationSeverity.warning => const Duration(seconds: 4),
    NotificationSeverity.success => const Duration(seconds: 3),
    NotificationSeverity.info => const Duration(seconds: 3),
  };

  IconData icon() => switch (this) {
    NotificationSeverity.error => Icons.error_outline,
    NotificationSeverity.warning => Icons.warning_amber_rounded,
    NotificationSeverity.success => Icons.check_circle_outline,
    NotificationSeverity.info => Icons.info_outline,
  };

  TextStyle textStyle() => GoogleFonts.rajdhani(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    letterSpacing: 0.3,
  );
}
