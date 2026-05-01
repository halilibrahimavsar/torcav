import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../wifi_scan/domain/entities/channel_rating.dart';
import '../../../wifi_scan/domain/entities/wifi_network.dart';
import '../../domain/router_grouping.dart';

/// Compact list of dual-band routers detected in the current scan.
/// Each chip jumps to the relevant band tab when tapped.
class RouterGroupsCard extends StatelessWidget {
  final List<RouterGroup> groups;
  final Map<String, ChannelRating?> Function(WifiNetwork) ratingFor;
  final void Function(int bandIndex) onJumpToBand;

  const RouterGroupsCard({
    super.key,
    required this.groups,
    required this.ratingFor,
    required this.onJumpToBand,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.neonPurple.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.neonPurple.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.router_outlined,
                color: AppColors.neonPurple,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.routerGroupsHeader,
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neonPurple,
                    letterSpacing: 1,
                  ),
                ),
              ),
              InfoIconButton(
                title: l10n.routerGroupsHeader,
                body: l10n.routerGroupsInfoBody,
                color: AppColors.neonPurple,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...groups.map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _GroupRow(
                group: g,
                ratingFor: ratingFor,
                onJumpToBand: onJumpToBand,
                onSurface: onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupRow extends StatelessWidget {
  final RouterGroup group;
  final Map<String, ChannelRating?> Function(WifiNetwork) ratingFor;
  final void Function(int bandIndex) onJumpToBand;
  final Color onSurface;

  const _GroupRow({
    required this.group,
    required this.ratingFor,
    required this.onJumpToBand,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.wifi_tethering_rounded, size: 14, color: AppColors.neonPurple),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                group.ssid,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: onSurface.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var i = 0; i < group.radios.length; i++)
              _BandChip(
                radio: group.radios[i],
                rating: ratingFor(group.radios[i])[_bandKey(group.radios[i])],
                isLast: i == group.radios.length - 1,
                onTap: () =>
                    onJumpToBand(_bandIndex(group.radios[i].frequency)),
              ),
          ],
        ),
      ],
    );
  }

  static String _bandKey(WifiNetwork n) {
    if (n.frequency < 2500) return '2.4';
    if (n.frequency < 5925) return '5';
    return '6';
  }

  static int _bandIndex(int frequency) {
    if (frequency < 2500) return 0;
    if (frequency < 5925) return 1;
    return 2;
  }
}

class _BandChip extends StatelessWidget {
  final WifiNetwork radio;
  final ChannelRating? rating;
  final bool isLast;
  final VoidCallback onTap;

  const _BandChip({
    required this.radio,
    required this.rating,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _bandColor(radio.frequency);
    final label = _bandLabel(radio.frequency);
    final ratingText =
        rating != null ? ' · ${rating!.rating.toStringAsFixed(1)}' : '';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          '$label CH ${radio.channel}$ratingText',
          style: GoogleFonts.orbitron(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Color _bandColor(int freq) {
    if (freq < 2500) return const Color(0xFF00E5FF);
    if (freq < 5925) return const Color(0xFF76FF03);
    return const Color(0xFFEEFF41);
  }

  String _bandLabel(int freq) {
    if (freq < 2500) return '2.4 GHz';
    if (freq < 5925) return '5 GHz';
    return '6 GHz';
  }
}
