import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/extensions/context_extensions.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  /// Public URL where the canonical privacy policy is hosted.
  static const String _privacyPolicyUrl =
      'https://halirlnj.github.io/torcav-privacy/';

  /// Contact email shown to users who want to exercise data-subject rights.
  static const String _contactEmail = 'halirlnj@gmail.com';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            pinned: true,
            centerTitle: true,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                l10n.privacyTitle,
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: colorScheme.onSurface,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.1),
                      colorScheme.surface,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildIntroCard(context),
                const SizedBox(height: 16),
                _buildFullPolicyCta(context),
                const SizedBox(height: 24),
                _buildSectionHeader(context, l10n.privacyResponsibleTitle),
                _buildPolicyCard(
                  context,
                  icon: Icons.person_rounded,
                  title: l10n.privacyIndividualDev,
                  content: l10n.privacyDevBody(_contactEmail),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, l10n.privacyDataCollectionTitle),
                _buildPolicyCard(
                  context,
                  icon: Icons.wifi_rounded,
                  title: l10n.privacyWifiAnalysisTitle,
                  content: l10n.privacyWifiAnalysisBody,
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.lan_rounded,
                  title: l10n.privacyLanInventoryTitle,
                  content: l10n.privacyLanInventoryBody,
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.location_on_rounded,
                  title: l10n.privacyLocationTitle,
                  content: l10n.privacyLocationBody,
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.directions_walk_rounded,
                  title: l10n.privacySensorsTitle,
                  content: l10n.privacySensorsBody,
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.memory_rounded,
                  title: l10n.privacyAiTitle,
                  content: l10n.privacyAiBody,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  context,
                  l10n.privacyExternalEndpointsTitle,
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.speed_rounded,
                  title: l10n.privacyCloudflareTitle,
                  content: l10n.privacyCloudflareBody,
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.dns_rounded,
                  title: l10n.privacyDnsProbesTitle,
                  content: l10n.privacyDnsProbesBody,
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.web_rounded,
                  title: l10n.privacyCaptivePortalTitle,
                  content: l10n.privacyCaptivePortalBody,
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.password_rounded,
                  title: l10n.privacyBreachCheckTitle,
                  content: l10n.privacyBreachCheckBody,
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.block_rounded,
                  title: l10n.privacyNoTrackersTitle,
                  content: l10n.privacyNoTrackersBody,
                  isHighlight: true,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, l10n.privacyRetentionTitle),
                _buildPolicyCard(
                  context,
                  icon: Icons.timer_rounded,
                  title: l10n.privacyConfigRetentionTitle,
                  content: l10n.privacyConfigRetentionBody,
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.delete_forever_rounded,
                  title: l10n.privacyWipeLocalDataTitle,
                  content: l10n.privacyWipeLocalDataBody,
                  isHighlight: true,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, l10n.privacyRightsTitle),
                _buildPolicyCard(
                  context,
                  icon: Icons.gavel_rounded,
                  title: l10n.privacyKvkkGdprTitle,
                  content: l10n.privacyRightsBody(_contactEmail),
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.child_care_rounded,
                  title: l10n.privacyChildrenTitle,
                  content: l10n.privacyChildrenBody,
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.security_rounded,
                  title: l10n.privacyAuthorisedUseTitle,
                  content: l10n.privacyAuthorisedUseBody,
                ),
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Text(
                        l10n.privacyContactLabel,
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _contactEmail,
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.privacyEffectiveDate,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullPolicyCta(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        final uri = Uri.parse(_privacyPolicyUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.open_in_new_rounded, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.privacyViewFullGithub,
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.privacyFullPolicyDesc,
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      height: 1.35,
                      color: colorScheme.onSurfaceVariant,
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

  Widget _buildIntroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        context.l10n.privacyIntro,
        style: GoogleFonts.outfit(
          fontSize: 14,
          height: 1.6,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.orbitron(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildPolicyCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    bool isHighlight = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isHighlight
                ? colorScheme.error.withValues(alpha: 0.05)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isHighlight
                  ? colorScheme.error.withValues(alpha: 0.2)
                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  isHighlight
                      ? colorScheme.error.withValues(alpha: 0.1)
                      : colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: isHighlight ? colorScheme.error : colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    height: 1.45,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
