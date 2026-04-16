import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torcav/core/theme/app_theme.dart';

/// Right rail button dock for control actions (discard, finish).
class HudDock extends StatelessWidget {
  const HudDock({
    super.key,
    this.onFinish,
    this.onDiscard,
  });

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
              if (!context.mounted) return;
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
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
        if (onFinish != null)
          _DockButton(
            icon: Icons.stop_rounded,
            tooltip: 'Finish & Review',
            color: AppColors.neonRed,
            onTap: onFinish!,
          ),
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
