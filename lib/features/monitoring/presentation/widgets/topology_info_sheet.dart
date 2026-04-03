import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/neon_widgets.dart';

class TopologyInfoSheet extends StatelessWidget {
  const TopologyInfoSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TopologyInfoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;

    return GlassmorphicContainer(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      borderColor: colorScheme.primary,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.auto_graph_rounded,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.topologyGuideTitle.toUpperCase(),
                              style: GoogleFonts.orbitron(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              l10n.topologyGuideDesc,
                              style: GoogleFonts.rajdhani(
                                fontSize: 14,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Sections
                  _InfoSection(
                    title: l10n.gatewayTitle,
                    description: l10n.gatewayDesc,
                    icon: Icons.router_rounded,
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(height: 24),
                  _InfoSection(
                    title: l10n.deviceLayersTitle,
                    description: l10n.deviceLayersDesc,
                    icon: Icons.layers_rounded,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(height: 24),
                  _InfoSection(
                    title: l10n.pathwaysTitle,
                    description: l10n.pathwaysDesc,
                    icon: Icons.multiple_stop_rounded,
                    color: colorScheme.primary,
                  ),

                  const SizedBox(height: 16),
                  _buildLegendSection(context),
                  const SizedBox(height: 24),
                  _buildTechnicalContext(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Close Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Text(
                'ACKNOWLEDGED',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'LEGEND & NODES', Icons.legend_toggle_rounded),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _legendTile(context, Icons.router, colorScheme.primary, 'GATEWAY', 'Central network entry point'),
            _legendTile(context, Icons.settings_input_antenna, colorScheme.tertiary, 'ACCESS POINT', 'WiFi signal distributor'),
            _legendTile(context, Icons.smartphone, const Color(0xFFFF0060), 'MOBILE', 'Personal handheld devices'),
            _legendTile(context, Icons.sensors_outlined, const Color(0xFFB5179E), 'IOT', 'Smart home & sensors'),
            _legendTile(context, Icons.device_hub, colorScheme.secondary, 'DEVICE', 'Computers, TVs, etc.'),
          ],
        ),
      ],
    );
  }

  Widget _legendTile(BuildContext context, IconData icon, Color color, String label, String desc) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: GoogleFonts.rajdhani(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalContext(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'CONNECTION TYPES', Icons.linear_scale_rounded),
        const SizedBox(height: 12),
        _connectionType(context, 'Solid Line (Blue)', 'High-speed wired Ethernet connection'),
        _connectionType(context, 'Glowing Gradient (Cyan)', 'Wireless WiFi connection'),
        _connectionType(context, 'Pulsing Data Point', 'Active traffic detected on the link'),
      ],
    );
  }

  Widget _connectionType(BuildContext context, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Colors.white24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.rajdhani(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.rajdhani(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7), size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.orbitron(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _InfoSection({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
