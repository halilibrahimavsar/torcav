import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:torcav/core/theme/neon_widgets.dart';
import '../../domain/entities/security_event.dart' as domain_event;

class SecurityTimelineView extends StatelessWidget {
  final List<domain_event.SecurityEvent> events;

  const SecurityTimelineView({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    if (events.isEmpty) {
      return GlassmorphicContainer(
        borderColor: scheme.outline.withValues(alpha: 0.2),
        backgroundColor: scheme.surface.withValues(alpha: 0.05),
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.history_toggle_off_rounded,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.noSecurityEvents,
                style: GoogleFonts.rajdhani(
                  color: scheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayEvents = events.reversed.take(15).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayEvents.length,
          itemBuilder: (context, index) {
            final event = displayEvents[index];
            final isLast = index == displayEvents.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Enhanced Timeline Column
                  SizedBox(
                    width: 24,
                    child: Column(
                      children: [
                        _TimelineDot(severity: event.severity),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 1.5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    _getSeverityColor(context, event.severity),
                                    scheme.outline.withValues(alpha: 0.1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Event Card
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SecurityEventCard(event: event, index: index),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TimelineDot extends StatelessWidget {
  final domain_event.SecurityEventSeverity severity;

  const _TimelineDot({required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(context, severity);
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

class SecurityEventCard extends StatelessWidget {
  final domain_event.SecurityEvent event;
  final int index;

  const SecurityEventCard({super.key, required this.event, required this.index});

  IconData get _icon {
    switch (event.type) {
      case domain_event.SecurityEventType.rogueApSuspected:
      case domain_event.SecurityEventType.evilTwinDetected:
        return Icons.warning_amber_rounded;
      case domain_event.SecurityEventType.deauthAttackSuspected:
      case domain_event.SecurityEventType.deauthBurstDetected:
        return Icons.wifi_off_rounded;
      case domain_event.SecurityEventType.encryptionDowngraded:
      case domain_event.SecurityEventType.handshakeCaptureStarted:
        return Icons.lock_open_rounded;
      case domain_event.SecurityEventType.handshakeCaptureCompleted:
        return Icons.lock_rounded;
      case domain_event.SecurityEventType.captivePortalDetected:
        return Icons.web_rounded;
      default:
        return Icons.security_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sevColor = _getSeverityColor(context, event.severity);
    final scheme = Theme.of(context).colorScheme;

    return StaggeredEntry(
      delay: Duration(milliseconds: 100 + (index * 50)),
      child: GlassmorphicContainer(
        borderColor: sevColor.withValues(alpha: 0.3),
        padding: const EdgeInsets.all(16),
        backgroundColor: sevColor.withValues(alpha: 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: sevColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(_icon, color: sevColor, size: 14),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NeonText(
                        l10n.securityEventType(event.type.name).toUpperCase(),
                        style: GoogleFonts.orbitron(
                          color: sevColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                        glowRadius: 4,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}:${event.timestamp.second.toString().padLeft(2, '0')} • LOG_ID: ${event.id.hashCode.toRadixString(16).toUpperCase()}',
                        style: GoogleFonts.firaCode(
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.onSurface.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: scheme.outline.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TARGET: ${event.ssid.isEmpty ? l10n.hiddenNetwork : event.ssid}',
                    style: GoogleFonts.rajdhani(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'BSSID: ${event.bssid}',
                    style: GoogleFonts.firaCode(
                      color: scheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.evidence,
                    style: GoogleFonts.rajdhani(
                      color: scheme.onSurface.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _getSeverityColor(BuildContext context, domain_event.SecurityEventSeverity severity) {
  final scheme = Theme.of(context).colorScheme;
  switch (severity) {
    case domain_event.SecurityEventSeverity.critical:
      return scheme.error;
    case domain_event.SecurityEventSeverity.high:
      return const Color(0xFFFFB300);
    case domain_event.SecurityEventSeverity.medium:
      return scheme.outline;
    case domain_event.SecurityEventSeverity.warning:
      return Colors.orange;
    default:
      return scheme.primary;
  }
}
