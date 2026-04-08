import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import '../bloc/security_bloc.dart';
import '../../domain/entities/known_network.dart';
import '../../domain/entities/trusted_network_profile.dart';

class NetworkSecurityCard extends StatelessWidget {
  final List<KnownNetwork> knownNetworks;
  final List<TrustedNetworkProfile> trustedProfiles;

  const NetworkSecurityCard({
    super.key,
    required this.knownNetworks,
    required this.trustedProfiles,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return StaggeredEntry(
      delay: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (knownNetworks.isEmpty && trustedProfiles.isEmpty)
            NeonCard(
              glowColor: scheme.outline,
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  l10n.noIdentifiedNetworks,
                  style: GoogleFonts.rajdhani(
                    color: scheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else ...[
            ...knownNetworks.asMap().entries.map((entry) {
              final isTrusted = trustedProfiles.any((p) => p.bssid == entry.value.bssid);
              return NetworkCard(
                network: entry.value,
                isTrusted: isTrusted,
                index: entry.key,
              );
            }),
            if (knownNetworks.isNotEmpty && trustedProfiles.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: NeonDivider(height: 1),
              ),
            ...trustedProfiles.asMap().entries.map((entry) {
              return TrustedProfileCard(
                profile: entry.value,
                index: entry.key + knownNetworks.length,
              );
            }),
          ],
        ],
      ),
    );
  }
}

class NetworkCard extends StatelessWidget {
  final KnownNetwork network;
  final bool isTrusted;
  final int index;

  const NetworkCard({
    super.key,
    required this.network,
    required this.isTrusted,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activeColor = isTrusted ? scheme.tertiary : scheme.secondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: StaggeredEntry(
        delay: Duration(milliseconds: 100 + (index * 40)),
        child: NeonCard(
          glowColor: activeColor,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _NetworkIcon(activeColor: activeColor, isTrusted: isTrusted),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NeonText(
                      network.ssid.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                      glowRadius: isTrusted ? 6 : 0,
                      glowColor: activeColor,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'BSSID: ${network.bssid.toUpperCase()}',
                      style: GoogleFonts.firaCode(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (isTrusted)
                _StatusBadge(label: 'TRUSTED', color: scheme.tertiary)
              else
                _StatusBadge(label: 'IDENTIFIED', color: scheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

class TrustedProfileCard extends StatelessWidget {
  final TrustedNetworkProfile profile;
  final int index;

  const TrustedProfileCard({
    super.key,
    required this.profile,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tertiary = scheme.tertiary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: StaggeredEntry(
        delay: Duration(milliseconds: 100 + (index * 40)),
        child: NeonCard(
          glowColor: tertiary,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _NetworkIcon(activeColor: tertiary, isTrusted: true),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NeonText(
                      profile.ssid.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                      glowRadius: 8,
                      glowColor: tertiary,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AUTH: ESTABLISHED ${profile.trustedAt.day}.${profile.trustedAt.month}.${profile.trustedAt.year}',
                      style: GoogleFonts.rajdhani(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.read<SecurityBloc>().add(
                      SecurityUntrustRequested(profile.bssid),
                    ),
                icon: Icon(
                  Icons.delete_sweep_rounded,
                  size: 20,
                  color: scheme.error.withValues(alpha: 0.8),
                ),
                tooltip: 'REVOKE TRUST',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkIcon extends StatelessWidget {
  final Color activeColor;
  final bool isTrusted;

  const _NetworkIcon({required this.activeColor, required this.isTrusted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: activeColor.withValues(alpha: 0.1),
        border: Border.all(color: activeColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          if (isTrusted)
            BoxShadow(
              color: activeColor.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Icon(
        isTrusted ? Icons.verified_user_rounded : Icons.wifi_find_rounded,
        color: activeColor,
        size: 20,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.orbitron(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
