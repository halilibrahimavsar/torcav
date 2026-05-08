import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Explains, in plain language, what the on-device Ping Stabilizer does
/// and the trade-offs the user should understand before turning it on.
///
/// Shown on the Ping Stabilizer page header and (collapsed) on the dashboard
/// quick-access card. Honest about the limits — no marketing claims about
/// "boosting" pings beyond what your ISP gives you.
class StabilizerExplainer extends StatelessWidget {
  final bool startCollapsed;

  const StabilizerExplainer({super.key, this.startCollapsed = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: !startCollapsed,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Icon(Icons.info_outline_rounded, color: scheme.primary),
          title: Text(
            'How Ping Stabilizer works',
            style: GoogleFonts.orbitron(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
              letterSpacing: 1.2,
            ),
          ),
          subtitle: Text(
            'On-device, no remote servers, free.',
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurfaceVariant,
            ),
          ),
          children: const [
            _ExplainerSection(
              icon: Icons.bolt_rounded,
              title: 'What it does',
              bullets: [
                'Establishes a local VPN tunnel on your device — no traffic '
                    'leaves through any third-party server.',
                'Routes DNS queries to the fastest resolver (1.1.1.1, 8.8.8.8, '
                    '9.9.9.9, …) measured live.',
                'Watches latency / jitter every second and warns you when a '
                    'spike persists, optionally cycling the tunnel to break a '
                    'sticky bad path.',
                'Uses an EWMA filter (recent samples weighted heavier) so it '
                    'reacts to real degradation, not single-packet noise.',
              ],
            ),
            SizedBox(height: 12),
            _ExplainerSection(
              icon: Icons.warning_amber_rounded,
              title: 'What it does NOT do',
              bullets: [
                'It cannot make your ISP\'s route to the game server '
                    'physically shorter — no on-device app can.',
                'It does not replace a paid VPN/relay service like ExitLag or '
                    'WTFast (those route via their own servers; this is local-only).',
                'Multi-path "first-wins" send across Wi-Fi + cellular is on the '
                    'roadmap (Phase 2) and currently disabled.',
              ],
            ),
            SizedBox(height: 12),
            _ExplainerSection(
              icon: Icons.shield_outlined,
              title: 'Risks & things to know',
              bullets: [
                'Android shows a key icon while the tunnel is active — that is '
                    'normal and required by the system.',
                'Only one VPN can run at a time. If you have another VPN app '
                    'connected, this will refuse to start.',
                'A persistent low-priority notification is mandatory for VPN '
                    'foreground services on modern Android.',
                'DNS auto-switch will change which resolver answers your '
                    'queries while the tunnel is on. That switch reverts when '
                    'you stop the stabilizer.',
                'Battery use is small (~3-5%/hr in our tests) but non-zero — '
                    'turn it off when you\'re done playing.',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplainerSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> bullets;

  const _ExplainerSection({
    required this.icon,
    required this.title,
    required this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: scheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...bullets.map(
          (b) => Padding(
            padding: const EdgeInsets.only(left: 26, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ',
                    style:
                        TextStyle(color: scheme.onSurfaceVariant, height: 1.4)),
                Expanded(
                  child: Text(
                    b,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
