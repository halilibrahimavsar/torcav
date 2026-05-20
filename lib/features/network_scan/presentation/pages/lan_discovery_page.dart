import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../monitoring/presentation/bloc/topology_bloc.dart';
import '../../../monitoring/presentation/pages/topology_page.dart';
import '../bloc/network_scan_bloc.dart';
import 'network_scan_page.dart';

/// Unified LAN discovery shell.
///
/// Hosts a single [NetworkScanBloc] and exposes its results through two
/// interchangeable views — a device **List** and a network **Map** — so the
/// user scans once and switches presentation instead of running two
/// separate features.
class LanDiscoveryPage extends StatefulWidget {
  const LanDiscoveryPage({super.key});

  @override
  State<LanDiscoveryPage> createState() => _LanDiscoveryPageState();
}

class _LanDiscoveryPageState extends State<LanDiscoveryPage> {
  /// false = list view, true = map view.
  bool _mapView = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NetworkScanBloc>(
          create: (_) => getIt<NetworkScanBloc>(),
        ),
        BlocProvider<TopologyBloc>(
          create:
              (_) =>
                  getIt<TopologyBloc>()
                    ..add(const BuildTopologyFromScanEvent([])),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Keep the map graph in sync with whatever the shared scan finds.
          return BlocListener<NetworkScanBloc, NetworkScanState>(
            listenWhen: (_, next) => next is NetworkScanLoaded,
            listener: (context, state) {
              if (state is NetworkScanLoaded) {
                context.read<TopologyBloc>().add(
                  BuildTopologyFromScanEvent(state.devices),
                );
              }
            },
            child: Column(
              children: [
                _ViewToggle(
                  mapView: _mapView,
                  onChanged: (v) => setState(() => _mapView = v),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _mapView ? 1 : 0,
                    children: const [
                      NetworkScanPage(provideBloc: false),
                      TopologyPage(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.mapView, required this.onChanged});

  final bool mapView;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      height: 40,
      decoration: BoxDecoration(
        color: scheme.surfaceContainer.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          _ToggleSegment(
            icon: Icons.view_list_rounded,
            label: l10n.lanViewListLabel,
            selected: !mapView,
            onTap: () => onChanged(false),
          ),
          _ToggleSegment(
            icon: Icons.hub_rounded,
            label: l10n.lanViewMapLabel,
            selected: mapView,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient:
                  selected
                      ? LinearGradient(
                        colors: [
                          scheme.primary.withValues(alpha: 0.2),
                          scheme.primary.withValues(alpha: 0.05),
                        ],
                      )
                      : null,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    selected
                        ? scheme.primary.withValues(alpha: 0.4)
                        : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    letterSpacing: 1,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
