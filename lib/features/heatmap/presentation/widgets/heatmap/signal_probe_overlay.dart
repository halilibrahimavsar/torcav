import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import 'package:torcav/features/heatmap/domain/entities/heatmap_point.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap/heatmap_page_models.dart';
import 'package:torcav/features/heatmap/presentation/widgets/heatmap/heatmap_utility_widgets.dart';

class SignalProbeOverlay extends StatelessWidget {
  const SignalProbeOverlay({
    super.key,
    required this.point,
    required this.onDismiss,
    required this.copy,
  });

  final HeatmapPoint? point;
  final VoidCallback onDismiss;
  final HeatmapCopy copy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    if (point == null) {
      return Positioned(
        left: 20,
        right: 20,
        bottom: 120,
        child: InfoBanner(
          color: AppColors.neonOrange,
          icon: Icons.search_off_rounded,
          title: 'NO DATA AT THIS LOCATION',
          body: 'Try tapping closer to a captured signal point.',
        ),
      );
    }

    final p = point!;
    final rssi = p.rssi;
    final color = _signalColor(rssi);

    final statusLabel =
        rssi > -60
            ? 'OPTIMAL'
            : rssi > -75
            ? 'FAIR'
            : 'CRITICAL';
    final statusColor =
        rssi > -60
            ? AppColors.neonGreen
            : rssi > -75
            ? AppColors.neonOrange
            : AppColors.neonRed;

    final apName = (p.ssid.isNotEmpty) ? p.ssid : p.bssid;
    final timeLabel = DateFormat('HH:mm:ss').format(p.timestamp);
    final posLabel =
        'X ${p.floorX.toStringAsFixed(1)} m  ·  Y ${p.floorY.toStringAsFixed(1)} m';
    final samplesLabel =
        '${p.sampleCount} samples  ·  ±${p.rssiStdDev.toStringAsFixed(1)} dBm';

    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color:
                  isLight
                      ? theme.colorScheme.scrim.withValues(alpha: 0.12)
                      : theme.colorScheme.scrim.withValues(alpha: 0.4),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: StaggeredEntry(
                duration: const Duration(milliseconds: 400),
                child: GlassmorphicContainer(
                  borderRadius: BorderRadius.circular(28),
                  borderColor: color.withValues(alpha: isLight ? 0.4 : 1.0),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Header ──────────────────────────────────────────
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.analytics_rounded,
                              color: color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SIGNAL PROBE',
                                  style: GoogleFonts.orbitron(
                                    color: color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                if (apName.isNotEmpty)
                                  Text(
                                    apName.toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: isLight ? 0.6 : 0.45,
                              ),
                            ),
                            onPressed: onDismiss,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Primary stats row ────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: StatBrick(
                              label: 'RSSI',
                              value: '$rssi dBm',
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatBrick(
                              label: 'STATUS',
                              value: statusLabel,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatBrick(
                              label: 'FLOOR',
                              value: '${p.floor}',
                              color: AppColors.neonBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ── Detail rows ──────────────────────────────────────
                      ProbeDetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'POSITION',
                        value: posLabel,
                      ),
                      const SizedBox(height: 6),
                      ProbeDetailRow(
                        icon: Icons.wifi_outlined,
                        label: 'SAMPLES',
                        value: samplesLabel,
                      ),
                      const SizedBox(height: 6),
                      ProbeDetailRow(
                        icon: Icons.schedule_outlined,
                        label: 'CAPTURED',
                        value: timeLabel,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _signalColor(int rssi) {
    if (rssi > -50) return AppColors.neonGreen;
    if (rssi > -65) return const Color(0xFFC6FF00); // Lime
    if (rssi > -75) return AppColors.neonOrange;
    return AppColors.neonRed;
  }
}

class ProbeDetailRow extends StatelessWidget {
  const ProbeDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 13,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.orbitron(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 9,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.outfit(
              color: theme.colorScheme.onSurface,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
