import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../domain/entities/scan_snapshot.dart';
import '../../domain/entities/wifi_network.dart';
import '../../domain/entities/wifi_band.dart';
import 'wifi_scanner_radar.dart';

class WifiBentoHeader extends StatelessWidget {
  final ScanSnapshot snapshot;
  final bool isRefreshing;

  const WifiBentoHeader({
    super.key,
    required this.snapshot,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final double radarSize = constraints.maxWidth * 0.45;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: radarSize,
                  height: radarSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      WifiScannerRadar(isScanning: isRefreshing || true),
                      Icon(
                        isRefreshing
                            ? Icons.sync_rounded
                            : Icons.settings_input_antenna_rounded,
                        color: Theme.of(context).colorScheme.primary.withValues(
                          alpha: isRefreshing ? 0.8 : 0.5,
                        ),
                        size: 24,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: radarSize < 155 ? 155 : radarSize,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: BentoStatTile(
                                  label:
                                      AppLocalizations.of(
                                        context,
                                      )!.networksLabel,
                                  value: '${snapshot.networks.length}',
                                  icon: Icons.wifi_find_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: BentoStatTile(
                                  label:
                                      AppLocalizations.of(
                                        context,
                                      )!.securityLabel,
                                  value:
                                      '${snapshot.networks.where((n) => n.security != SecurityType.open).length}',
                                  icon: Icons.security_rounded,
                                  color: AppColors.neonGreen,
                                  subValue: AppLocalizations.of(
                                    context,
                                  )!.openCount(
                                    snapshot.networks
                                        .where(
                                          (n) =>
                                              n.security == SecurityType.open,
                                        )
                                        .length,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: BentoStatTile(
                                  label:
                                      AppLocalizations.of(
                                        context,
                                      )!.avgSignalLabel,
                                  value:
                                      snapshot.networks.isEmpty
                                          ? AppLocalizations.of(
                                            context,
                                          )!.notAvailable
                                          : '${(snapshot.networks.map((n) => n.avgSignalDbm).reduce((a, b) => a + b) / snapshot.networks.length).round()}',
                                  icon: Icons.signal_wifi_4_bar_rounded,
                                  color: AppColors.neonPurple,
                                  subValue:
                                      AppLocalizations.of(context)!.dbmCaps,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: BentoStatTile(
                                  label:
                                      AppLocalizations.of(
                                        context,
                                      )!.interfaceLabel,
                                  value: snapshot.interfaceName.toUpperCase(),
                                  icon: Icons.lan_rounded,
                                  color: AppColors.neonOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        if (snapshot.bandStats.isNotEmpty)
          SizedBox(
            height: 80,
            child: Row(
              children:
                  snapshot.bandStats.map((band) {
                    final isLast = snapshot.bandStats.last == band;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: isLast ? 0 : 8),
                        child: NeonCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          glowColor: _getBandColor(context, band.band),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                band.label,
                                style: GoogleFonts.orbitron(
                                  color: _getBandColor(context, band.band),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.networksCount(band.networkCount),
                                style: GoogleFonts.rajdhani(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
      ],
    );
  }

  Color _getBandColor(BuildContext context, WifiBand band) {
    return switch (band) {
      WifiBand.ghz24 => Theme.of(context).colorScheme.primary,
      WifiBand.ghz5 => AppColors.neonPurple,
      WifiBand.ghz6 => AppColors.neonGreen,
    };
  }
}
