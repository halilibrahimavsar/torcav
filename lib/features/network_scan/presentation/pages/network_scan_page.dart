import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/extensions/context_extensions.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../domain/entities/host_scan_result.dart';
import '../../domain/entities/network_scan_profile.dart';

import '../../../../features/network_scan/presentation/widgets/network_scanner_radar.dart';
import '../bloc/network_scan_bloc.dart';
import '../widgets/host_device_card.dart';
import '../widgets/lan_consent_dialog.dart';

class NetworkScanPage extends StatelessWidget {
  const NetworkScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NetworkScanBloc>(),
      child: const _NetworkScanView(),
    );
  }
}

class _NetworkScanView extends StatefulWidget {
  const _NetworkScanView();

  @override
  State<_NetworkScanView> createState() => _NetworkScanViewState();
}

class _NetworkScanViewState extends State<_NetworkScanView> {
  final _targetController = TextEditingController(text: '192.168.1.0/24');
  final _searchController = TextEditingController();
  bool _vulnOnly = false;
  String _searchQuery = '';
  NetworkScanProfile _profile = NetworkScanProfile.fast;

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
    _targetController.dispose();
    _searchController.dispose();
    super.dispose();
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
              builder: (context) => const LanConsentDialog(),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(label),
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          final loadedState = state is NetworkScanLoaded ? state : null;
          final isActivelyScanning =
              state is NetworkScanLoading ||
              (loadedState != null && loadedState.isScanning);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              // ── Section 1: SCAN CONTROL ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 50),
                child: NeonSectionHeader(
                  label: context.l10n.networkReconTitle,
                  icon: Icons.radar_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              StaggeredEntry(
                delay: const Duration(milliseconds: 100),
                child: _ScanControlPanel(
                  controller: _targetController,
                  isScanning: isActivelyScanning,
                  profile: _profile,
                  onProfileChanged: (p) => setState(() => _profile = p),
                  onScan: () {
                    context.read<NetworkScanBloc>().add(
                      StartNetworkScan(
                        target: _targetController.text,
                        profile: _profile,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // ── Scanning Banner (compact, shown while scanning) ──
              Visibility(
                visible: isActivelyScanning,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: false,
                child: _ScanningBanner(
                  foundCount: loadedState?.hosts.length ?? 0,
                ),
              ),

              // ── Full-screen radar (only when no results yet) ──
              if (state is NetworkScanLoading)
                const _ScanningIndicator(),

              if (state case final NetworkScanLoaded loaded) ...[
                const SizedBox(height: 16),
                // ── Section 2: SCAN ANALYTICS ──
                StaggeredEntry(
                  delay: const Duration(milliseconds: 150),
                  child: NeonSectionHeader(
                    label: context.l10n.intelligenceReportTitle,
                    icon: Icons.analytics_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 16),

                _NetworkBentoHeader(
                  devices: loaded.devices,
                  hosts: loaded.hosts,
                  target: _targetController.text,
                ),
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
                  final hosts = loaded.hosts.where((h) {
                        if (_vulnOnly && h.vulnerabilities.isEmpty) {
                          return false;
                        }
                        if (_searchQuery.isNotEmpty) {
                          if (!h.ip.contains(_searchQuery) &&
                              !h.hostName.toLowerCase().contains(_searchQuery) &&
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
                    message: state.message,
                    onRetry:
                        () => context.read<NetworkScanBloc>().add(
                          StartNetworkScan(target: _targetController.text),
                        ),
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

class _ScanControlPanel extends StatelessWidget {
  final TextEditingController controller;
  final bool isScanning;
  final VoidCallback onScan;
  final NetworkScanProfile profile;
  final ValueChanged<NetworkScanProfile> onProfileChanged;

  const _ScanControlPanel({
    required this.controller,
    required this.isScanning,
    required this.onScan,
    required this.profile,
    required this.onProfileChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final scheme = Theme.of(context).colorScheme;

    return NeonCard(
      glowColor: scheme.primary,
      glowIntensity: 0.06,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonText(
            l10n.lanReconTitle,
            style: GoogleFonts.orbitron(
              color: scheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            glowRadius: 6,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            style: GoogleFonts.sourceCodePro(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              labelText: l10n.targetSubnet,
              prefixIcon: Icon(
                Icons.network_check_rounded,
                color: scheme.primary.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ── Scan Profile Selector ──
          Row(
            children: [
              Icon(
                Icons.tune_rounded,
                size: 16,
                color: scheme.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.scanProfileLabel,
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  color: scheme.primary.withValues(alpha: 0.7),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 4),
              InfoIconButton(
                title: l10n.infoScanProfilesTitle,
                body:
                    '${l10n.infoScanProfileFastDesc}\n\n'
                    '${l10n.infoScanProfileBalancedDesc}\n\n'
                    '${l10n.infoScanProfileAggressiveDesc}',
                color: scheme.primary,
              ),
              const Spacer(),
              DropdownButton<NetworkScanProfile>(
                value: profile,
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
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isScanning ? null : onScan,
                borderRadius: BorderRadius.circular(12),
                splashColor: scheme.primary.withValues(alpha: 0.1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color:
                        isScanning
                            ? scheme.surfaceContainerHighest
                            : scheme.primary.withValues(alpha: 0.12),
                    border: Border.all(
                      color: scheme.primary.withValues(
                        alpha: isScanning ? 0.1 : 0.3,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isScanning)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.primary,
                          ),
                        )
                      else
                        Icon(
                          Icons.radar_rounded,
                          color: scheme.primary,
                          size: 20,
                        ),
                      const SizedBox(width: 10),
                      Text(
                        isScanning
                            ? l10n.analyzing.toUpperCase()
                            : l10n.scanAllCaps,
                        style: GoogleFonts.orbitron(
                          color: scheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanningBanner extends StatelessWidget {
  final int foundCount;
  const _ScanningBanner({required this.foundCount});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: NetworkScannerRadar(isScanning: true, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.activeNodeRecon,
                  style: GoogleFonts.orbitron(
                    color: scheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                if (foundCount > 0)
                  Text(
                    '$foundCount ${context.l10n.nodesLabel.toLowerCase()} found...',
                    style: GoogleFonts.rajdhani(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 18,
            height: 18,
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
