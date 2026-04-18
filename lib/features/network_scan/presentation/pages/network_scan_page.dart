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
  bool _deepScan = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
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
        listenWhen: (prev, next) =>
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
            final label = count == 1
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
          final isLoading = state is NetworkScanLoading;
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
                  isScanning: isLoading,
                  profile: _profile,
                  onProfileChanged: (p) => setState(() => _profile = p),
                  deepScan: _deepScan,
                  onDeepScanChanged: (v) => setState(() => _deepScan = v),
                  onScan: () {
                    context.read<NetworkScanBloc>().add(
                      StartNetworkScan(
                        target: _targetController.text,
                        profile: _profile,
                        deepScan: _deepScan,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // ── Scanning Indicator ──
              // Keep this widget permanently in the tree (never conditionally
              // inserted/removed from the list) so Flutter never disposes its
              // AnimationController mid-animation. Visibility preserves the
              // element while hiding it, keeping the radar sweep running.
              Visibility(
                visible: isLoading,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: false,
                child: const _ScanningIndicator(),
              ),

              if (state is NetworkScanLoaded) ...[
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
                  devices: state.devices,
                  hosts: state.hosts,
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
                  final hosts = state.hosts.where((h) {
                    if (_vulnOnly && h.vulnerabilities.isEmpty) return false;
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
                      delay: Duration(milliseconds: 250 + entry.key * 50),
                      child: _DeviceCard(host: entry.value),
                    );
                  });
                }(),
              ],

              if (state is NetworkScanError) ...[
                StaggeredEntry(
                  delay: const Duration(milliseconds: 200),
                  child: NeonErrorCard(
                    message: state.message,
                    onRetry: () => context.read<NetworkScanBloc>().add(
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
  final bool deepScan;
  final ValueChanged<bool> onDeepScanChanged;

  const _ScanControlPanel({
    required this.controller,
    required this.isScanning,
    required this.onScan,
    required this.profile,
    required this.onProfileChanged,
    required this.deepScan,
    required this.onDeepScanChanged,
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
                items: NetworkScanProfile.values
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: isScanning
                    ? null
                    : (p) {
                        if (p != null) onProfileChanged(p);
                      },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Deep Scan Toggle ──
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                size: 16,
                color: scheme.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.deepScan,
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  color: scheme.primary.withValues(alpha: 0.7),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 4),
              InfoIconButton(
                title: l10n.deepScan,
                body: 'Comprehensive port scanning and service fingerprinting. '
                    'Enabling this will significantly increase scan time but '
                    'provides much deeper reconnaissance data.',
                color: scheme.primary,
              ),
              const Spacer(),
              Transform.scale(
                scale: 0.8,
                child: Switch.adaptive(
                  value: deepScan,
                  activeColor: scheme.primary,
                  onChanged: isScanning ? null : onDeepScanChanged,
                ),
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
                  NetworkScannerRadar(
                    isScanning: false,
                    color: scheme.primary,
                  ),
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
                                  avgRisk > 5
                                      ? scheme.error
                                      : scheme.tertiary,
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

class _DeviceCard extends StatelessWidget {
  final HostScanResult host;

  const _DeviceCard({required this.host});

  Color getRiskColor(BuildContext context) {
    if (host.exposureScore > 7) return Theme.of(context).colorScheme.error;
    if (host.exposureScore > 3) return Theme.of(context).colorScheme.outline;
    return Theme.of(context).colorScheme.tertiary;
  }

  IconData get _deviceIcon {
    final type = host.deviceType.toLowerCase();
    
    if (type.contains('router') || type.contains('gateway')) {
      return Icons.router_rounded;
    }
    if (type.contains('smart tv')) {
      return Icons.tv_rounded;
    }
    if (type.contains('audio') || type.contains('speaker')) {
      return Icons.speaker_group_rounded;
    }
    if (type.contains('printer')) {
      return Icons.print_rounded;
    }
    if (type.contains('workstation')) {
      return Icons.computer_rounded;
    }
    if (type.contains('mobile') || type.contains('phone')) {
      return Icons.smartphone_rounded;
    }
    if (type.contains('nas') || type.contains('storage')) {
      return Icons.dns_rounded;
    }
    
    // Fallback to name/vendor guessing if type is generic
    final name = host.hostName.toLowerCase();
    final vendor = host.vendor.toLowerCase();
    if (name.contains('phone') ||
        name.contains('android') ||
        name.contains('iphone')) {
      return Icons.smartphone_rounded;
    }
    if (name.contains('tablet') || name.contains('ipad')) {
      return Icons.tablet_mac_rounded;
    }
    if (name.contains('laptop') || name.contains('macbook') || vendor.contains('apple')) {
      return Icons.laptop_chromebook_rounded;
    }
    return Icons.settings_input_component_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = getRiskColor(context);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeonCard(
        glowColor: riskColor,
        glowIntensity: 0.08,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: riskColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: riskColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(_deviceIcon, color: riskColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              host.hostName.isEmpty
                                  ? context.l10n.anonymousNode
                                  : host.hostName.toUpperCase(),
                              style: GoogleFonts.orbitron(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (host.isGateway) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.tertiary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: scheme.tertiary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                'GATEWAY',
                                style: GoogleFonts.orbitron(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: scheme.tertiary,
                                ),
                              ),
                            ),
                          ],
                          if (host.deviceType != 'Unknown') ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                'IDENTIFIED',
                                style: GoogleFonts.orbitron(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            host.ip,
                            style: GoogleFonts.sourceCodePro(
                              color: scheme.primary.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (host.deviceType != 'Unknown') ...[
                            Text(
                              ' • ',
                              style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.3)),
                            ),
                            Text(
                              host.deviceType.toUpperCase(),
                              style: GoogleFonts.rajdhani(
                                color: scheme.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                _RiskIndicator(score: host.exposureScore),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              width: double.infinity,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.1),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _TechDetail(
                  label: host.mac.toUpperCase(),
                  icon: Icons.fingerprint_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                if (host.vendor.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TechDetail(
                      label: host.vendor.toUpperCase(),
                      icon: Icons.factory_rounded,
                      color: scheme.secondary,
                    ),
                  ),
                ],
                if (host.services.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: riskColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      context.l10n.portsCountLabel(host.services.length),
                      style: GoogleFonts.orbitron(
                        color: riskColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskIndicator extends StatelessWidget {
  final double score;

  const _RiskIndicator({required this.score});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color =
        score > 7
            ? scheme.error
            : (score > 3
                ? scheme.outline
                : scheme.tertiary);
    return Column(
      children: [
        NeonText(
          score.toStringAsFixed(1),
          style: GoogleFonts.orbitron(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
          glowColor: color,
          glowRadius: 4,
        ),
        Text(
          context.l10n.riskLabel,
          style: GoogleFonts.rajdhani(
            color: color.withValues(alpha: 0.7),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _TechDetail extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _TechDetail({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.rajdhani(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
            prefixIcon: Icon(Icons.search_rounded, color: scheme.primary, size: 20),
            suffixIcon: controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: () => controller.clear(),
                    child: Icon(Icons.clear_rounded, color: scheme.onSurfaceVariant, size: 18),
                  )
                : null,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.7)),
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
            color: vulnOnly
                ? scheme.error.withValues(alpha: 0.6)
                : scheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }
}
