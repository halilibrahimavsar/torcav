import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../extensions/context_extensions.dart';

/// Battery-optimization exemption flow for the two features whose value is
/// delivered while the app is closed: background monitoring (WorkManager)
/// and the ping stabilizer's native alert engine. OEM battery managers
/// (MIUI, One UI, …) throttle or kill both unless the app is exempt.
///
/// Play-policy note: `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` is acceptable
/// when core, user-facing functionality is adversely affected — which is
/// exactly these opt-in features — and we always show a disclosure dialog
/// before the system prompt.
class BatteryOptimization {
  const BatteryOptimization._();

  /// True when already exempt, or when the concept doesn't apply
  /// (non-Android platforms, web).
  static Future<bool> isExempt() async {
    if (kIsWeb || !Platform.isAndroid) return true;
    final status = await Permission.ignoreBatteryOptimizations.status;
    return status.isGranted;
  }

  /// Shows a disclosure dialog and, when accepted, the system exemption
  /// prompt. No-op when already exempt or not applicable. Safe to call on
  /// every feature activation — it only ever surfaces UI when needed.
  static Future<void> ensureExemption(BuildContext context) async {
    if (await isExempt()) return;
    if (!context.mounted) return;

    final l10n = context.l10n;
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Theme.of(ctx).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              l10n.batteryOptimizationTitle,
              style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(ctx).colorScheme.primary,
              ),
            ),
            content: Text(
              l10n.batteryOptimizationBody,
              style: GoogleFonts.rajdhani(
                color: Theme.of(ctx).colorScheme.onSurface,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  l10n.batteryOptimizationLater,
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  l10n.batteryOptimizationAction,
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    color: Theme.of(ctx).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );

    if (accepted == true) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }
}
