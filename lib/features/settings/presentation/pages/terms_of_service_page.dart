import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                'TERMS OF SERVICE',
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
                  '1. ACCEPTANCE',
                  'By accessing or using Torcav, you agree to be bound by these Terms. If you do not agree, you must immediately cease use of the App.',
                ),
                _buildTermSection(
                  context,
                  '2. AUTHORIZED TESTING ONLY',
                  'You represent and warrant that you will only use the App to analyze networks and devices that you own or for which you have received explicit, written authorization to test. Unauthorized access to networks is strictly prohibited and may be illegal in your jurisdiction.',
                  isCritical: true,
                ),
                _buildTermSection(
                  context,
                  '3. DISCLAIMER OF WARRANTIES',
                  'The App is provided "as is" and "as available". We do not guarantee that the App will identify all security vulnerabilities or that its results are 100% accurate. Use at your own risk.',
                ),
                _buildTermSection(
                  context,
                  '4. LIMITATION OF LIABILITY',
                  'In no event shall the developers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the App.',
                ),
                _buildTermSection(
                  context,
                  '5. MODIFICATIONS',
                  'We reserve the right to modify these terms at any time. Continued use of the App following any changes constitutes acceptance of the new terms.',
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Last Updated: April 2026',
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
            'LEGAL NOTICE',
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.error,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This application is a security auditing tool. Misuse of this software to access or monitor networks without permission is strictly prohibited.',
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
