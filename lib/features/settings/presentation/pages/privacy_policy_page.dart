import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'PRIVACY POLICY',
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
              'OVERVIEW',
              'Torcav ("the App") is a privacy-first network assistant designed for safe network diagnostics. Most analysis is performed locally on your device. We do not sell, rent, or trade your personal data with third parties.',
            ),
            _buildSection(
              context,
              'DATA COLLECTION & USAGE',
              '1. WiFi & Network Data: We scan nearby WiFi networks and local devices to provide security analysis and signal mapping. This data is strictly local and never uploaded.\n'
                  '2. Location Data: Android requires "Fine Location" permission to access WiFi scan results. This data is used only for scanning and is never transmitted off-device.\n'
                  '3. Sensors & Activity: We use accelerometer and activity recognition to track movement during signal surveys (heatmaps). This data is processed locally.\n'
                  '4. AI Classification: Device types are identified using a local ONNX model. No hardware identifiers are sent to our servers.',
            ),
            _buildSection(
              context,
              'DATA PERSISTENCE & DELETION',
              'All history, assessments, and security logs are stored in a private local database. You have full control over this data and can use the "Wipe All Local Data" feature in Settings to permanently delete all records from your device.',
            ),
            _buildSection(
              context,
              'THIRD-PARTY DISCLOSURE',
              'We do not share any data with third-party services. The App does not contain any third-party analytics, advertisements, or trackers.',
            ),
            _buildSection(
              context,
              'CONTACT',
              'For questions about this policy, contact us at: support@halilibrahimavsar.com',
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
