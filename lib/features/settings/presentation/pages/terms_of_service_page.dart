import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/extensions/context_extensions.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

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
            floating: false,
            pinned: true,
            centerTitle: true,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                l10n.tosTitle,
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
                _buildWarningCard(context),
                const SizedBox(height: 24),
                _buildTermSection(
                  context,
                  l10n.tosAcceptanceTitle,
                  l10n.tosAcceptanceBody,
                ),
                _buildTermSection(
                  context,
                  l10n.tosAuthorizedTestingTitle,
                  l10n.tosAuthorizedTestingBody,
                  isCritical: true,
                ),
                _buildTermSection(
                  context,
                  l10n.tosDisclaimerTitle,
                  l10n.tosDisclaimerBody,
                ),
                _buildTermSection(
                  context,
                  l10n.tosLiabilityTitle,
                  l10n.tosLiabilityBody,
                ),
                _buildTermSection(
                  context,
                  l10n.tosModificationsTitle,
                  l10n.tosModificationsBody,
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    l10n.tosLastUpdated,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.gavel_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.legalNoticeTitle,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.error,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.legalNoticeBody,
            textAlign: TextAlign.center,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermSection(
    BuildContext context,
    String title,
    String content, {
    bool isCritical = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isCritical ? colorScheme.error : colorScheme.primary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.rajdhani(
              fontSize: 15,
              height: 1.5,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ],
      ),
    );
  }
}
