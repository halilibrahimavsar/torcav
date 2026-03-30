import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';

/// A cybernetic profile hub for the agent.
class ProfileHubPage extends StatelessWidget {
  const ProfileHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: NeonText(
          l10n.profileTitle.toUpperCase(),
          style: GoogleFonts.orbitron(
            color: AppColors.neonCyan,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          glowRadius: 8,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Agent Identity Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.neonCyan.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonCyan.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_circle_outlined,
                      size: 80,
                      color: AppColors.neonCyan,
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeonText(
                    'OPERATOR_01',
                    style: GoogleFonts.orbitron(
                      color: AppColors.neonCyan,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.agentId('TR-9982-CX'),
                    style: GoogleFonts.outfit(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Session Information
            _buildSectionHeader(context, l10n.sessionInformation),
            const SizedBox(height: 16),
            HolographicCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      l10n.activeSession,
                      '2h 45m',
                      Icons.timer_outlined,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      context,
                      l10n.subscriptionStatus,
                      'ENTERPRISE_ELITE',
                      Icons.verified_user_outlined,
                      valueColor: AppColors.neonCyan,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Security Posture / Bio-metrics placeholder
            _buildSectionHeader(context, l10n.biometricData),
            const SizedBox(height: 16),
            HolographicCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      l10n.neuralSync,
                      '98.2%',
                      Icons.psychology_outlined,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      context,
                      l10n.encryptionKey,
                      'AES-256-GCM',
                      Icons.vpn_key_outlined,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.neonCyan,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: valueColor ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
