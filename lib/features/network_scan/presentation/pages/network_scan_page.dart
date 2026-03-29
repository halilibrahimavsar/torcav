import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torcav/l10n/generated/app_localizations.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../domain/entities/host_scan_result.dart';

import '../../../../features/network_scan/presentation/widgets/network_scanner_radar.dart';
import '../bloc/network_scan_bloc.dart';

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

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<NetworkScanBloc, NetworkScanState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              // ── Section 1: SCAN CONTROL ──
              StaggeredEntry(
                delay: const Duration(milliseconds: 50),
                child: NeonSectionHeader(
                  label: 'NETWORK RECON',
                  icon: Icons.radar_rounded,
                  color: AppColors.neonCyan,
                ),
              ),
              const SizedBox(height: 16),
              
              StaggeredEntry(
                delay: const Duration(milliseconds: 100),
                child: _ScanControlPanel(
                  controller: _targetController,
                  isScanning: state is NetworkScanLoading,
                  onScan: () {
                    context.read<NetworkScanBloc>().add(
                          StartNetworkScan(target: _targetController.text),
                        );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // ── Results ──
              if (state is NetworkScanLoading) ...[
                const StaggeredEntry(
                  delay: Duration(milliseconds: 200),
                  child: _ScanningIndicator(),
                ),
              ],

              if (state is NetworkScanLoaded) ...[
                // ── Section 2: SCAN ANALYTICS ──
                StaggeredEntry(
                  delay: const Duration(milliseconds: 150),
                  child: NeonSectionHeader(
                    label: 'INTELLIGENCE REPORT',
                    icon: Icons.analytics_outlined,
                    color: AppColors.neonPurple,
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
                    label: 'DISCOVERED ENDPOINTS',
                    icon: Icons.devices_rounded,
                    color: AppColors.neonGreen,
                  ),
                ),
                const SizedBox(height: 16),
                
                ...state.devices.asMap().entries.map(
                  (entry) {
                    final device = entry.value;
                    final hostResult = state.hosts.firstWhere(
                      (h) => h.ip == device.ip,
                      orElse: () => HostScanResult(
                        ip: device.ip,
                        mac: device.mac,
                        vendor: device.vendor,
                        hostName: device.hostName,
                        osGuess: 'Unknown',
                        latency: device.latency,
                        services: const [],
                        vulnerabilities: const [],
                        exposureScore: 0,
                        deviceType: 'Unknown',
                      ),
                    );
                    return StaggeredEntry(
                      delay: Duration(milliseconds: 250 + entry.key * 50),
                      child: _DeviceCard(host: hostResult),
                    );
                  },
                ),
              ],

              if (state is NetworkScanError) ...[
                StaggeredEntry(
                  delay: const Duration(milliseconds: 200),
                  child: _ErrorCard(message: state.message),
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

  const _ScanControlPanel({
    required this.controller,
    required this.isScanning,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NeonCard(
      glowColor: AppColors.neonCyan,
      glowIntensity: 0.06,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonText(
            l10n.lanReconTitle,
            style: GoogleFonts.orbitron(
              color: AppColors.neonCyan,
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
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              labelText: l10n.targetSubnet,
              prefixIcon: Icon(
                Icons.network_check_rounded,
                color: AppColors.neonCyan.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isScanning ? null : onScan,
                borderRadius: BorderRadius.circular(12),
                splashColor: AppColors.neonCyan.withValues(alpha: 0.1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isScanning
                        ? AppColors.glassWhite
                        : AppColors.neonCyan.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.neonCyan.withValues(
                        alpha: isScanning ? 0.1 : 0.3,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isScanning)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.neonCyan,
                          ),
                        )
                      else
                        const Icon(
                          Icons.radar_rounded,
                          color: AppColors.neonCyan,
                          size: 20,
                        ),
                      const SizedBox(width: 10),
                      Text(
                        isScanning
                            ? l10n.analyzing.toUpperCase()
                            : l10n.scanAllCaps,
                        style: GoogleFonts.orbitron(
                          color: AppColors.neonCyan,
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
                  glowColor: AppColors.neonCyan,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neonCyan.withValues(alpha: 0.1),
                    ),
                    child: const Icon(
                      Icons.router_rounded,
                      color: AppColors.neonCyan,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'ACTIVE NODE RECONNAISSANCE'.toUpperCase(),
            style: GoogleFonts.orbitron(
              color: AppColors.neonCyan,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Interrogating subnet for responsive hosts...',
            style: GoogleFonts.rajdhani(
              color: AppColors.textMuted,
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
    final avgRisk = hosts.isEmpty 
        ? 0.0 
        : hosts.map((h) => h.exposureScore).reduce((a, b) => a + b) / hosts.length;
    
    final totalServices = hosts.map((h) => h.services.length).fold(0, (a, b) => a + b);

    return LayoutBuilder(
      builder: (context, constraints) {
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
                    nodeCount: devices.length,
                    color: AppColors.neonCyan,
                  ),
                  Icon(
                    Icons.hub_rounded,
                    color: AppColors.neonCyan.withValues(alpha: 0.5),
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
                              label: 'Nodes',
                              value: '${devices.length}',
                              icon: Icons.devices_other_rounded,
                              color: AppColors.neonCyan,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: BentoStatTile(
                              label: 'Risk Avg',
                              value: avgRisk.toStringAsFixed(1),
                              icon: Icons.gpp_maybe_rounded,
                              color: avgRisk > 5 ? AppColors.neonRed : AppColors.neonGreen,
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
                              label: 'Services',
                              value: '$totalServices',
                              icon: Icons.dns_rounded,
                              color: AppColors.neonPurple,
                              subValue: 'OPEN PORTS',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: BentoStatTile(
                              label: 'Subnet',
                              value: target.split('.').last == '0/24' 
                                  ? target.replaceAll('.0/24', '') 
                                  : target,
                              icon: Icons.lan_rounded,
                              color: AppColors.neonOrange,
                              subValue: 'CIDR TARGET',
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

class _PulseRingState extends State<_PulseRing> with SingleTickerProviderStateMixin {
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

    _opacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.8, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: (widget.delaySeconds * 1000).toInt()), () {
      if (mounted) _controller.repeat();
    });
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

  Color get _riskColor {
    if (host.exposureScore > 7) return AppColors.neonRed;
    if (host.exposureScore > 3) return AppColors.neonOrange;
    return AppColors.neonGreen;
  }

  IconData get _deviceIcon {
    final name = host.hostName.toLowerCase();
    final vendor = host.vendor.toLowerCase();
    if (name.contains('phone') || name.contains('android') || name.contains('iphone')) return Icons.smartphone_rounded;
    if (name.contains('tablet') || name.contains('ipad')) return Icons.tablet_mac_rounded;
    if (name.contains('laptop') || name.contains('macbook')) return Icons.laptop_chromebook_rounded;
    if (name.contains('tv') || name.contains('television')) return Icons.tv_rounded;
    if (name.contains('router') || name.contains('gateway') || vendor.contains('tp-link') || vendor.contains('asus')) return Icons.router_rounded;
    if (name.contains('watch')) return Icons.watch_rounded;
    return Icons.settings_input_component_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeonCard(
        glowColor: _riskColor,
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
                    color: _riskColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: _riskColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _deviceIcon,
                    color: _riskColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        host.hostName.isEmpty ? 'ANONYMOUS NODE' : host.hostName.toUpperCase(),
                        style: GoogleFonts.orbitron(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        host.ip,
                        style: GoogleFonts.sourceCodePro(
                          color: AppColors.neonCyan,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
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
              color: AppColors.glassWhite.withValues(alpha: 0.05),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _TechDetail(
                  label: host.mac.toUpperCase(),
                  icon: Icons.fingerprint_rounded,
                  color: AppColors.textMuted,
                ),
                if (host.vendor.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TechDetail(
                      label: host.vendor.toUpperCase(),
                      icon: Icons.factory_rounded,
                      color: AppColors.neonPurple,
                    ),
                  ),
                ],
                if (host.services.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _riskColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _riskColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${host.services.length} PORTS',
                      style: GoogleFonts.orbitron(
                        color: _riskColor,
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
    final color = score > 7 ? AppColors.neonRed : (score > 3 ? AppColors.neonOrange : AppColors.neonGreen);
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
          'RISK',
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

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      glowColor: AppColors.neonRed,
      glowIntensity: 0.08,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.neonRed,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.rajdhani(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
