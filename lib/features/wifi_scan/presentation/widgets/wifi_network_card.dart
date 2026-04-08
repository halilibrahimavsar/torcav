import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../domain/entities/wifi_network.dart';
import '../../domain/entities/wifi_observation.dart';
import '../../../../features/security/presentation/pages/wifi_details_page.dart';

class WifiNetworkCard extends StatelessWidget {
  final WifiObservation network;
  final String interfaceName;
  final bool isPinned;
  final VoidCallback onTogglePin;

  const WifiNetworkCard({
    super.key,
    required this.network,
    required this.interfaceName,
    required this.isPinned,
    required this.onTogglePin,
  });

  Color _getSignalColor(BuildContext context) {
    if (network.avgSignalDbm > -55) return AppColors.neonGreen;
    if (network.avgSignalDbm > -70) return Theme.of(context).colorScheme.primary;
    if (network.avgSignalDbm > -85) return AppColors.neonOrange;
    return AppColors.neonRed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final signalColor = _getSignalColor(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeonCard(
        glowColor: signalColor,
        glowIntensity: 0.08,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WifiDetailsPage(network: network.toWifiNetwork()),
            ),
          );
        },
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: signalColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: signalColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    Icon(Icons.wifi_rounded, color: signalColor, size: 20),
                    Positioned(
                      bottom: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(4, (index) {
                          final isActive =
                              (network.avgSignalDbm + 100) / 40 > (index / 4);
                          return Container(
                            width: 3,
                            height: 4 + (index * 2),
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              color: isActive
                                  ? signalColor
                                  : signalColor.withValues(alpha: 0.1),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: signalColor.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (network.ssid.isEmpty
                                ? l10n.hiddenNetwork
                                : network.ssid)
                            .toUpperCase(),
                        style: GoogleFonts.orbitron(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${network.vendor.toUpperCase()} • ${network.bssid}',
                        style: GoogleFonts.rajdhani(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: onTogglePin,
                      child: Icon(
                        isPinned ? Icons.star_rounded : Icons.star_border_rounded,
                        color: isPinned
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3),
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    NeonText(
                      '${network.avgSignalDbm}',
                      style: GoogleFonts.orbitron(
                        color: signalColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                      glowColor: signalColor,
                      glowRadius: 6,
                    ),
                    Text(
                      'dBm',
                      style: GoogleFonts.rajdhani(
                        color: signalColor.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              width: double.infinity,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MiniTechTag(
                  label: l10n.channelLabel(network.channel),
                  icon: Icons.tag_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                _MiniTechTag(
                  label: l10n.frequencyLabel(network.frequency),
                  icon: Icons.waves_rounded,
                  color: AppColors.neonPurple,
                ),
                const SizedBox(width: 8),
                _MiniTechTag(
                  label: network.security.name.toUpperCase(),
                  icon: switch (network.security) {
                    SecurityType.open => Icons.lock_open_rounded,
                    SecurityType.wep => Icons.lock_open_rounded,
                    _ => Icons.lock_rounded,
                  },
                  color: switch (network.security) {
                    SecurityType.wpa2 || SecurityType.wpa3 => AppColors.neonGreen,
                    SecurityType.wpa => Colors.amber,
                    _ => AppColors.neonRed,
                  },
                ),
                const Spacer(),
                Text(
                  'σ ${network.signalStdDev.toStringAsFixed(1)}',
                  style: GoogleFonts.rajdhani(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTechTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _MiniTechTag({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color.withValues(alpha: 0.8)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
