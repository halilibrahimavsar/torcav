import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/features/security/domain/entities/security_event.dart' as domain_event;
import '../bloc/security_bloc.dart';

class EvilTwinAlertBanner extends StatelessWidget {
  final SecurityLoaded state;
  const EvilTwinAlertBanner({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final hasEvilTwin = state.recentEvents.any(
      (e) => e.type == domain_event.SecurityEventType.evilTwinDetected,
    );
    if (!hasEvilTwin) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final errorColor = Theme.of(context).colorScheme.error;

    return StaggeredEntry(
      delay: const Duration(milliseconds: 100),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: NeonCard(
          glowColor: errorColor,
          glowIntensity: 0.25,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: errorColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: errorColor.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: PulseAnimation(
                    color: errorColor,
                    child: Icon(
                      Icons.gpp_maybe_rounded,
                      color: errorColor,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        NeonText(
                          l10n.evilTwinAlertTitle.toUpperCase(),
                          style: GoogleFonts.orbitron(
                            color: errorColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                          glowColor: errorColor,
                          glowRadius: 8,
                        ),
                        const Spacer(),
                        _AlertBadge(
                          label: 'CRITICAL',
                          color: errorColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.evilTwinAlertBody,
                      style: GoogleFonts.rajdhani(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WpsWarningCard extends StatelessWidget {
  final SecurityLoaded state;
  const WpsWarningCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final wpsCount = state.scanSummary?.wpsCount ?? 0;
    if (wpsCount == 0) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    const warnColor = Color(0xFFFFB300);

    return StaggeredEntry(
      delay: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: NeonCard(
          glowColor: warnColor,
          glowIntensity: 0.15,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: warnColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: warnColor.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: PulseAnimation(
                  color: warnColor,
                  child: const Icon(
                    Icons.lock_open_rounded,
                    color: warnColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: NeonText(
                            l10n.wpsWarningTitle.toUpperCase(),
                            style: GoogleFonts.orbitron(
                              color: warnColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                            glowColor: warnColor,
                            glowRadius: 5,
                          ),
                        ),
                        _AlertBadge(
                          label: 'WPS ACTIVE',
                          color: warnColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.wpsWarningBody,
                      style: GoogleFonts.rajdhani(
                        color: warnColor.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _AlertBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.firaCode(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 9,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
