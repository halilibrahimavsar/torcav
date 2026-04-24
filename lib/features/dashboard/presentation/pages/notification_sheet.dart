import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../security/domain/entities/security_event.dart';
import '../../../security/presentation/bloc/notification/notification_bloc.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          _buildHandle(context),
          _buildHeader(context),
          NeonDivider(color: Theme.of(context).colorScheme.primary),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'SECURITY ALERTS',
                  style: GoogleFonts.orbitron(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is! NotificationLoaded || state.notifications.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(
                children: [
                  TextButton.icon(
                    onPressed:
                        () => context.read<NotificationBloc>().add(
                          MarkAllNotificationsAsRead(),
                        ),
                    icon: Icon(
                      Icons.done_all_rounded,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(
                      'MARK ALL READ',
                      style: GoogleFonts.orbitron(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed:
                        () => context.read<NotificationBloc>().add(
                          ClearAllNotifications(),
                        ),
                    icon: Icon(
                      Icons.delete_sweep_rounded,
                      size: 14,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    label: Text(
                      'CLEAR ALL',
                      style: GoogleFonts.orbitron(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Events are retained for 30 days. Swipe left to dismiss.',
                style: GoogleFonts.rajdhani(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        if (state is NotificationLoaded) {
          if (state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security_update_good_rounded,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.tertiary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All systems clear',
                    style: GoogleFonts.rajdhani(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            itemCount: state.notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final event = state.notifications[index];
              if (event.id == null) return NotificationTile(event: event);
              return Dismissible(
                key: Key('notif_${event.id}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => context
                    .read<NotificationBloc>()
                    .add(DismissNotification(event.id!)),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                child: NotificationTile(event: event),
              );
            },
          );
        }

        if (state is NotificationError) {
          return Center(child: Text(state.message));
        }

        return const SizedBox();
      },
    );
  }
}

class NotificationTile extends StatelessWidget {
  final SecurityEvent event;

  const NotificationTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(context, event.severity);
    final isUnread = !event.isRead;

    return NeonCard(
      glowColor: color,
      glowIntensity: isUnread ? 0.15 : 0.05,
      padding: const EdgeInsets.all(16),
      onTap: () {
        if (isUnread && event.id != null) {
          context.read<NotificationBloc>().add(
            MarkNotificationAsRead(event.id!),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _getTypeIcon(event.type, color),
                  const SizedBox(width: 10),
                  Text(
                    _getTypeLabel(event.type),
                    style: GoogleFonts.orbitron(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Text(
                DateFormat('HH:mm').format(event.timestamp),
                style: GoogleFonts.rajdhani(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.ssid,
            style: GoogleFonts.rajdhani(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            event.evidence,
            style: GoogleFonts.outfit(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (_isHeuristicEvent(event.type)) ...[
            const SizedBox(height: 8),
            Text(
              'Heuristic detection — not a confirmed attack. False positives may occur in congested environments.',
              style: GoogleFonts.outfit(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.45),
                fontSize: 11,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
          if (isUnread) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'MARK AS READ',
                  style: GoogleFonts.orbitron(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _isHeuristicEvent(SecurityEventType type) {
    return type == SecurityEventType.deauthBurstDetected ||
        type == SecurityEventType.deauthAttackSuspected ||
        type == SecurityEventType.arpSpoofingDetected ||
        type == SecurityEventType.evilTwinDetected ||
        type == SecurityEventType.rogueApSuspected;
  }

  Color _getSeverityColor(
    BuildContext context,
    SecurityEventSeverity severity,
  ) {
    switch (severity) {
      case SecurityEventSeverity.critical:
        return AppColors.neonRed;
      case SecurityEventSeverity.high:
        return Colors.orangeAccent;
      case SecurityEventSeverity.medium:
        return Theme.of(context).colorScheme.primary;
      case SecurityEventSeverity.low:
        return Theme.of(context).colorScheme.tertiary;
      case SecurityEventSeverity.info:
        return Theme.of(context).colorScheme.tertiary;
      case SecurityEventSeverity.warning:
        return Colors.yellowAccent;
    }
  }

  Widget _getTypeIcon(SecurityEventType type, Color color) {
    IconData icon;
    switch (type) {
      case SecurityEventType.rogueApSuspected:
        icon = Icons.wifi_off_rounded;
      case SecurityEventType.evilTwinDetected:
        icon = Icons.copy_rounded;
      case SecurityEventType.deauthAttackSuspected:
        icon = Icons.radar_rounded;
      case SecurityEventType.encryptionDowngraded:
        icon = Icons.lock_open_rounded;
      case SecurityEventType.deauthBurstDetected:
        icon = Icons.warning_amber_rounded;
      case SecurityEventType.handshakeCaptureStarted:
        icon = Icons.vpn_key_rounded;
      case SecurityEventType.handshakeCaptureCompleted:
        icon = Icons.key_rounded;
      case SecurityEventType.captivePortalDetected:
        icon = Icons.web_rounded;
      case SecurityEventType.unsupportedOperation:
        icon = Icons.error_outline_rounded;
      case SecurityEventType.arpSpoofingDetected:
        icon = Icons.security_rounded;
      case SecurityEventType.dnsHijackingDetected:
        icon = Icons.travel_explore_rounded;
    }
    return Icon(icon, color: color, size: 16);
  }

  String _getTypeLabel(SecurityEventType type) {
    switch (type) {
      case SecurityEventType.rogueApSuspected:
        return 'ROGUE AP';
      case SecurityEventType.evilTwinDetected:
        return 'EVIL TWIN';
      case SecurityEventType.deauthAttackSuspected:
        return 'DEAUTH ATTACK';
      case SecurityEventType.encryptionDowngraded:
        return 'ENCRYPTION WEAKENED';
      case SecurityEventType.deauthBurstDetected:
        return 'DEAUTH BURST';
      case SecurityEventType.handshakeCaptureStarted:
        return 'HANDSHAKE ANALYSIS';
      case SecurityEventType.handshakeCaptureCompleted:
        return 'HANDSHAKE SECURED';
      case SecurityEventType.captivePortalDetected:
        return 'CAPTIVE PORTAL';
      case SecurityEventType.unsupportedOperation:
        return 'UNSUPPORTED';
      case SecurityEventType.arpSpoofingDetected:
        return 'ARP SPOOFING';
      case SecurityEventType.dnsHijackingDetected:
        return 'DNS HIJACKING';
    }
  }
}
