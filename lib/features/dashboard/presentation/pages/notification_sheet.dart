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
      padding: const EdgeInsets.fromLTRB(24, 0, 12, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                'SECURITY ALERTS',
                style: GoogleFonts.orbitron(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            onPressed: () => Navigator.pop(context),
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
            child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
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
                    color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All systems clear',
                    style: GoogleFonts.rajdhani(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final event = state.notifications[index];
              return NotificationTile(event: event);
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.4,
            ),
          ),
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

   Color _getSeverityColor(BuildContext context, SecurityEventSeverity severity) {
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
        return 'HANDSHAKE CAPTURE';
      case SecurityEventType.handshakeCaptureCompleted:
        return 'HANDSHAKE SECURED';
      case SecurityEventType.captivePortalDetected:
        return 'CAPTIVE PORTAL';
      case SecurityEventType.unsupportedOperation:
        return 'UNSUPPORTED';
    }
  }
}
