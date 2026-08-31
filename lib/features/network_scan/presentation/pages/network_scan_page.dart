import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/notification_context_extensions.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../domain/entities/host_scan_result.dart';

import '../../../../features/network_scan/presentation/widgets/network_scanner_radar.dart';
import '../bloc/network_scan_bloc.dart';
import '../widgets/host_device_card.dart';
import '../../../../core/theme/prominent_disclosure_dialog.dart';
import 'package:torcav/features/network_scan/domain/repositories/lan_scan_history_repository.dart';
import '../../../../core/errors/failure_labels.dart';

class NetworkScanPage extends StatelessWidget {
  /// The list view of the shared LAN discovery shell. A [NetworkScanBloc] must
  /// be supplied by an ancestor so the list and map views share one scan.
  const NetworkScanPage({
    super.key,
    required this.targetController,
    required this.onRescan,
  });

  /// Shared target subnet field, owned by the LAN discovery shell.
  final TextEditingController targetController;

  /// Re-runs the scan using the shell's current target + profile.
  final VoidCallback onRescan;

  @override
  Widget build(BuildContext context) {
    return _NetworkScanView(
      targetController: targetController,
      onRescan: onRescan,
    );
  }
}

class _NetworkScanView extends StatefulWidget {
  const _NetworkScanView({
    required this.targetController,
    required this.onRescan,
  });

  final TextEditingController targetController;
  final VoidCallback onRescan;

  @override
  State<_NetworkScanView> createState() => _NetworkScanViewState();
}

