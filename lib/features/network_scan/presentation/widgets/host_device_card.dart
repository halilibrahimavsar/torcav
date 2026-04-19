import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/neon_widgets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/host_scan_result.dart';
import '../../domain/entities/service_fingerprint.dart';
import '../../domain/usecases/port_scan_usecase.dart';

enum _PortScanState { idle, scanning, done }

class HostDeviceCard extends StatefulWidget {
  final HostScanResult host;

  const HostDeviceCard({super.key, required this.host});

  @override
  State<HostDeviceCard> createState() => _HostDeviceCardState();
}

class _HostDeviceCardState extends State<HostDeviceCard> {
  bool _isExpanded = false;
  _PortScanState _portScanState = _PortScanState.idle;
  final List<ServiceFingerprint> _scannedServices = [];
  StreamSubscription<ServiceFingerprint>? _scanSub;
  int _scannedPortCount = 0;
  static const int _totalPorts = 25;

  @override
  void initState() {
    super.initState();
    // Pre-populate with services already discovered during LAN scan
    _scannedServices.addAll(widget.host.services);
    if (_scannedServices.isNotEmpty) {
      _portScanState = _PortScanState.done;
    }
  }

  @override
  void didUpdateWidget(HostDeviceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Merge newly discovered services (from enrichment phase)
    for (final s in widget.host.services) {
      if (!_scannedServices.any((e) => e.port == s.port)) {
        _scannedServices.add(s);
      }
    }
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    super.dispose();
  }

