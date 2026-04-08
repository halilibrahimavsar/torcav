import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/neon_widgets.dart';

class ScanModeToggle extends StatelessWidget {
  final bool quickScan;
  final ValueChanged<bool> onChanged;

  const ScanModeToggle({
    super.key,
    required this.quickScan,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        _ModeButton(
          label: AppLocalizations.of(context)!.quickScan,
          icon: Icons.flash_on_rounded,
          selected: quickScan,
          color: Theme.of(context).colorScheme.tertiary,
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: 8),
        _ModeButton(
          label: AppLocalizations.of(context)!.deepScan,
          icon: Icons.radar_rounded,
          selected: !quickScan,
          color: primary,
          onTap: () => onChanged(false),
        ),
        const SizedBox(width: 8),
        InfoIconButton(
          title: AppLocalizations.of(context)!.scanModesTitle,
          body: AppLocalizations.of(context)!.scanModesInfo,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.7)
                : color.withValues(alpha: 0.2),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? color : color.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                color: selected ? color : color.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
