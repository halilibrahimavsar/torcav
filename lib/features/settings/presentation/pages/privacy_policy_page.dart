import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
                'PRIVACY POLICY',
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
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'DATA COLLECTION & USAGE'),
                _buildPolicyCard(
                  context,
                  icon: Icons.wifi_rounded,
                  title: 'WiFi & Network Analysis',
                  content:
                      'Nearby network signatures and local device fingerprints are processed to identify security risks. This data is strictly local and is never transmitted off-device.',
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.location_on_rounded,
                  title: 'Location Services',
                  content:
                      'Android requires location permissions to perform WiFi scans. Torcav uses this exclusively for hardware-level scanning and does not track your movements or upload your location.',
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.directions_walk_rounded,
                  title: 'Sensors & Movement',
                  content:
                      'Activity recognition and accelerometer data are used during heatmap surveys to map signal strength to your physical path. Processing occurs entirely in-memory.',
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.memory_rounded,
                  title: 'AI & Local Classification',
                  content:
                      'Device manufacturer identification and security scoring are performed using local ONNX models. No proprietary data leaves the device.',
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'GOVERNANCE & TRANSPARENCY'),
                _buildPolicyCard(
                  context,
                  icon: Icons.radar_rounded,
                  title: 'Active Network Discovery',
                  content:
                      'Torcav may perform active service probing (e.g., port scanning, SSDP/mDNS queries) to identify device types. This generates local network traffic but transmits zero data to our servers.',
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.child_care_rounded,
                  title: 'Children\'s Privacy',
                  content:
                      'Our services are not directed to persons under 13. We do not knowingly collect personal information from children. If you are a parent and aware that your child has provided us with personal data, please contact us.',
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.timer_rounded,
                  title: 'Data Retention',
                  content:
                      'Data persists only as long as the app remains installed or until you manually clear it. We have no way to recover your data if you delete it or uninstall the app.',
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.delete_forever_rounded,
                  title: 'Data Persistence',
                  content:
                      'All history is stored in an encrypted-at-rest SQLite database. You can permanently wipe all records using the "Wipe All Local Data" tool in Settings.',
                  isHighlight: true,
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.security_rounded,
                  title: 'No Third-Party Access',
                  content:
                      'Torcav contains zero trackers, advertisements, or analytics SDKs. We do not share, sell, or rent any information to third parties.',
                ),
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'CONTACT SUPPORT',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'support@halilibrahimavsar.com',
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Version 1.0.0 • April 2026',
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
        'Torcav is built on the principle of "Privacy by Default". We believe your network data should belong to you alone. This policy outlines how we handle the technical metadata required for app functionality.',
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
        color: isHighlight
            ? colorScheme.error.withValues(alpha: 0.05)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlight
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
              color: isHighlight
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
