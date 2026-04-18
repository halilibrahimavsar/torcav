import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/wifi_band.dart';
import 'scan_filter_state.dart';

class SearchFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final ScanFilterState filter;
  final ValueChanged<ScanFilterState> onFilterChanged;

  const SearchFilterBar({
    super.key,
    required this.controller,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surfaceContainer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primary.withValues(alpha: 0.2), width: 1),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.rajdhani(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchSsidBssidVendor,
              hintStyle: GoogleFonts.rajdhani(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              prefixIcon: Icon(Icons.search_rounded, color: primary, size: 18),
              suffixIcon:
                  controller.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 16,
                          color: primary,
                        ),
                        onPressed: () {
                          controller.clear();
                          onFilterChanged(filter.copyWith(query: ''));
                        },
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (v) => onFilterChanged(filter.copyWith(query: v)),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ScanChip(
                label: AppLocalizations.of(
                  context,
                )!.sortPrefix(_sortLabel(context, filter.sortBy)),
                icon: Icons.sort_rounded,
                color: primary,
                onTap: () => _showSortMenu(context),
              ),
              const SizedBox(width: 8),
              for (final band in [
                null,
                WifiBand.ghz24,
                WifiBand.ghz5,
                WifiBand.ghz6,
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _ScanChip(
                    label:
                        band == null
                            ? AppLocalizations.of(context)!.bandAll
                            : _bandLabel(band),
                    icon:
                        band == null
                            ? Icons.cell_tower_rounded
                            : Icons.wifi_rounded,
                    color:
                        filter.band == band
                            ? primary
                            : Theme.of(context).colorScheme.outline,
                    selected: filter.band == band,
                    onTap: () => onFilterChanged(filter.copyWith(band: band)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _sortLabel(BuildContext context, ScanSortBy sortBy) {
    final l10n = AppLocalizations.of(context)!;
    switch (sortBy) {
      case ScanSortBy.signal:
        return l10n.sortSignal;
      case ScanSortBy.ssid:
        return l10n.sortName;
      case ScanSortBy.channel:
        return l10n.sortChannel;
      case ScanSortBy.security:
        return l10n.sortSecurity;
    }
  }

  String _bandLabel(WifiBand band) {
    switch (band) {
      case WifiBand.ghz24:
        return '2.4 GHz';
      case WifiBand.ghz5:
        return '5 GHz';
      case WifiBand.ghz6:
        return '6 GHz';
    }
  }

  void _showSortMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.sortByTitle,
                  style: GoogleFonts.orbitron(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                for (final sort in ScanSortBy.values)
                  ListTile(
                    title: Text(
                      _sortLabel(context, sort).toUpperCase(),
                      style: GoogleFonts.rajdhani(
                        color:
                            filter.sortBy == sort
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing:
                        filter.sortBy == sort
                            ? Icon(
                              Icons.check_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            )
                            : null,
                    onTap: () {
                      Navigator.pop(context);
                      onFilterChanged(filter.copyWith(sortBy: sort));
                    },
                  ),
              ],
            ),
          ),
    );
  }
}

class _ScanChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ScanChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color:
              selected
                  ? color.withValues(alpha: 0.15)
                  : Theme.of(
                    context,
                  ).colorScheme.surfaceContainer.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: selected ? 0.6 : 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
