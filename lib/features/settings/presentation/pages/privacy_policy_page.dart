import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  /// Public URL where the canonical privacy policy is hosted. This is the
  /// same URL submitted to Google Play / Apple App Store. Replace with the
  /// actual GitHub Pages URL once the repo is created (see
  /// `docs/PRIVACY_POLICY_HOSTING.md`).
  static const String _privacyPolicyUrl =
      'https://halirlnj.github.io/torcav-privacy/';

  /// Contact email shown to users who want to exercise data-subject rights.
  static const String _contactEmail = 'halirlnj@gmail.com';

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
                const SizedBox(height: 16),
                _buildFullPolicyCta(context),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'WHO IS RESPONSIBLE'),
                _buildPolicyCard(
                  context,
                  icon: Icons.person_rounded,
                  title: 'Individual Developer',
                  content:
                      'Torcav is operated by an individual developer (Halil İbrahim Avşar), not a registered company. '
                      'You can reach the data controller directly at $_contactEmail.',
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'DATA COLLECTION & USAGE'),
                _buildPolicyCard(
                  context,
                  icon: Icons.wifi_rounded,
                  title: 'Wi-Fi & Network Analysis',
                  content:
                      'Nearby SSID/BSSID/RSSI metadata and security flags (WPA2/WPA3/WPS/PMF) are read from the OS scan API. '
                      'This data stays in a local SQLite database encrypted at rest. It is never uploaded.',
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.lan_rounded,
                  title: 'LAN Device Inventory',
                  content:
                      'When you run a LAN scan, the app collects IP/MAC/hostname/vendor/open ports for devices on the same '
                      'network. This may include third-party devices — anonymisation is on by default for exports.',
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.location_on_rounded,
                  title: 'Location Permission (Wi-Fi only)',
                  content:
                      'Android requires the location permission to enable Wi-Fi scanning. Torcav uses it strictly for '
                      'that — we do not read GPS coordinates and we do not track movement.',
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.directions_walk_rounded,
                  title: 'Sensors & Heatmap',
                  content:
                      'Activity recognition + IMU/barometer are used during heatmap surveys to map signal strength to '
                      'your relative path (origin = scan start). GPS is not used.',
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.memory_rounded,
                  title: 'AI / Local Classification',
                  content:
                      'Device-type identification uses a local ONNX model. No proprietary or vendor data leaves the device.',
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'EXTERNAL ENDPOINTS'),
                _buildPolicyCard(
                  context,
                  icon: Icons.speed_rounded,
                  title: 'Cloudflare Speed Test',
                  content:
                      'Speed Doctor and the speed-test page download/upload ~300-500 MB against speed.cloudflare.com. '
                      'Cloudflare sees your IP — no Torcav identifier or telemetry is attached.',
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.dns_rounded,
                  title: 'Public DNS Probes',
                  content:
                      '1.1.1.1, 8.8.8.8, 9.9.9.9, OpenDNS and AdGuard are queried for DNS benchmark and leak detection. '
                      'They see standard DNS queries (no user identifiers).',
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.web_rounded,
                  title: 'Captive Portal Probe',
                  content:
                      'connectivitycheck.gstatic.com receives a plain HEAD request to detect captive portals. '
                      'This is the same probe Android itself runs.',
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.block_rounded,
                  title: 'No Analytics, No Trackers, No Ads',
                  content:
                      'There are zero analytics SDKs, zero advertising IDs, zero crash-reporting services in v1.0. '
                      'We do not phone home on app start.',
                  isHighlight: true,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'RETENTION & DELETION'),
                _buildPolicyCard(
                  context,
                  icon: Icons.timer_rounded,
                  title: 'Configurable Retention',
                  content:
                      'Settings → Privacy lets you set retention windows (7-365 days) for scan history, speed tests, '
                      'and security events. Default is 30 days. Old records prune automatically.',
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.delete_forever_rounded,
                  title: 'Wipe All Local Data',
                  content:
                      'A single tap in Settings → Privacy clears every persisted record: scans, devices, security events, '
                      'heatmap sessions, LAN history, exports. Irreversible.',
                  isHighlight: true,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'YOUR RIGHTS'),
                _buildPolicyCard(
                  context,
                  icon: Icons.gavel_rounded,
                  title: 'KVKK (Turkey) + GDPR (EU/EEA)',
                  content:
                      'You can request access, correction, deletion, or portability of your data. '
                      'For deletion, the in-app Wipe All button is the fastest path. '
                      'For other requests, email $_contactEmail — we respond within 30 days.',
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.child_care_rounded,
                  title: 'Children\'s Privacy',
                  content:
                      'Torcav is not directed at users under 13 and presumes the user is old enough to take responsibility '
                      'for the network being scanned.',
                ),
                _buildPolicyCard(
                  context,
                  icon: Icons.security_rounded,
                  title: 'Authorised Use Only',
                  content:
                      'Use Torcav on networks you own or are explicitly authorised to scan. Active LAN discovery and '
                      'port scanning on networks you do not own may violate Turkish, EU, and US laws.',
                ),
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'CONTACT',
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
                        'Effective 2026-05-08 • Version 1.0',
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
                    'VIEW FULL POLICY ON GITHUB',
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'The card list below is a summary. The canonical, KVKK + GDPR-formatted policy is hosted at github.io.',
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
        'Torcav is built on the principle of "Privacy by Default". Almost every byte stays on your device — no accounts, '
        'no cloud sync, no analytics, no advertising. A handful of features connect to public technical endpoints '
        '(Cloudflare, Google\'s captive-portal probe, public DNS resolvers) — those see only your IP, never any '
        'Torcav-internal identifier. You can wipe every persisted record with one tap.',
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
