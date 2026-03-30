import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';

class CyberDrawer extends StatelessWidget {
  final Function(String) onNavigate;

  const CyberDrawer({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: AppColors.darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: AppColors.neonCyan.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
        ),
        child: Column(
          children: [
            // ── Drawer Header: Agent Profile ──
            const SizedBox(height: 60),
            InkWell(
              onTap: () {
                Navigator.pop(context); // Close drawer
                onNavigate('profile');
              },
              borderRadius: BorderRadius.circular(16),
              child: _buildProfileSection(),
            ),
            const SizedBox(height: 40),

            // ── System Status Section ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NeonSectionHeader(
                label: l10n.systemStatus,
                icon: Icons.monitor_heart_rounded,
                color: AppColors.neonCyan,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusCard(l10n),

            const Spacer(),

            // ── Actions Section ──
            const Divider(color: Colors.white10),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: CircleAvatar(
              backgroundColor: AppColors.darkSurface,
              child: Icon(
                Icons.person_outline_rounded,
                size: 40,
                color: AppColors.neonCyan,
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
            color: AppColors.textPrimary,
            letterSpacing: 2,
          ),
        ),
        Text(
          'CYBERNETIC_ID: 0x8FA2',
          style: GoogleFonts.shareTechMono(
            fontSize: 10,
            color: AppColors.neonCyan.withValues(alpha: 0.8),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(16),
        borderColor: AppColors.neonGreen.withValues(alpha: 0.2),
        backgroundColor: AppColors.darkSurface.withValues(alpha: 0.5),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: AppColors.neonGreen,
                size: 20,
              ),
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
                      color: AppColors.neonGreen,
                    ),
                  ),
                  Text(
                    'Sub: Premium',
                    style: GoogleFonts.rajdhani(
                      fontSize: 10,
                      color: AppColors.textSecondary,
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
}
