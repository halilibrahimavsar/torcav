import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/core/theme/app_theme.dart';
import 'package:torcav/features/heatmap/presentation/bloc/heatmap_bloc.dart';

/// Right rail button dock for control actions (recalibrate, auto-sample, flag, finish).
class HudDock extends StatelessWidget {
  const HudDock({
    super.key,
    required this.onFlagWeakZone,
    this.onFinish,
    this.onDiscard,
  });

  final VoidCallback? onFlagWeakZone;
  final VoidCallback? onFinish;
  final VoidCallback? onDiscard;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (onDiscard != null) ...[
          _DockButton(
            icon: Icons.delete_forever_rounded,
            tooltip: 'Discard Survey',
            color: AppColors.neonOrange,
            onTap: () async {
              // BUG-05: guard against stale context if the widget is removed
              // from the tree while this async gap is open.
              if (!context.mounted) return;
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: Colors.black.withValues(alpha: 0.9),
                      title: Text(
                        'DISCARD SURVEY?',
                        style: GoogleFonts.orbitron(
                          color: AppColors.neonOrange,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        'All recorded data for this session will be permanently deleted.',
                        style: GoogleFonts.outfit(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'CANCEL',
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'DISCARD',
                            style: GoogleFonts.orbitron(
                              color: AppColors.neonOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
              );
              if (confirm == true && context.mounted) {
                onDiscard?.call();
              }
            },
          ),
          const SizedBox(height: 10),
        ],
        if (onFlagWeakZone != null)
          _DockButton(
            icon: Icons.flag_rounded,
            tooltip: 'Flag weak zone',
            color: AppColors.neonOrange,
            onTap: onFlagWeakZone!,
          ),
        const SizedBox(height: 10),
        BlocSelector<HeatmapBloc, HeatmapState, bool>(
          selector: (s) => s.isAutoSampling,
          builder: (context, isAuto) {
            return _DockButton(
              icon: isAuto ? Icons.auto_mode_rounded : Icons.touch_app_rounded,
              tooltip: isAuto
                  ? 'Auto-sample ON — step to record'
                  : 'Manual — tap reticle to record',
              color: isAuto ? AppColors.neonGreen : Colors.white70,
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<HeatmapBloc>().toggleAutoSampling();
              },
            );
          },
        ),
        BlocSelector<HeatmapBloc, HeatmapState, bool>(
          selector: (s) {
            final pos = s.currentPosition;
            if (pos == null) return false;
            for (final wall in s.pendingWalls) {
              final cx = (wall.x1 + wall.x2) / 2 - pos.dx;
              final cy = (wall.y1 + wall.y2) / 2 - pos.dy;
              if (cx * cx + cy * cy < 6.25) return true;
            }
            return false;
          },
          builder: (context, hasWall) {
            if (!hasWall) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _DockButton(
                icon: Icons.architecture_rounded,
                tooltip: 'Commit Wall Segment',
                color: AppColors.neonYellow,
                onTap: () {
                  HapticFeedback.heavyImpact();
                  context.read<HeatmapBloc>().addNearestPendingWall();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Wall added manually'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.black87,
                    ),
                  );
                },
              ),
            );
          },
        ),
        if (onFinish != null) ...[
          const SizedBox(height: 10),
          _DockButton(
            icon: Icons.stop_rounded,
            tooltip: 'Finish & Review',
            color: AppColors.neonRed,
            onTap: onFinish!,
          ),
        ],
      ],
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.55)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
