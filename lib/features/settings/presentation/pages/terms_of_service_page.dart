import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'TERMS OF SERVICE',
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              '1. ACCEPTANCE OF TERMS',
              'By accessing or using Torcav, you agree to be bound by these Terms of Service. If you do not agree, you may not use the App.',
            ),
            _buildSection(
              context,
              '2. AUTHORIZED USE',
              'You represent and warrant that you will only use the App to analyze networks and devices that you own or for which you have received explicit, written authorization to test. Unauthorized access to networks is illegal and strictly prohibited.',
            ),
            _buildSection(
              context,
              '3. NO WARRANTY',
              'The App is provided "as is" without warranty of any kind. We do not guarantee the accuracy of scan results or that the App will identify all security vulnerabilities.',
            ),
            _buildSection(
              context,
              '4. LIMITATION OF LIABILITY',
              'In no event shall the developers be liable for any damages arising out of the use or inability to use the App, even if advised of the possibility of such damages.',
            ),
            _buildSection(
              context,
              '5. GOVERNING LAW',
              'These terms are governed by the laws of your jurisdiction. Any disputes shall be resolved in the appropriate courts.',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Last Updated: April 2026',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