class _NetworkScanViewState extends State<_NetworkScanView> {
  final _searchController = TextEditingController();
  bool _vulnOnly = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _clearHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              context.l10n.clearScanHistoryTitle,
              style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              context.l10n.clearScanHistoryBody,
              style: GoogleFonts.rajdhani(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  context.l10n.cancelLabel,
                  style: GoogleFonts.orbitron(fontSize: 10),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  context.l10n.deleteAllLabel,
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    color: Theme.of(ctx).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      await getIt<LanScanHistoryRepository>().deleteAllSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<NetworkScanBloc, NetworkScanState>(
        listenWhen:
            (prev, next) =>
                next is NetworkScanLoaded && next.newDevices.isNotEmpty ||
                next is NetworkScanConsentRequired,
        listener: (context, state) async {
          if (state is NetworkScanConsentRequired) {
            final accepted = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder:
                  (ctx) => ProminentDisclosureDialog(
                    title: context.l10n.networkAuditConsentTitle,
                    description: context.l10n.networkAuditConsentDesc,
                    icon: Icons.gavel_rounded,
                    privacyPoints: [
                      context.l10n.consentScanNodes,
                      context.l10n.consentFingerprint,
                      context.l10n.consentIdentifyVulns,
                      context.l10n.consentConfirmAuth,
                    ],
                    actionLabel: context.l10n.iUnderstand,
                    onAccept: () => Navigator.of(ctx).pop(true),
                    onCancel: () => Navigator.of(ctx).pop(false),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            );
            if (context.mounted) {
              context.read<NetworkScanBloc>().add(
                AcknowledgeLegalRisk(accepted ?? false),
              );
            }
          }

          if (state is NetworkScanLoaded && state.newDevices.isNotEmpty) {
            if (!context.mounted) return;
            final count = state.newDevices.length;
            final label =
                count == 1
                    ? context.l10n.newDeviceFound(state.newDevices.first.ip)
                    : context.l10n.newDevicesFound(count);
            context.showInfo(label);
          }
        },
        builder: (context, state) {
          // Scan control + profile live in the shared LAN discovery bar above.
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              if (Platform.isIOS)
                _LanPlatformNotice(
                  message: context.l10n.iosLanDiscoveryLimited,
                ),

              // ── Full-screen radar (only when no results yet) ──
              if (state is NetworkScanLoading) const _ScanningIndicator(),

              if (state case final NetworkScanLoaded loaded) ...[
                const SizedBox(height: 16),
                // ── Section 2: SCAN ANALYTICS ──
                StaggeredEntry(
                  delay: const Duration(milliseconds: 150),
                  child: Row(
                    children: [
                      Expanded(
                        child: NeonSectionHeader(
                          label: context.l10n.intelligenceReportTitle,
                          icon: Icons.analytics_outlined,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      if (!loaded.isScanning)
                        IconButton(
                          icon: Icon(
                            Icons.delete_sweep_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          tooltip: context.l10n.clearScanHistoryTitle,
                          onPressed: () => _clearHistory(context),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _NetworkBentoHeader(
                  devices: loaded.devices,
                  hosts: loaded.hosts,
                  target: widget.targetController.text,
                ),
                if (Platform.isAndroid &&
                    loaded.hosts.any(
                      (host) =>
                          host.vendor.isEmpty ||
                          host.vendor == 'Unknown' ||
                          host.vendor == 'Android Device (MAC Restricted)',
                    )) ...[
                  const SizedBox(height: 12),
                  _LanPlatformNotice(
                    message: context.l10n.androidLanVendorLimited,
                  ),
                ],
                const SizedBox(height: 32),

                // ── Section 3: DISCOVERED NODES ──
                StaggeredEntry(
                  delay: const Duration(milliseconds: 200),
                  child: NeonSectionHeader(
                    label: context.l10n.discoveredEndpointsTitle,
                    icon: Icons.devices_rounded,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Search & Filter ──
                _LanSearchBar(
                  controller: _searchController,
                  vulnOnly: _vulnOnly,
                  onVulnFilterChanged: (v) => setState(() => _vulnOnly = v),
                ),
                const SizedBox(height: 12),

                ...() {
                  final hosts =
                      loaded.hosts.where((h) {
                        if (_vulnOnly && h.vulnerabilities.isEmpty) {
                          return false;
                        }
                        if (_searchQuery.isNotEmpty) {
                          if (!h.ip.contains(_searchQuery) &&
                              !h.hostName.toLowerCase().contains(
                                _searchQuery,
                              ) &&
                              !h.vendor.toLowerCase().contains(_searchQuery)) {
                            return false;
                          }
                        }
                        return true;
                      }).toList();

                  return hosts.asMap().entries.map((entry) {
                    return StaggeredEntry(
                      delay: Duration(milliseconds: 50 + entry.key * 30),
                      child: HostDeviceCard(host: entry.value),
                    );
                  });
                }(),
              ],

              if (state is NetworkScanError) ...[
                StaggeredEntry(
                  delay: const Duration(milliseconds: 200),
                  child: NeonErrorCard(
                    message: FailureLabels.forKey(
                      context.l10n,
                      state.messageKey,
                    ),
                    onRetry: widget.onRescan,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _LanPlatformNotice extends StatelessWidget {
  const _LanPlatformNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    const color = Colors.orange;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: color, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.rajdhani(
                color: color,
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanningIndicator extends StatelessWidget {
  const _ScanningIndicator();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const NetworkScannerRadar(isScanning: true),
                NeonGlowBox(
                  glowColor: scheme.primary,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.router_rounded,
                      color: scheme.primary,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.activeNodeRecon,
            style: GoogleFonts.orbitron(
              color: scheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.interrogatingSubnet,
            style: GoogleFonts.rajdhani(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Network Bento Header ──────────────────────────────────────────

class _NetworkBentoHeader extends StatelessWidget {
  final List<dynamic> devices;
  final List<HostScanResult> hosts;
  final String target;

  const _NetworkBentoHeader({
    required this.devices,
    required this.hosts,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final avgRisk =
        hosts.isEmpty
            ? 0.0
            : hosts.map((h) => h.exposureScore).reduce((a, b) => a + b) /
                hosts.length;

    final totalServices = hosts
        .map((h) => h.services.length)
        .fold(0, (a, b) => a + b);

    return LayoutBuilder(
      builder: (context, constraints) {
        final scheme = Theme.of(context).colorScheme;
        final double radarSize = constraints.maxWidth * 0.45;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Radar Column ──
            SizedBox(
              width: radarSize,
              height: radarSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  NetworkScannerRadar(isScanning: false, color: scheme.primary),
                  Icon(
                    Icons.hub_rounded,
                    color: scheme.primary.withValues(alpha: 0.5),
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // ── Stats Grid ──
            Expanded(
              child: SizedBox(
                height: radarSize,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: BentoStatTile(
                              label: context.l10n.nodesLabel,
                              value: '${devices.length}',
                              icon: Icons.devices_other_rounded,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: BentoStatTile(
                              label: context.l10n.riskAvgLabel,
                              value: avgRisk.toStringAsFixed(1),
                              icon: Icons.gpp_maybe_rounded,
                              color:
                                  avgRisk > 5 ? scheme.error : scheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: BentoStatTile(
                              label: context.l10n.servicesLabel,
                              value: '$totalServices',
                              icon: Icons.dns_rounded,
                              color: scheme.secondary,
                              subValue: context.l10n.openPortsLabel,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: BentoStatTile(
                              label: context.l10n.subnetLabel,
                              value:
                                  target.split('.').last == '0/24'
                                      ? target.replaceAll('.0/24', '')
                                      : target,
                              icon: Icons.lan_rounded,
                              color: scheme.outline,
                              subValue: context.l10n.cidrTargetLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PulseRing extends StatefulWidget {
  final double delaySeconds;
  final Color color;

  const _PulseRing({required this.delaySeconds, required this.color});

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _opacity = Tween<double>(
      begin: 0.5,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _scale = Tween<double>(
      begin: 0.8,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(
      Duration(milliseconds: (widget.delaySeconds * 1000).toInt()),
      () {
        if (mounted) _controller.repeat();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Opacity(
            opacity: _opacity.value,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: widget.color, width: 2),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── LAN Search & Filter Bar ──────────────────────────────────────────

class _LanSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool vulnOnly;
  final ValueChanged<bool> onVulnFilterChanged;

  const _LanSearchBar({
    required this.controller,
    required this.vulnOnly,
    required this.onVulnFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          style: GoogleFonts.rajdhani(color: scheme.onSurface, fontSize: 15),
          decoration: InputDecoration(
            hintText: context.l10n.searchLanPlaceholder,
            hintStyle: GoogleFonts.rajdhani(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: scheme.primary,
              size: 20,
            ),
            suffixIcon:
                controller.text.isNotEmpty
                    ? GestureDetector(
                      onTap: () => controller.clear(),
                      child: Icon(
                        Icons.clear_rounded,
                        color: scheme.onSurfaceVariant,
                        size: 18,
                      ),
                    )
                    : null,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: scheme.primary.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: scheme.primary.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilterChip(
          label: Text(
            context.l10n.hasVulnerabilitiesLabel,
            style: GoogleFonts.rajdhani(
              color: vulnOnly ? scheme.onError : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          selected: vulnOnly,
          onSelected: onVulnFilterChanged,
          selectedColor: scheme.error.withValues(alpha: 0.2),
          checkmarkColor: scheme.error,
          side: BorderSide(
            color:
                vulnOnly
                    ? scheme.error.withValues(alpha: 0.6)
                    : scheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }
}
