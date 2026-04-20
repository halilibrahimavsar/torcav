import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/core/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../core/theme/theme_cubit.dart';

class CyberDrawer extends StatelessWidget {
  final Function(String) onNavigate;

  const CyberDrawer({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: GlassmorphicContainer(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        padding: EdgeInsets.zero,
        blurSigma: 15,
        child: Column(
          children: [
            // ── Drawer Header: Agent Profile ──
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                Navigator.pop(context); // Close drawer
                onNavigate('profile');
              },
              borderRadius: BorderRadius.circular(16),
              child: _buildProfileSection(context),
            ),
            const SizedBox(height: 40),

            // ── System Status Section ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NeonSectionHeader(
                label: l10n.systemStatus,
                icon: Icons.monitor_heart_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusCard(context, l10n),
            const SizedBox(height: 32),

            // ── Theme Selection ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NeonSectionHeader(
                label: l10n.interfaceTheme,
                icon: Icons.palette_outlined,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            _buildThemeSelector(context),

            const Spacer(),

            // ── Actions Section ──
            Divider(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 12),
            _DrawerActionTile(
              icon: Icons.settings_outlined,
              label: l10n.settingsTitle,
              onTap: () {
                Navigator.pop(context);
                onNavigate('settings');
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.person_outline_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'AGENT-01',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: 2,
          ),
        ),
        Text(
          'CYBERNETIC_ID: 0x8FA2',
          style: GoogleFonts.shareTechMono(
            fontSize: 10,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, AppLocalizations l10n) {
    final color = Theme.of(context).colorScheme.tertiary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(16),
        borderColor: color.withValues(alpha: 0.2),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.verified_user_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.connectedStatusCaps,
                    style: GoogleFonts.orbitron(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    'Sub: Premium',
                    style: GoogleFonts.rajdhani(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
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

  Widget _buildThemeSelector(BuildContext context) {
    final themeCubit = GetIt.I<ThemeCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, currentMode) {
          return Row(
            children: [
              _ThemeOption(
                icon: Icons.light_mode_outlined,
                isSelected: currentMode == ThemeMode.light,
                onTap: () => themeCubit.setTheme(ThemeMode.light),
              ),
              const SizedBox(width: 12),
              _ThemeOption(
                icon: Icons.dark_mode_outlined,
                isSelected: currentMode == ThemeMode.dark,
                onTap: () => themeCubit.setTheme(ThemeMode.dark),
              ),
              const SizedBox(width: 12),
              _ThemeOption(
                icon: Icons.settings_brightness_outlined,
                isSelected: currentMode == ThemeMode.system,
                onTap: () => themeCubit.setTheme(ThemeMode.system),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.outline;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: isSelected ? 0.8 : 0.2),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? color.withValues(alpha: 0.1) : null,
          ),
          child: Icon(icon, color: color),
        ),
      ),
    );
  }
}

class _DrawerActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: Tooltip(
        message: label,
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }
}
