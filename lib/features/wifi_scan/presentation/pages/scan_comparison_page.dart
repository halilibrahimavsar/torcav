import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../domain/entities/wifi_observation.dart';
import '../../domain/services/scan_comparison_service.dart';
import '../../domain/services/scan_session_store.dart';

class ScanComparisonPage extends StatelessWidget {
  const ScanComparisonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = getIt<ScanSessionStore>();
    final all = store.all;

    if (all.length < 2) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'SCAN COMPARISON',
            style: GoogleFonts.orbitron(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 2,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'At least 2 scans are needed for comparison.\n\nRun another scan to see what changed.',
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ),
      );
    }

    final before = all[all.length - 2];
    final after = all[all.length - 1];
    final diff = ScanComparisonService().compare(before, after);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SCAN COMPARISON',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: diff.isEmpty
          ? Center(
              child: Text(
                'No changes detected between the last two scans.',
                style: GoogleFonts.rajdhani(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (diff.added.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'NEW (${diff.added.length})',
                    color: Theme.of(context).colorScheme.tertiary,
                    icon: Icons.add_circle_outline_rounded,
                  ),
                  ...diff.added.map(
                    (n) => _NetworkRow(
                      network: n,
                      accentColor: Theme.of(context).colorScheme.tertiary,
                      trailing: '+ NEW',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (diff.removed.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'GONE (${diff.removed.length})',
                    color: Theme.of(context).colorScheme.error,
                    icon: Icons.remove_circle_outline_rounded,
                  ),
                  ...diff.removed.map(
                    (n) => _NetworkRow(
                      network: n,
                      accentColor: Theme.of(context).colorScheme.error,
                      trailing: 'GONE',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (diff.changed.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'CHANGED (${diff.changed.length})',
                    color: Theme.of(context).colorScheme.primary,
                    icon: Icons.swap_horiz_rounded,
                  ),
                  ...diff.changed.map(
                    (c) => _ChangedRow(before: c.before, after: c.after),
                  ),
                ],
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _SectionHeader({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NeonSectionHeader(label: label, icon: icon, color: color),
    );
  }
}

class _NetworkRow extends StatelessWidget {
  final WifiObservation network;
  final Color accentColor;
  final String trailing;

  const _NetworkRow({
    required this.network,
    required this.accentColor,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  network.ssid.isEmpty ? '[Hidden]' : network.ssid,
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
                Text(
                  network.bssid,
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            trailing,
            style: GoogleFonts.orbitron(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangedRow extends StatelessWidget {
  final WifiObservation before;
  final WifiObservation after;

  const _ChangedRow({required this.before, required this.after});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final delta = after.avgSignalDbm - before.avgSignalDbm;
    final deltaStr = delta > 0 ? '+$delta dBm' : '$delta dBm';
    final deltaColor = delta > 0
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  before.ssid.isEmpty ? '[Hidden]' : before.ssid,
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
                Text(
                  '${before.avgSignalDbm} dBm → ${after.avgSignalDbm} dBm',
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            deltaStr,
            style: GoogleFonts.orbitron(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: deltaColor,
            ),
          ),
        ],
      ),
    );
  }
}
