import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/core/extensions/context_extensions.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import '../../domain/entities/network_context_type.dart';

/// Surfaces a short safe-use checklist when the connected network resolves to
/// a `public` or `guest` context. Plain-language: VPN, HTTPS, sensitive data,
/// DNS health.
class PublicWifiSafetyCard extends StatelessWidget {
  final NetworkContextType context;
  final VoidCallback? onRunDnsTest;

  const PublicWifiSafetyCard({
    super.key,
    required this.context,
    this.onRunDnsTest,
  });

  @override
  Widget build(BuildContext buildContext) {
    final scheme = Theme.of(buildContext).colorScheme;
    final isPublic = context == NetworkContextType.public;
    final accent = isPublic ? scheme.error : scheme.tertiary;
    final label = isPublic
        ? buildContext.l10n.publicWifiLabel
        : buildContext.l10n.guestNetworkLabel;
    final subtitle = isPublic
        ? buildContext.l10n.publicWifiDesc
        : buildContext.l10n.guestNetworkDesc;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: accent, size: 20),
              const SizedBox(width: 10),
              NeonText(
                label,
                style: GoogleFonts.orbitron(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.6,
                ),
                glowColor: accent,
                glowRadius: 5,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.rajdhani(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          _Tip(
            icon: Icons.vpn_lock_rounded,
            title: buildContext.l10n.tipVpnTitle,
            body: buildContext.l10n.tipVpnBody,
          ),
          _Tip(
            icon: Icons.lock_rounded,
            title: buildContext.l10n.tipHttpsTitle,
            body: buildContext.l10n.tipHttpsBody,
          ),
          _Tip(
            icon: Icons.no_accounts_rounded,
            title: buildContext.l10n.tipSensitiveTitle,
            body: buildContext.l10n.tipSensitiveBody,
          ),
          _Tip(
            icon: Icons.dns_rounded,
            title: buildContext.l10n.tipDnsTitle,
            body: buildContext.l10n.tipDnsBody,
            onTap: onRunDnsTest,
          ),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onTap;

  const _Tip({
    required this.icon,
    required this.title,
    required this.body,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final actionable = onTap != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.orbitron(
                        color: scheme.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: GoogleFonts.rajdhani(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (actionable)
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.primary.withValues(alpha: 0.6),
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
