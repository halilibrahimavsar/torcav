import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../monitoring/presentation/bloc/topology_bloc.dart';
import '../../../monitoring/presentation/pages/topology_page.dart';
import '../../domain/entities/network_scan_profile.dart';
import '../bloc/network_scan_bloc.dart';
import '../widgets/network_scanner_radar.dart';
import '../widgets/scan_profile_card.dart';
import 'network_scan_page.dart';

/// Unified LAN discovery shell.
///
/// Hosts a single [NetworkScanBloc] and exposes its results through two
/// interchangeable views — a device **List** and a network **Map** — so the
/// user scans once and switches presentation instead of running two
/// separate features.
///
/// The scan controls (target + profile) live in a shared bar above both
/// views, so a scan can be started — and watched live — from either one.
class LanDiscoveryPage extends StatefulWidget {
  const LanDiscoveryPage({super.key});

  @override
  State<LanDiscoveryPage> createState() => _LanDiscoveryPageState();
}

class _LanDiscoveryPageState extends State<LanDiscoveryPage> {
  /// false = list view, true = map view.
  bool _mapView = false;

  final TextEditingController _targetController = TextEditingController(
    text: '192.168.1.0/24',
  );
  NetworkScanProfile _profile = NetworkScanProfile.fast;

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

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
          void startScan() {
            context.read<NetworkScanBloc>().add(
              StartNetworkScan(
                target: _targetController.text,
                profile: _profile,
              ),
            );
          }

          void cancelScan() {
            context.read<NetworkScanBloc>().add(const CancelNetworkScan());
          }

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
                _LanScanBar(
                  controller: _targetController,
                  profile: _profile,
                  onProfileChanged: (p) => setState(() => _profile = p),
                  onScan: startScan,
                  onCancel: cancelScan,
                ),
                _ViewToggle(
                  mapView: _mapView,
                  onChanged: (v) => setState(() => _mapView = v),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _mapView ? 1 : 0,
                    children: [
                      NetworkScanPage(
                        targetController: _targetController,
                        onRescan: startScan,
                      ),
                      const TopologyPage(),
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

/// Shared scan control bar: target subnet, profile selector and a
/// scan/cancel action. Sits above both the list and map views so a scan can
/// be triggered and observed from either.
class _LanScanBar extends StatelessWidget {
  const _LanScanBar({
    required this.controller,
    required this.profile,
    required this.onProfileChanged,
    required this.onScan,
    required this.onCancel,
  });

  final TextEditingController controller;
  final NetworkScanProfile profile;
  final ValueChanged<NetworkScanProfile> onProfileChanged;
  final VoidCallback onScan;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<NetworkScanBloc, NetworkScanState>(
      builder: (context, state) {
        final isScanning =
            state is NetworkScanLoading ||
            (state is NetworkScanLoaded && state.isScanning);
        final startedAt = switch (state) {
          NetworkScanLoading(:final startedAt) => startedAt,
          NetworkScanLoaded(:final scanStartedAt) => scanStartedAt,
          _ => null,
        };
        final foundCount =
            state is NetworkScanLoaded ? state.hosts.length : 0;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: TextField(
                        controller: controller,
                        enabled: !isScanning,
                        style: GoogleFonts.sourceCodePro(
                          color: scheme.onSurface,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          prefixIcon: Icon(
                            Icons.network_check_rounded,
                            size: 18,
                            color: scheme.primary.withValues(alpha: 0.6),
                          ),
                          hintText: '192.168.1.0/24',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _ScanButton(
                    isScanning: isScanning,
                    onScan: onScan,
                    onCancel: onCancel,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 15,
                    color: scheme.primary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)!.scanProfileLabel,
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      color: scheme.primary.withValues(alpha: 0.7),
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  DropdownButton<NetworkScanProfile>(
                    value: profile,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    style: GoogleFonts.rajdhani(
                      color: scheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    dropdownColor: scheme.surfaceContainer,
                    items:
                        NetworkScanProfile.values
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                    onChanged:
                        isScanning
                            ? null
                            : (p) {
                              if (p != null) onProfileChanged(p);
                            },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (isScanning && startedAt != null)
                _LiveScanBanner(startedAt: startedAt, foundCount: foundCount)
              else
                ScanProfileCard(profile: profile),
            ],
          ),
        );
      },
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton({
    required this.isScanning,
    required this.onScan,
    required this.onCancel,
  });

  final bool isScanning;
  final VoidCallback onScan;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isScanning ? scheme.error : scheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isScanning ? onCancel : onScan,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withValues(alpha: 0.12),
            border: Border.all(color: color.withValues(alpha: 0.32)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isScanning ? Icons.stop_rounded : Icons.radar_rounded,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                (isScanning
                        ? AppLocalizations.of(context)!.cancelLabel
                        : AppLocalizations.of(context)!.scanAllCaps)
                    .toUpperCase(),
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Live, ticking scan metrics — elapsed time, devices found and discovery
/// rate — so the speed difference between scan profiles is visible.
class _LiveScanBanner extends StatefulWidget {
  const _LiveScanBanner({required this.startedAt, required this.foundCount});

  final DateTime startedAt;
  final int foundCount;

  @override
  State<_LiveScanBanner> createState() => _LiveScanBannerState();
}

class _LiveScanBannerState extends State<_LiveScanBanner> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatElapsed(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final elapsed = DateTime.now().difference(widget.startedAt).inSeconds;
    final safeElapsed = elapsed < 1 ? 1 : elapsed;
    final rate = (widget.foundCount / safeElapsed).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: NetworkScannerRadar(isScanning: true, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          _Metric(
            label: l10n.scanElapsedLabel,
            value: _formatElapsed(elapsed),
            color: scheme.primary,
          ),
          const SizedBox(width: 18),
          _Metric(
            label: l10n.nodesLabel,
            value: '${widget.foundCount}',
            color: scheme.tertiary,
          ),
          const SizedBox(width: 18),
          _Metric(
            label: l10n.scanRateLabel,
            value: '$rate/s',
            color: scheme.secondary,
          ),
          const Spacer(),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: 7,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: color.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.sourceCodePro(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
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