  void _startPortScan() {
    if (_portScanState == _PortScanState.scanning) return;
    setState(() {
      _portScanState = _PortScanState.scanning;
      _scannedPortCount = 0;
    });

    final useCase = getIt<PortScanUseCase>();
    _scanSub = useCase.callReactive(widget.host.ip).listen(
      (service) {
        if (!mounted) return;
        setState(() {
          _scannedPortCount++;
          if (!_scannedServices.any((s) => s.port == service.port)) {
            _scannedServices.add(service);
          }
        });
      },
      onDone: () {
        if (!mounted) return;
        setState(() {
          _portScanState = _PortScanState.done;
          _scannedPortCount = _totalPorts;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _portScanState = _PortScanState.done);
      },
    );
  }

  Color getRiskColor(BuildContext context) {
    if (widget.host.exposureScore > 7) {
      return Theme.of(context).colorScheme.error;
    }
    if (widget.host.exposureScore > 3) {
      return Theme.of(context).colorScheme.outline;
    }
    return Theme.of(context).colorScheme.tertiary;
  }

  IconData get _deviceIcon {
    final type = widget.host.deviceType.toLowerCase();
    if (type.contains('router') || type.contains('gateway')) return Icons.router_rounded;
    if (type.contains('smart tv')) return Icons.tv_rounded;
    if (type.contains('audio') || type.contains('speaker')) return Icons.speaker_group_rounded;
    if (type.contains('printer')) return Icons.print_rounded;
    if (type.contains('workstation')) return Icons.computer_rounded;
    if (type.contains('mobile') || type.contains('phone')) return Icons.smartphone_rounded;
    if (type.contains('nas') || type.contains('storage')) return Icons.dns_rounded;

    final name = widget.host.hostName.toLowerCase();
    final vendor = widget.host.vendor.toLowerCase();
    if (name.contains('phone') || name.contains('android') || name.contains('iphone')) {
      return Icons.smartphone_rounded;
    }
    if (name.contains('tablet') || name.contains('ipad')) return Icons.tablet_mac_rounded;
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
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Row ──
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: riskColor.withValues(alpha: 0.1),
                    border: Border.all(color: riskColor.withValues(alpha: 0.2), width: 1),
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
                              widget.host.hostName.isEmpty
                                  ? '${widget.host.ip} (${widget.host.deviceType.toUpperCase()})'
                                  : widget.host.hostName.toUpperCase(),
                              style: GoogleFonts.orbitron(
                                color: scheme.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.host.isGateway) ...[
                            const SizedBox(width: 6),
                            _Badge(label: 'GATEWAY', color: scheme.tertiary),
                          ],
                          if (widget.host.deviceType != 'Unknown') ...[
                            const SizedBox(width: 6),
                            _Badge(label: 'IDENTIFIED', color: scheme.primary),
                          ],
                          if (widget.host.isAiClassified) ...[
                            const SizedBox(width: 6),
                            const _AiBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            widget.host.ip,
                            style: GoogleFonts.sourceCodePro(
                              color: scheme.primary.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.host.deviceType != 'Unknown') ...[
                            Text(' • ', style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.3))),
                            Text(
                              widget.host.deviceType.toUpperCase(),
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
                _RiskIndicator(score: widget.host.exposureScore),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1, width: double.infinity, color: scheme.onSurface.withValues(alpha: 0.1)),
            const SizedBox(height: 12),

            // ── Footer Row ──
            Row(
              children: [
                _TechDetail(
                  label: widget.host.mac == '00:00:00:00:00:00'
                      ? 'UNKNOWN MAC (RESTRICTED)'
                      : widget.host.mac.toUpperCase(),
                  icon: Icons.fingerprint_rounded,
                  color: scheme.onSurfaceVariant,
                ),
                if (widget.host.vendor.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TechDetail(
                      label: widget.host.vendor.toUpperCase(),
                      icon: Icons.factory_rounded,
                      color: scheme.secondary,
                    ),
                  ),
                ],
                if (_scannedServices.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _PortsCountBadge(count: _scannedServices.length, color: riskColor),
                ],
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),

            // ── Expanded Port Scan Section ──
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              const NeonDivider(height: 0.5),
              const SizedBox(height: 12),
              _PortScanSection(
                services: _scannedServices,
                scanState: _portScanState,
                scannedPortCount: _scannedPortCount,
                onScanRequested: _startPortScan,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Port Scan Section ──────────────────────────────────────────────

class _PortScanSection extends StatelessWidget {
  final List<ServiceFingerprint> services;
  final _PortScanState scanState;
  final int scannedPortCount;
  final VoidCallback onScanRequested;

  const _PortScanSection({
    required this.services,
    required this.scanState,
    required this.scannedPortCount,
    required this.onScanRequested,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.manage_search_rounded, size: 14, color: scheme.primary.withValues(alpha: 0.7)),
            const SizedBox(width: 6),
            Text(
              'PORT SCAN',
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: scheme.primary.withValues(alpha: 0.7),
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            if (scanState == _PortScanState.scanning) ...[
              Text(
                '$scannedPortCount / 25',
                style: GoogleFonts.sourceCodePro(
                  color: scheme.primary.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: scheme.primary),
              ),
            ] else if (scanState == _PortScanState.done) ...[
              Icon(Icons.check_circle_rounded, size: 14, color: scheme.tertiary),
              const SizedBox(width: 4),
              Text(
                'COMPLETE',
                style: GoogleFonts.orbitron(
                  fontSize: 9,
                  color: scheme.tertiary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ],
        ),

        if (scanState == _PortScanState.scanning && services.isEmpty) ...[
          const SizedBox(height: 12),
          _ScanProgressBar(progress: scannedPortCount / 25, color: scheme.primary),
          const SizedBox(height: 8),
          Text(
            'Probing ports...',
            style: GoogleFonts.rajdhani(
              color: scheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],

        if (services.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: services.map((s) => _ServiceChip(service: s)).toList(),
          ),
          if (scanState == _PortScanState.scanning) ...[
            const SizedBox(height: 10),
            _ScanProgressBar(progress: scannedPortCount / 25, color: scheme.primary),
          ],
        ],

        if (scanState == _PortScanState.idle) ...[
          const SizedBox(height: 12),
          if (services.isEmpty)
            Text(
              'No ports probed yet. Run a port scan to discover open services.',
              style: GoogleFonts.rajdhani(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          const SizedBox(height: 10),
          _ScanButton(onTap: onScanRequested),
        ],

        if (scanState == _PortScanState.done && services.isEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.lock_rounded, size: 14, color: scheme.tertiary.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text(
                'No open ports found',
                style: GoogleFonts.rajdhani(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ScanProgressBar extends StatelessWidget {
  final double progress;
  final Color color;

  const _ScanProgressBar({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        backgroundColor: color.withValues(alpha: 0.1),
        valueColor: AlwaysStoppedAnimation<Color>(color.withValues(alpha: 0.6)),
        minHeight: 3,
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.radar_rounded, size: 14, color: scheme.primary),
            const SizedBox(width: 6),
            Text(
              'SCAN PORTS',
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: scheme.primary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Service Chip ──────────────────────────────────────────────────

class _ServiceChip extends StatelessWidget {
  final ServiceFingerprint service;
  const _ServiceChip({required this.service});

  Color _getServiceColor(BuildContext context, int port) {
    final scheme = Theme.of(context).colorScheme;
    if (port == 80 || port == 443 || port == 8080 || port == 8443) return scheme.tertiary;
    if (port == 22 || port == 23) return scheme.error;
    if (port == 21 || port == 445 || port == 139) return scheme.secondary;
    if (port == 53) return Colors.cyanAccent;
    if (port == 3306 || port == 5432 || port == 1433 || port == 27017) return Colors.orangeAccent;
    if (port == 3389 || port == 5900) return scheme.error;
    if (port == 6379) return Colors.redAccent;
    return scheme.outline;
  }

  IconData _getServiceIcon(int port) {
    if (port == 80 || port == 443 || port == 8080 || port == 8443) return Icons.public_rounded;
    if (port == 22) return Icons.terminal_rounded;
    if (port == 23) return Icons.warning_rounded;
    if (port == 21) return Icons.folder_shared_rounded;
    if (port == 53) return Icons.dns_rounded;
    if (port == 445 || port == 139) return Icons.storage_rounded;
    if (port == 3389 || port == 5900) return Icons.desktop_windows_rounded;
    if (port == 3306 || port == 5432 || port == 1433 || port == 27017) return Icons.table_chart_rounded;
    if (port == 6379) return Icons.memory_rounded;
    return Icons.settings_ethernet_rounded;
  }

  String _getRiskLabel(int port) {
    if (port == 23) return 'CRITICAL';
    if (port == 22 || port == 3389 || port == 5900) return 'HIGH';
    if (port == 445 || port == 139 || port == 6379 || port == 27017) return 'HIGH';
    if (port == 21 || port == 25 || port == 111 || port == 514) return 'MEDIUM';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getServiceColor(context, service.port);
    final icon = _getServiceIcon(service.port);
    final riskLabel = _getRiskLabel(service.port);
    final hasDetail = service.product.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${service.port}',
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    service.serviceName.toUpperCase(),
                    style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                  if (riskLabel.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        riskLabel,
                        style: GoogleFonts.orbitron(
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (hasDetail)
                Text(
                  service.product,
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 9,
                    color: color.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.orbitron(fontSize: 8, fontWeight: FontWeight.w900, color: color),
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();

  @override
  Widget build(BuildContext context) {
    final tertiary = Theme.of(context).colorScheme.tertiary;
    return NeonGlowBox(
      glowColor: tertiary,
      minOpacity: 0.1,
      maxOpacity: 0.3,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [tertiary.withValues(alpha: 0.2), tertiary.withValues(alpha: 0.1)],
          ),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: tertiary.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 8, color: tertiary),
            const SizedBox(width: 4),
            Text(
              context.l10n.aiBadgeLabel.toUpperCase(),
              style: GoogleFonts.orbitron(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: tertiary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortsCountBadge extends StatelessWidget {
  final int count;
  final Color color;
  const _PortsCountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        context.l10n.portsCountLabel(count),
        style: GoogleFonts.orbitron(color: color, fontSize: 10, fontWeight: FontWeight.w900),
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
    final color = score > 7 ? scheme.error : (score > 3 ? scheme.outline : scheme.tertiary);
    return Column(
      children: [
        NeonText(
          score.toStringAsFixed(1),
          style: GoogleFonts.orbitron(color: color, fontWeight: FontWeight.w900, fontSize: 16),
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

  const _TechDetail({required this.label, required this.icon, required this.color});

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
            style: GoogleFonts.rajdhani(color: color, fontSize: 12, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
