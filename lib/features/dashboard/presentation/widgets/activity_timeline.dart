import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../security/domain/entities/security_event.dart';
import '../../../wifi_scan/domain/entities/scan_snapshot.dart';

/// Horizontal scrolling timeline mixing recent scan snapshots and security
/// events. Each card uses the page offset to drive a parallax background
/// icon, so swiping feels alive.
class ActivityTimeline extends StatefulWidget {
  final List<ScanSnapshot> snapshots;
  final List<SecurityEvent> events;
  final void Function(String destination) onNavigate;

  const ActivityTimeline({
    super.key,
    required this.snapshots,
    required this.events,
    required this.onNavigate,
  });

  @override
  State<ActivityTimeline> createState() => _ActivityTimelineState();
}

class _ActivityTimelineState extends State<ActivityTimeline> {
  late final PageController _controller;
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.78);
    _controller.addListener(() {
      setState(() => _page = _controller.page ?? 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_TimelineItem> _buildItems(AppLocalizations l10n) {
    final items = <_TimelineItem>[];
    for (final s in widget.snapshots.take(6)) {
      items.add(_TimelineItem.scan(s, l10n));
    }
    for (final e in widget.events.take(8)) {
      items.add(_TimelineItem.event(e, l10n));
    }
    items.sort((a, b) => b.when.compareTo(a.when));
    return items.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = _buildItems(l10n);
    if (items.isEmpty) {
      return _EmptyTimeline(
        onScan: () => widget.onNavigate('wifi'),
      );
    }

    return SizedBox(
      height: 140,
      child: PageView.builder(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final delta = (i - _page).abs().clamp(0.0, 1.0);
          final scale = 1 - (delta * 0.06);
          final parallax = (i - _page) * 18;
          return Transform.scale(
            scale: scale,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _TimelineCard(
                item: items[i],
                parallax: parallax,
                onTap: () => widget.onNavigate(items[i].destination),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimelineItem {
  final DateTime when;
  final IconData icon;
  final Color accent;
  final String headline;
  final String subline;
  final String destination;

  _TimelineItem({
    required this.when,
    required this.icon,
    required this.accent,
    required this.headline,
    required this.subline,
    required this.destination,
  });

  factory _TimelineItem.scan(ScanSnapshot s, AppLocalizations l10n) {
    return _TimelineItem(
      when: s.timestamp,
      icon: Icons.radar_rounded,
      accent: AppColors.neonCyan,
      headline: l10n.networksCount(s.networks.length),
      subline: l10n.scanVia(s.backendUsed),
      destination: 'wifi',
    );
  }

  factory _TimelineItem.event(SecurityEvent e, AppLocalizations l10n) {
    final color = switch (e.severity) {
      SecurityEventSeverity.critical => AppColors.neonRed,
      SecurityEventSeverity.high => AppColors.neonOrange,
      SecurityEventSeverity.medium => const Color(0xFFFFB300),
      SecurityEventSeverity.warning => const Color(0xFFFFB300),
      SecurityEventSeverity.low => AppColors.neonCyan,
      SecurityEventSeverity.info => AppColors.neonCyan,
    };
    return _TimelineItem(
      when: e.timestamp,
      icon: Icons.warning_amber_rounded,
      accent: color,
      headline: _eventTitle(e.type, l10n),
      subline: e.ssid.isNotEmpty ? e.ssid : e.bssid,
      destination: 'security',
    );
  }

  static String _eventTitle(SecurityEventType t, AppLocalizations l10n) {
    switch (t) {
      case SecurityEventType.rogueApSuspected:
        return l10n.rogueApSuspected;
      case SecurityEventType.deauthBurstDetected:
      case SecurityEventType.deauthAttackSuspected:
        return l10n.deauthActivity;
      case SecurityEventType.handshakeCaptureStarted:
        return l10n.handshakeCaptureStarted;
      case SecurityEventType.handshakeCaptureCompleted:
        return l10n.handshakeCaptured;
      case SecurityEventType.captivePortalDetected:
        return l10n.captivePortal;
      case SecurityEventType.evilTwinDetected:
        return l10n.evilTwinDetected;
      case SecurityEventType.encryptionDowngraded:
        return l10n.encryptionDowngrade;
      case SecurityEventType.unsupportedOperation:
        return l10n.unsupportedOp;
      case SecurityEventType.arpSpoofingDetected:
        return l10n.arpSpoofing;
      case SecurityEventType.dnsHijackingDetected:
        return l10n.dnsHijacking;
    }
  }
}

class _TimelineCard extends StatelessWidget {
  final _TimelineItem item;
  final double parallax;
  final VoidCallback onTap;

  const _TimelineCard({
    required this.item,
    required this.parallax,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        borderColor: item.accent.withValues(alpha: 0.35),
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned(
                right: -30 + parallax,
                top: -20,
                child: Icon(
                  item.icon,
                  size: 130,
                  color: item.accent.withValues(alpha: 0.06),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.accent.withValues(alpha: 0.15),
                            border: Border.all(
                              color: item.accent.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Icon(item.icon,
                              color: item.accent, size: 14),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formatRelative(item.when, AppLocalizations.of(context)!),
                            style: GoogleFonts.orbitron(
                              color: item.accent.withValues(alpha: 0.9),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      item.headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rajdhani(
                        color: scheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rajdhani(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
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

  String _formatRelative(DateTime t, AppLocalizations l10n) {
    final diff = DateTime.now().difference(t);
    if (diff.isNegative) return l10n.justNow;
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
    return l10n.daysAgo(diff.inDays);
  }
}

class _EmptyTimeline extends StatelessWidget {
  final VoidCallback onScan;
  const _EmptyTimeline({required this.onScan});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onScan,
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(20),
        borderColor: scheme.primary.withValues(alpha: 0.2),
        child: Row(
          children: [
            Icon(Icons.history_rounded,
                color: scheme.primary.withValues(alpha: 0.6), size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.noActivityYet,
                    style: GoogleFonts.orbitron(
                      color: scheme.primary.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.runFirstScanDesc,
                    style: GoogleFonts.rajdhani(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: scheme.primary.withValues(alpha: 0.5), size: 14),
          ],
        ),
      ),
    );
  }
}
