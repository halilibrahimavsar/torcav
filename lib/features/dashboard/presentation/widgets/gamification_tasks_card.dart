import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/neon_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../diagnostics/domain/entities/network_health_score.dart';

extension GamificationTaskX on GamificationTask {
  String localizedTitle(BuildContext context) {
    final l10n = context.l10n;
    switch (titleKey) {
      case 'harden_router':
        return l10n.hardenRouterTaskTitle;
      case 'enable_wpa3':
        return l10n.enableWpa3TaskTitle;
      case 'disable_wps':
        return l10n.disableWpsTaskTitle;
      case 'change_default_passwords':
        return l10n.changeDefaultPasswordsTaskTitle;
      case 'run_speed_test':
        return l10n.runSpeedTestTaskTitle;
      case 'optimize_channel':
        return l10n.optimizeChannelTaskTitle;
      default:
        return titleKey;
    }
  }

  String localizedDescription(BuildContext context) {
    final l10n = context.l10n;
    switch (titleKey) {
      case 'harden_router':
        return l10n.hardenRouterTaskDesc;
      case 'enable_wpa3':
        return l10n.enableWpa3TaskDesc;
      case 'disable_wps':
        return l10n.disableWpsTaskDesc;
      case 'change_default_passwords':
        return l10n.changeDefaultPasswordsTaskDesc;
      case 'run_speed_test':
        return l10n.runSpeedTestTaskDesc;
      case 'optimize_channel':
        return l10n.optimizeChannelTaskDesc;
      default:
        return '';
    }
  }

  String get severity {
    if (pointValue >= 20) return 'critical';
    if (pointValue >= 10) return 'high';
    return 'medium';
  }

  String get type {
    if (titleKey == 'run_speed_test' || titleKey == 'optimize_channel') {
      return 'performance';
    }
    return 'security';
  }
}

class GamificationTasksCard extends StatelessWidget {
  final List<GamificationTask> tasks;
  final void Function(GamificationTask) onTapTask;

  const GamificationTasksCard({
    super.key,
    required this.tasks,
    required this.onTapTask,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonSectionHeader(
          label: l10n.recommendedActionsTitle,
          color: scheme.tertiary,
          icon: Icons.task_alt_rounded,
        ),
        const SizedBox(height: 12),
        ...tasks.take(3).map((task) {
          final color = _severityColor(task.severity, scheme);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () => onTapTask(task),
              child: GlassmorphicContainer(
                borderColor: color.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        _taskIcon(task.type),
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.localizedTitle(context),
                            style: GoogleFonts.orbitron(
                              color: scheme.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task.localizedDescription(context),
                            style: GoogleFonts.rajdhani(
                              color: scheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        NeonText(
                          '+${task.pointValue}',
                          style: GoogleFonts.orbitron(
                            color: AppColors.neonCyan,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                          glowColor: AppColors.neonCyan,
                        ),
                        Text(
                          l10n.ptsLabel,
                          style: GoogleFonts.orbitron(
                            color: scheme.onSurfaceVariant,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Color _severityColor(String severity, ColorScheme scheme) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return scheme.error;
      case 'high':
        return Colors.orange;
      case 'medium':
        return const Color(0xFFFFB300);
      default:
        return AppColors.neonCyan;
    }
  }

  IconData _taskIcon(String type) {
    switch (type.toLowerCase()) {
      case 'security':
        return Icons.security_rounded;
      case 'performance':
        return Icons.speed_rounded;
      case 'configuration':
        return Icons.settings_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}
